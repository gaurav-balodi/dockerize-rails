# frozen_string_literal: true

require_relative 'dependency_analyzer'
require_relative 'dockerfile_generator'
require_relative 'docker_compose_generator'

module DockerizeRails
  class Generator
    def initialize(path:, framework: nil, use: [], restore: nil)
      @path = path
      @framework = framework
      @explicit_services = use
      @restore_file = restore
    end

    def run
      analyzer = DependencyAnalyzer.new(@path)
      framework = @framework || analyzer.detect_framework
      services = @explicit_services.any? ? @explicit_services : analyzer.detect_services

      puts "✔ Detected framework: #{framework}"
      puts "✔ Services: #{services.join(', ')}"

      DockerfileGenerator.generate(@path, framework)
      DockerComposeGenerator.generate(@path, framework, services)

      puts "✔ Docker setup generated successfully."
      puts "✔ To build: docker-compose up --build"
    end
  end
end
