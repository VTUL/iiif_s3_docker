FROM ruby:2.5
LABEL maintainer="Yinlin Chen <ylchen@vt.edu>"

WORKDIR /usr/local/iiif

RUN apt-get update && apt-get install -y imagemagick
RUN gem install --no-user-install --no-document iiif_s3

COPY policy.xml /etc/ImageMagick-6/policy.xml
COPY . .

ENTRYPOINT ["./createiiif.sh"]
