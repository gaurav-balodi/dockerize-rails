# frozen_string_literal: true

require_relative 'dependency_analyzer'
require_relative 'dockerfile_generator'
require_relative 'docker_compose_generator'
require_relative 'database_creator'
require_relative 'database_restorer'

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

      # Ask user about restoring or creating database
      db_name = get_database_name

      if @restore_file
        puts "✔ Restoring database from dump file '#{@restore_file}'..."
        DatabaseRestorer.restore(@path, @restore_file)
      else
        puts "✔ Database not provided. Do you want to create a new database?"
        create_new_db = ask_yes_or_no("Would you like to create a new database?")
        if create_new_db
          DatabaseCreator.create(@path, db_name)
        else
          puts "✔ Skipping database creation."
        end
      end

      puts "✔ Docker setup generated successfully."
      puts "✔ To build: docker compose up --build"
    end

    private

    def ask_yes_or_no(question)
      print "#{question} (y/n): "
      response = gets.chomp.downcase
      response == 'y'
    end

    def get_database_name
      # This method assumes that the database name can be fetched from config/database.yml
      # For simplicity, we'll return a default name for now
      "default_db"
    end
  end
end
