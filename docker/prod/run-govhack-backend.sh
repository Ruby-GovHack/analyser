#!/bin/bash

su -l docker -c "cd /code; rackup config.ru"
