ARG RUBYVERSION=2.5.3
FROM ruby:$RUBYVERSION

RUN apt-get update \
  && apt-get install -y \
    git \
    locales \
    make \
    nodejs

RUN gem install --no-document github-pages

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN \
  echo "en_US UTF-8" > /etc/locale.gen && \
  locale-gen en-US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

VOLUME [/usr/src/app]
EXPOSE 4000

CMD ["jekyll", "serve", "-H", "0.0.0.0", "-P", "4000"]
