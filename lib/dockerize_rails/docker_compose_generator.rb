# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module DockerizeRails
  class DockerComposeGenerator
    def self.generate(path, framework, services = [])
      compose = {
        "version" => "3",
        "services" => {
          "web" => {
            "build" => ".",
            "volumes" => ["./:/app"],
            "ports" => ["3000:3000"],
            "depends_on" => []
          }
        }
      }

      if services.include?(:postgres)
        compose["services"]["postgres"] = {
          "image" => "postgres:15",
          "ports" => ["5432:5432"],
          "environment" => {
            "POSTGRES_USER" => "user",
            "POSTGRES_PASSWORD" => "password"
          }
        }
        compose["services"]["web"]["depends_on"] << "postgres"
      end

      if services.include?(:redis)
        compose["services"]["redis"] = {
          "image" => "redis:6",
          "ports" => ["6379:6379"]
        }
        compose["services"]["web"]["depends_on"] << "redis"
      end

      if services.include?(:mysql)
        compose["services"]["mysql"] = {
          "image" => "mysql:8",
          "ports" => ["3306:3306"],
          "environment" => {
            "MYSQL_ROOT_PASSWORD" => "secret",
            "MYSQL_DATABASE" => "app_db"
          }
        }
        compose["services"]["web"]["depends_on"] << "mysql"
      end

      if services.include?(:mongodb)
        compose["services"]["mongodb"] = {
          "image" => "mongo:6",
          "ports" => ["27017:27017"]
        }
        compose["services"]["web"]["depends_on"] << "mongodb"
      end

      File.write(File.join(path, "docker-compose.yml"), compose.to_yaml)
    end
  end
end
