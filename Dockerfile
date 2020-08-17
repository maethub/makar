FROM ruby:2.5.1

RUN apt-get update -qq && apt-get install -y build-essential vim

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for a JS runtime
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install -j3

ADD package*.json $APP_HOME/
RUN npm install

EXPOSE 3000

CMD rails server -p 3000