RubyGovHackers API
============================

The API
-------
```
GET <root>/<version>/<resource>/[<subresource>/]<dataset>?[<vars>]&[<geo params>]&[<time params>] 
```
Where:

* ```<root> = localhost:5556 (locally) or api.rubygovhackers.org (production)                                      ``` 
* ```<version> = V1  ```
* ```<resource> = sites | timeseries  ```
* ```<subresource> = monthly  (daily and yearly to be added)```
* ```<dataset> = acorn-sat  (any geocoded timeseries datasource could be added)```
* ```<vars> = high_max_temp=true (see below; other vars such rainfall, max-temp-std-dev etc to be added) ```
* ```<geo params> = <bounding box> | <site>  ```
* ```<bounding box> = north=<lat>&east=<long>&south=<lat>&west=<long>  ```
* ```<site> = site=<site id>  ```
* ```<time params> = start=<time>&end=<time> | time=<time>  ```
* ```<time> = [[dd-]mm-]yyyy  ```

Available vars:

* ```high_max_temp     ``` : The maximum temperature during the specified month for the specified year.
* ```low_min_temp      ``` : The minimum temperature during the specified month for the specified year.
* ```max_highest_since ``` : The most recent year where the maximum temperature was greater than or equal to the maximum temperature during the specified month during the specified year. For example, June 1994 may have had the highest maximum temperature since June 1972.
* ```max_lowest_since  ``` : The most recent year where the maximum temperature was less than or equal to the maximum temperature during the specified month during the specified year. For example, June 1994 may have had the lowest maximum temperature since June 1972.
* ```max_ten_max       ``` : The highest maximum temperature during this month for the past ten years.
* ```max_ten_min       ``` : The lowest maximum temperature during this month for the past ten years.
* ```max_moving_mean   ``` : The moving mean of the maximum temperatures for this month over the past ten years.
* ```min_highest_since ``` : The most recent year where the minimum temperature was greater than or equal to the minimum temperature during the specified month during the specified year. For example, June 1994 may have had the highest minimum temperature since June 1972.
* ```min_lowest_since  ``` : The most recent year where the minimum temperature was less than or equal to the minimum temperature during the specified month during the specified year. For example, June 1994 may have had the lowest minimum temperature since June 1972.
* ```min_ten_max       ``` : The highest minimum temperature during this month for the past ten years.
* ```min_ten_min       ``` : The lowest minimum temperature during this month for the past ten years.
* ```min_moving_mean   ``` : The moving mean of the minimum temperatures for this month over the past ten years.

The Stack
-------

* [Ruby](http://www.ruby-doc.org/core-2.1.2/)
* [Sinatra](http://www.sinatrarb.com/)
* [RSpec](https://www.relishapp.com/rspec/rspec-core/v/2-99/docs/)
* [Thin](http://code.macournoyer.com/thin/)
* [MongoDB](http://docs.mongodb.org/manual/) with [Mongo](https://rubygems.org/gems/mongo) and [Mongoid](http://mongoid.org/en/mongoid/index.html)

Install
-------

[Install MongoDB](http://docs.mongodb.org/manual/installation/)

Clone the repo  
```
git clone https://github.com/macosgrove/back-end-db-stack
```

Change directory into the project repo  
```
cd backend-db-stack
```

Install gems  
```
bundle install
```


Run
---

Change directory into the project repo  
```
cd backend-db-stack
```

Start the database server  
```
mongod --config /usr/local/etc/mongod.conf
```
Start the Sinatra server  
```
ruby app.rb
```
### Browse to http://localhost:5556/

Rake tasks!
-----------

Seed db data  
```
rake db:seed
```

Drop db data  
```
rake db:drop
```

Run the specs  
```
rake spec
```
