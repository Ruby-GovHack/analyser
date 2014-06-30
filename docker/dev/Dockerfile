# https://github.com/phusion/baseimage-docker
FROM phusion/baseimage:0.9.10

# Create user docker so we don't have to run everything as root.
RUN useradd -d /home/docker -m -s /bin/bash docker

# Install dependencies.
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates

# Install MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org

# Install RVM
RUN su -l docker -c "curl -sSL https://get.rvm.io | bash -s stable"
RUN bash -l -c "/home/docker/.rvm/bin/rvm requirements"

# Install Ruby (includes Bundler)
ADD ./code/.ruby-version /tmp/.ruby-version
RUN su -l docker -c "rvm install $(cat /tmp/.ruby-version)"

# Install ruby dependencies using Bundler.
RUN mkdir /tmp/bundle
ADD ./code/Gemfile /tmp/bundle/Gemfile
ADD ./code/Gemfile.lock /tmp/bundle/Gemfile.lock
RUN su -l docker -c "cd /tmp/bundle; bundle install"

# Clean up some uneeded files.
RUN DEBIAN_FRONTEND=noninteractive apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/tmp/*
RUN rm -rf /tmp/*

# cd into /code on login by docker
RUN echo "cd /code" >> /home/docker/.bashrc

# Run MongoDB on start
ADD ./docker/run-mongodb.sh /etc/service/mongodb/run

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Code volume should be mounted here.
VOLUME /code

# The port we host on.
EXPOSE 5556

# Use baseimage-docker's init system so CMD doesn't have PID 1.
# https://github.com/phusion/baseimage-docker#running-a-one-shot-command-in-the-container
ENTRYPOINT ["/sbin/my_init", "--quiet", "--"]

# Open shell as user docker by defualt.
CMD ["su", "--login", "docker"]

