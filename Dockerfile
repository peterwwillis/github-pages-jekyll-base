ARG RUBYVERSION=2.5.3
FROM ruby:$RUBYVERSION

RUN apt-get update \
  && apt-get install -y \
    git \
    locales \
    make \
    nodejs

COPY Gemfile .

RUN bundle install






RUN mkdir -p /usr/src/app /home/jekyll /_site
WORKDIR /usr/src/app

RUN groupadd -rg 1000 jekyll && \
    useradd -rg jekyll -u 1000 -d /home/jekyll jekyll && \
    chown jekyll:jekyll /home/jekyll /usr/src/app /_site

RUN echo "en_US UTF-8" > /etc/locale.gen && locale-gen en-US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

VOLUME [/usr/src/app]
EXPOSE 4000

USER jekyll

CMD ["jekyll", "serve", "-H", "0.0.0.0", "-P", "4000"]
