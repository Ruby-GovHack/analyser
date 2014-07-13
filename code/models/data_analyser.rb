class DataAnalyser

  YEARS_LOOK_BACK = 9

  SPACESHIP_LESS = -1
  SPACESHIP_EQUAL = 0
  SPACESHIP_GREATER = 1

  def self.fetch_monthly(provider, site_id)
    start_month ||= '00-0000'
    end_month ||= '99-999999'
    time_series = 'http://lab.environment.data.gov.au/def/acorn/time-series/'
    acorn_sat = 'http://lab.environment.data.gov.au/def/acorn/sat/'

    max_temp = RDF::URI(time_series + 'maxTemperatureMax')
    min_temp = RDF::URI(time_series + 'minTemperatureMin')
    station = RDF::URI('http://lab.environment.data.gov.au/data/acorn/climate/slice/station/' + site_id)
    subslice = RDF::URI('http://purl.org/linked-data/cube#subSlice')
    acorn_year = RDF::URI(acorn_sat + 'year')
    acorn_month = RDF::URI(acorn_sat + 'month')

    vars = [:max, :min, :year, :month]
    patterns = [
        [station, subslice, :sliceyear],
        [:sliceyear, subslice, :yearmonth],
        [:yearmonth, acorn_year, :year],
        [:yearmonth, acorn_month, :month],
        [:yearmonth, max_temp, :max],
        [:yearmonth, min_temp, :min]
    ]

    max_result = {}
    min_result = {}
    years = {}
    provider.fetch(vars, patterns).each do |solution|


      year  = id_from_uri(solution[:year]).to_i
      month = id_from_uri(solution[:month]).to_i
      max_result[month] ||= {}
      max_result[month][year] = solution[:max].to_f

      min_result[month] ||= {}
      min_result[month][year] = solution[:min].to_f

      years[year] = 1
    end

    {:maxes => max_result, :mins => min_result, :years => years}
  end

  def self.in_date_range(month, year, start_time, end_time)
    start_month, start_year = start_time.split('-').map { |a| a.to_i }
    end_month, end_year = end_time.split('-').map { |a| a.to_i }
    (year >= start_year) && (year <= end_year) &&
        (year != start_year || month >= start_month) &&
        (year != end_year || month <= end_month)
  end

  def self.store_monthly(month, year, max_result, min_result, monthly_max_stats, monthly_max_means, monthly_min_stats, monthly_min_means, site)
    MonthlyData.create!(
        year: year,
        month: month,
        year_month: year*100 + month,
        high_max_temp: max_result[month][year],
        low_min_temp: min_result[month][year],
        max_highest_since: monthly_max_stats[:highestsince][year],
        max_lowest_since: monthly_max_stats[:lowestsince][year],
        max_ten_max: monthly_max_stats[:rollmax][year],
        max_ten_min: monthly_max_stats[:rollmin][year],
        max_moving_mean: monthly_max_means[year],
        min_highest_since: monthly_min_stats[:highestsince][year],
        min_lowest_since: monthly_min_stats[:lowestsince][year],
        min_ten_max: monthly_min_stats[:rollmax][year],
        min_ten_min: monthly_min_stats[:rollmin][year],
        min_moving_mean: monthly_min_means[year],
        site: site
    )
  end

  def self.monthly_fetch_analyse(provider, sites = nil, start_month=nil, end_month=nil)
    if sites.nil?
      sites = Site.all_as_hash
    end

    sites.each do |site_id, site|
      # Skip if we already have data on this site
      next unless MonthlyData.where(:site => site).empty?

      # Get results from endpoint
      fetched_results = fetch_monthly(provider, site_id)
      max_result = fetched_results[:maxes]
      min_result = fetched_results[:mins]
      years = fetched_results[:years]

      (1..12).each do |month|
        monthly_max_stats = statistics(max_result[month])
        monthly_max_means = moving_mean(max_result[month], YEARS_LOOK_BACK)
        monthly_min_stats = statistics(min_result[month])
        monthly_min_means = moving_mean(min_result[month], YEARS_LOOK_BACK)

        years.keys.each do |year|
          if start_month.nil? || in_date_range(month, year, start_month, end_month)
            store_monthly(month, year, max_result, min_result, monthly_max_stats, monthly_max_means, monthly_min_stats, monthly_min_means, site)
          end
        end


        monthly_max_stats[:highestsince] = nil
        monthly_max_stats[:lowestsince] = nil
        monthly_max_stats[:rollmax] = nil
        monthly_max_stats[:rollmin] = nil
        monthly_max_means = nil
        monthly_min_stats[:highestsince] = nil
        monthly_min_stats[:lowestsince] = nil
        monthly_min_stats[:rollmax] = nil
        monthly_min_stats[:rollmin] = nil
        monthly_min_means = nil

        max_result[month] = nil
        min_result[month] = nil

      end

      max_result = nil
      min_result = nil

      puts "#{site_id} has been completed!"
    end

    return false
  end

  def self.id_from_uri(site_uri)
    site_uri.to_s.split('/').last
  end

  def self.extremity_since(year, years, spaceship_result)
    count_down_year = year
    year_datapoint = years[year]
    extremity_since = nil

    while (extremity_since.nil?) && years.include?(count_down_year-1)
      count_down_year -= 1

      if ((years[count_down_year] <=> year_datapoint) != -spaceship_result)
        extremity_since = count_down_year
        break
      end
    end
    if  extremity_since.nil?
      extremity_since = 'ever'
    end
    extremity_since
  end

  def self.rolling_extremity(year, years, spaceship_result, look_back)
    count_down_year = year
    ten_year_extremity = years[year]

    while (year - count_down_year+1 <= look_back)
      count_down_year -= 1

      if (years.include?(count_down_year) && (years[count_down_year] <=> ten_year_extremity) == spaceship_result)
        ten_year_extremity = years[count_down_year]
      end
    end
    ten_year_extremity
  end

  def self.statistics(years)
    yearsHighestSince = {}
    yearsLowestSince = {}
    yearsRollMax = {}
    yearsRollMin = {}

    years.each do |year, datapoint|
      yearsHighestSince[year] = extremity_since(year, years, SPACESHIP_GREATER)
      yearsLowestSince[year] = extremity_since(year, years, SPACESHIP_LESS)
      yearsRollMax[year] = rolling_extremity(year, years, SPACESHIP_GREATER, YEARS_LOOK_BACK)
      yearsRollMin[year] = rolling_extremity(year, years, SPACESHIP_LESS, YEARS_LOOK_BACK)
    end

    yearsHighestSince.each do |key, datapoint|
      puts "#{key}: #{years[key]}, highest since #{datapoint}, ten year max of #{yearsRollMax[key]}"
    end

    yearsLowestSince.each do |key, datapoint|
      puts "#{key}: #{years[key]}, lowest since #{datapoint}, ten year min of max of #{yearsRollMin[key]}"
    end

    {:highestsince => yearsHighestSince, :lowestsince => yearsLowestSince, :rollmax => yearsRollMax, :rollmin => yearsRollMin}
  end

  def self.moving_mean(years, look_back)

    yearsMovingMean = {}

    years.each do |key, datapoint|
      countdownyear = key
      movingtotal = datapoint
      movingcount = 1

      #puts "#{key} has temp #{datapoint}"

      while years.include?(countdownyear-1) && key-countdownyear+1 <= look_back
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