# frozen_string_literal: true

module DockerizeRails
  class DockerfileGenerator
    def self.generate(path, framework)
      dockerfile = []
      dockerfile << "FROM ruby:3.2"
      dockerfile << "RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs"
      dockerfile << "WORKDIR /app"
      dockerfile << "COPY . ."
      dockerfile << "RUN bundle install"
      
      port = framework == :rails ? 3000 : 4567
      dockerfile << "EXPOSE #{port}"

      cmd = if framework == :rails
              ['rails', 's', '-b', '0.0.0.0']
            else
              ['ruby', 'app.rb']
            end
      dockerfile << "CMD [#{cmd.map { |c| "\"#{c}\"" }.join(', ')}]"

      File.write(File.join(path, "Dockerfile"), dockerfile.join("\n"))
    end
  end
end
