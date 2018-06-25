FROM ruby:2.3.1
MAINTAINER MIC Labs

#RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# for a JS runtime
#RUN apt-get install -y nodejs

# install npm
#RUN apt-get install -y npm
#RUN cp /usr/bin/nodejs /usr/bin/node

COPY Gemfile* /tmp/
COPY engines /tmp/engines

WORKDIR /tmp
RUN bundle install

ENV DIR /var/www

RUN mkdir $DIR
WORKDIR $DIR
ADD . $DIR

ENV BUNDLE_GEMFILE=$DIR/Gemfile \
BUNDLE_JOBS=2 \
BUNDLE_PATH=/bundle
