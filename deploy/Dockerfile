# https://github.com/phusion/baseimage-docker
FROM phusion/baseimage:0.9.10

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

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
RUN curl -sSL https://get.rvm.io | bash -s stable

# Install Ruby (includes Bundler)
RUN bash -l -c "rvm requirements"
ADD code/.ruby-version /tmp/.ruby-version
RUN bash -l -c "rvm install $(cat /tmp/.ruby-version)"
RUN rm -f /tmp/.ruby-version

# Install ruby dependencies using Bundler.
RUN mkdir /tmp/bundle
ADD code/Gemfile /tmp/bundle/Gemfile
ADD code/Gemfile.lock /tmp/bundle/Gemfile.lock
RUN bash -l -c "cd /tmp/bundle; bundle install --system"
RUN rm -rf /tmp/bundle

# Clean up some uneeded files.
RUN DEBIAN_FRONTEND=noninteractive apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/tmp/*
RUN rm -rf /tmp/*

# Create user docker so we don't have to run everything as root.
RUN useradd -d /home/docker -m -s /bin/bash docker

# cd into /code on login by docker
RUN echo "cd /code" >> /home/docker/.bashrc

# Run MongoDB on start
ADD run-mongodb.sh /etc/service/mongodb/run

# Code volume should be mounted here.
VOLUME /code

# The port we host on.
EXPOSE 5555

# Use baseimage-docker's init system so CMD doesn't have PID 1.
# https://github.com/phusion/baseimage-docker#running-a-one-shot-command-in-the-container
ENTRYPOINT ["/sbin/my_init", "--quiet", "--"]

# Open shell as user docker by defualt.
CMD ["su", "--login", "docker"]
