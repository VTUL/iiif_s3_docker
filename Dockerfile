FROM ruby:2.6
LABEL authors="Yinlin Chen <ylchen@vt.edu>, Lee Hunter <whunter@vt.edu>"
WORKDIR /usr/local/iiif
RUN apt-get update && apt-get install -y imagemagick awscli vim && rm -rf /var/lib/apt/lists/*
RUN gem install --no-user-install --no-document --verbose iiif_s3 -v 0.1.5 -s "https://whunter:<gh pat (just generate a new one)>@rubygems.pkg.github.com/vt-digital-libraries-platform"
COPY policy.xml /etc/ImageMagick-6/policy.xml
COPY . .

CMD ["/usr/local/iiif/createiiif.sh"]

