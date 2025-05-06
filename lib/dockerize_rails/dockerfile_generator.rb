# frozen_string_literal: true

require 'fileutils'
require_relative 'ruby_version_detector'

module DockerizeRails
  class DockerfileGenerator
    def self.generate(path, framework)
      gemfile_path = File.join(path, 'Gemfile')
      ruby_version = DockerizeRails::RubyVersionDetector.detect(gemfile_path) || '3.2'

      dockerfile_content = <<~DOCKERFILE
        FROM ruby:#{ruby_version}
        RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
        WORKDIR /app
        COPY . .
        RUN bundle install
      DOCKERFILE

      if framework == :rails
        dockerfile_content += <<~RAILS
          EXPOSE 3000
          CMD ["rails", "s", "-b", "0.0.0.0"]
        RAILS
      elsif framework == :sinatra
        dockerfile_content += <<~SINATRA
          EXPOSE 4567
          CMD ["ruby", "app.rb", "-b", "0.0.0.0"]
        SINATRA
      end

      File.write(File.join(path, 'Dockerfile'), dockerfile_content)
    end
  end
end

