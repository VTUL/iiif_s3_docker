FROM ruby:2.5

RUN mkdir /usr/local/iiif

WORKDIR /usr/local/iiif

RUN gem install iiif_s3

RUN apt-get install imagemagick

COPY . .
