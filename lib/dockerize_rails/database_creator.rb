# frozen_string_literal: true

module DockerizeRails
  class DatabaseCreator
    def self.create(path, db_name)
      puts "✔ Creating database '#{db_name}' inside Docker container..."

      container_name = "app"  # Assuming the container is named 'app', adjust if needed
      command = "docker compose exec #{container_name} bash -c 'rails db:create'"

      result = system(command)
      
      if result
        puts "✔ Database '#{db_name}' created successfully."
      else
        puts "❌ Failed to create database '#{db_name}'. Please check the logs for errors."
      end
    end

    def self.parse_database_yml(path)
      yml_path = File.join(path, 'config', 'database.yml')
      raise 'database.yml not found' unless File.exist?(yml_path)

      yaml_content = YAML.load_file(yml_path)
      yaml_content
    end
  end
end
