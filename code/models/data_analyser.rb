class DataAnalyser

  YEARSLOOKBACK = 9

  def self.fetch(provider, start_month=nil, end_month=nil, north=nil, east=nil, south=nil, west=nil)
    sites = Site.fetch(provider)
    fetch_monthly_data(provider, start_month, end_month, north, east, south, west)
  end

  def self.in_date_range(month, year, start_time, end_time)
    start_month, start_year = start_time.split('-').map {|a| a.to_i}
    end_month,   end_year =   end_time.split('-').map {|a| a.to_i}
    (year >= start_year) && (year <= end_year) &&
        (year != start_year || month >= start_month) &&
        (year != end_year || month <= end_month)
  end

  def self.fetch_monthly_data(provider, start_month=nil, end_month=nil, north=nil, east=nil, south=nil, west=nil)
    monthlyData = {}
    unless north.nil?
      sites = Site.all_as_hash.select {|site_id, site| site.in_bounding_box(north, east, south, west)}
    else
      sites = Site.all_as_hash
    end

    sites.each do |site_id, site|
      start_month ||= '00-0000'
      end_month ||= '99-999999'
      time_series = 'http://lab.environment.data.gov.au/def/acorn/time-series/'
      acorn_sat   = 'http://lab.environment.data.gov.au/def/acorn/sat/'

      max_temp = RDF::URI(time_series + 'maxTemperatureMax')
      min_temp = RDF::URI(time_series + 'minTemperatureMin')
      station  = RDF::URI('http://lab.environment.data.gov.au/data/acorn/climate/slice/station/' + site_id)
      subslice = RDF::URI('http://purl.org/linked-data/cube#subSlice')
      acorn_year  = RDF::URI(acorn_sat + 'year')
      acorn_month = RDF::URI(acorn_sat + 'month')

      vars = [:max, :min, :year, :month]
      patterns = [
          [station,    subslice,   :sliceyear],
          [:sliceyear, subslice,   :yearmonth],
          [:yearmonth, acorn_year, :year],
          [:yearmonth, acorn_month,:month],
          [:yearmonth, max_temp,   :max],
          [:yearmonth, min_temp,   :min]
      ]

      max_result = {}
      min_result = {}
      provider.fetch(vars, patterns).each do |solution|

        year = id_from_uri(solution[:year]).to_i
        month = id_from_uri(solution[:month]).to_i
          max_result[id_from_uri(solution[:month]).to_i] ||= {}
          max_result[id_from_uri(solution[:month]).to_i][id_from_uri(solution[:year]).to_i] = solution[:max].to_f

          min_result[id_from_uri(solution[:month]).to_i] ||= {}
          min_result[id_from_uri(solution[:month]).to_i][id_from_uri(solution[:year]).to_i] = solution[:min].to_f

      end

      (1..12).each do |month|
        monthly_max_stats = statistics(max_result[month])
        monthly_max_means = movingmean(max_result[month])
        monthly_min_stats = statistics(min_result[month])
        monthly_min_means = movingmean(min_result[month])

        (1910..2011).each do |year|
          if in_date_range(month, year, start_month, end_month) || start_month.nil?
            MonthlyData.create!(
                year: year,
                month: month,
                year_month: year*100 + month,
                high_max_temp: max_result[month][year],
                low_min_temp: min_result[month][year],
                max_highest_since: monthly_max_stats[:highestsince][year],
                max_lowest_since:monthly_max_stats[:lowestsince][year],
                max_ten_max:monthly_max_stats[:rollmax][year],
                max_ten_min:monthly_max_stats[:rollmin][year],
                max_moving_mean:monthly_max_means[year],
                min_highest_since: monthly_min_stats[:highestsince][year],
                min_lowest_since:monthly_min_stats[:lowestsince][year],
                min_ten_max:monthly_min_stats[:rollmax][year],
                min_ten_min:monthly_min_stats[:rollmin][year],
                min_moving_mean:monthly_min_means[year],
                site: site
            )
          end
        end

      end
      # through montly data
      # monthly.each
      # MonthlyData.create_from_solution!(solution, site)
      puts "#{site_id} has been completed!"
    end
  end

  def self.id_from_uri(site_uri)
    site_uri.to_s.split('/').last
  end

  def self.statistics(years)
    yearsHighestSince = {}
    yearsLowestSince = {}
    yearsRollMax = {}
    yearsRollMin = {}

    years.each do |key, datapoint|

      countdownyear = key
      highestsince = nil
      tenmax = datapoint

      while ((highestsince.nil? || key - countdownyear+1 <= YEARSLOOKBACK )&& years.include?(countdownyear-1))
        countdownyear = countdownyear -1

        if (years[countdownyear] >= datapoint && highestsince.nil?)
          highestsince = countdownyear
        end

        if (key - countdownyear <= YEARSLOOKBACK && years[countdownyear] > tenmax)
          tenmax = years[countdownyear]
        end

      end
      if  highestsince.nil?
        highestsince = 'ever'
      end
      yearsHighestSince[key] = highestsince
      yearsRollMax[key] = tenmax

      countdownyear = key
      lowestsince = nil
      tenmin = datapoint

      while ((lowestsince.nil? || key - countdownyear+1 <= YEARSLOOKBACK) && years.include?(countdownyear-1))
        countdownyear = countdownyear -1


        if (years[countdownyear] <= datapoint && lowestsince.nil?)
          lowestsince = countdownyear
        end

        if (key - countdownyear <= YEARSLOOKBACK && years[countdownyear] < tenmin)
          tenmin = years[countdownyear]
        end

      end
      if  lowestsince.nil?
        lowestsince = 'ever'
      end

      yearsLowestSince[key] = lowestsince
      yearsRollMin[key] = tenmin
    end

    yearsHighestSince.each do |key, datapoint|
      #puts "#{key}: #{years[key]}, highest since #{datapoint}, ten year max of #{yearsRollMax[key]}"
    end

    yearsLowestSince.each do |key, datapoint|
      #puts "#{key}: #{years[key]}, lowest since #{datapoint}, ten year min of max of #{yearsRollMax[key]}"
    end

    {:highestsince => yearsHighestSince, :lowestsince => yearsLowestSince, :rollmax => yearsRollMax, :rollmin => yearsRollMin}
  end

  def self.movingmean(years)

    yearsMovingMean = {}

    years.each do |key, datapoint|
      countdownyear = key
      movingtotal = datapoint
      movingcount = 1

      #puts "#{key} has temp #{datapoint}"

      while years.include?(countdownyear-1) && key-countdownyear+1 <= YEARSLOOKBACK
        countdownyear = countdownyear -1
        movingtotal += years[countdownyear]
        movingcount = movingcount + 1
        #puts "#{movingcount} adds to #{movingtotal} from #{countdownyear}"
      end

      yearsMovingMean[key] = movingtotal / movingcount
    end

    yearsMovingMean.each do |key, datapoint|
      #puts "#{key}: rolling mean of #{datapoint}"
    end

    yearsMovingMean
  end
end