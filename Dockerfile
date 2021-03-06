# Installs IPython from the current branch
# Another Docker container should build from this one to get services like the notebook

FROM ubuntu:14.04

MAINTAINER IPython Project <ipython-dev@scipy.org>

ENV DEBIAN_FRONTEND noninteractive

# Make sure apt is up to date
RUN apt-get update
RUN apt-get upgrade -y

# Not essential, but wise to set the lang
# Note: Users with other languages should set this in their derivative image
RUN apt-get install -y language-pack-en
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Python binary dependencies, developer tools
RUN apt-get install -y -q build-essential make gcc zlib1g-dev git && \
    apt-get install -y -q python python-dev python-pip python3-dev python3-pip && \
    apt-get install -y -q libzmq3-dev sqlite3 libsqlite3-dev pandoc libcurl4-openssl-dev nodejs nodejs-legacy npm

# In order to build from source, need less
RUN npm install -g less

RUN apt-get install -y -q fabric python-sphinx python3-sphinx

RUN mkdir -p /srv/
WORKDIR /srv/
ADD . /srv/ipython
WORKDIR /srv/ipython/
RUN chmod -R +rX /srv/ipython

# .[all] only works with -e, so use file://path#egg
# Can't use -e because ipython2 and ipython3 will clobber each other
RUN pip2 install file:///srv/ipython#egg=ipython[all]
RUN pip3 install file:///srv/ipython#egg=ipython[all]

# install kernels
RUN python2 -m IPython kernelspec install-self --system
RUN python3 -m IPython kernelspec install-self --system

WORKDIR /tmp/

RUN iptest2
RUN iptest3
