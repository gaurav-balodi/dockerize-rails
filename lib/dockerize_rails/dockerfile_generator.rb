# frozen_string_literal: true

require 'fileutils'
require_relative 'ruby_version_detector'

module DockerizeRails
  class DockerfileGenerator
    def self.generate(path, framework)
      gemfile_path = File.join(path, 'Gemfile')
      ruby_version = DockerizeRails::RubyVersionDetector.detect(gemfile_path) || '3.2'

      # Collect local bundle configs using `bundle config --parseable`
      bundle_config_cmds = []
      begin
        output = `bundle config --parseable`
        if $?.success?
          output.lines.each do |line|
            key, value = line.strip.split('=', 2)
            next if key.nil? || value.nil?
            key = key.sub(/^BUNDLE_/, '').downcase
            bundle_config_cmds << "RUN bundle config set #{key} #{value}"
          end
        end
      rescue => e
        puts "DockerfileGenerator Invalid bundle config: #{e.message}"
        # Fail gracefully: skip bundle config if anything goes wrong
        bundle_config_cmds = []
      end

      dockerfile_content = <<~DOCKERFILE
        FROM ruby:#{ruby_version}
        RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
        WORKDIR /app
        COPY . .
        #{'COPY .env .env' if File.exist?(File.join(path, '.env'))}
        #{bundle_config_cmds.join("\n")}
        COPY entrypoint.sh /usr/bin/entrypoint.sh
        RUN chmod +x /usr/bin/entrypoint.sh
        ENTRYPOINT ["entrypoint.sh"]
        RUN bundle install
      DOCKERFILE

      if framework == :rails
        dockerfile_content += <<~RAILS
          EXPOSE 3000
          CMD rm -f /app/tmp/pids/server.pid
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
