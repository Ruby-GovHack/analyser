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
* ```<vars> = max-temp (other vars such as min-temp, rainfall, max-temp-std-dev etc to be added) ```
* ```<geo params> = <bounding box> | <site>  ```
* ```<bounding box> = north=<lat>&east=<long>&south=<lat>&west=<long>  ```
* ```<site> = site-id=<site id>  ```
* ```<time params> = start=<time>&end=<time> | time=<time>  ```
* ```<time> = [[dd-]mm-]yyyy  ```

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
