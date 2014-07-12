#!/bin/bash

su -l docker -c "cd /code; rake db:seed; rackup config.ru"
