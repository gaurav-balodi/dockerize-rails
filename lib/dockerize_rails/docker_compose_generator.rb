# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module DockerizeRails
  class DockerComposeGenerator
    def self.generate(path, framework, services = [])
      compose = {
        "version" => "3",
        "services" => {}
      }

      web_service = {
        "build" => ".",
        "volumes" => ["./:/app", "/app/tmp/pids"],
        "ports" => ["3000:3000"]
      }

      depends_on = []

      services = services.map(&:to_s)

      if services.include?("postgres")
        compose["services"]["postgres"] = {
          "image" => "postgres:14",
          "ports" => ["5432:5432"],
          "environment" => {
            "POSTGRES_USER" => "user",
            "POSTGRES_PASSWORD" => "password",
            "POSTGRES_DB" => "app_development"
          },
          "volumes" => ["pgdata:/var/lib/postgresql/data"],
          "healthcheck" => {
            "test" => ["CMD-SHELL", "pg_isready -U user"],
            "interval" => "10s",
            "timeout" => "5s",
            "retries" => 5
          }
        }
        depends_on << "postgres"
      end

      if services.include?("redis")
        compose["services"]["redis"] = {
          "image" => "redis:6",
          "ports" => ["6379:6379"]
        }
        depends_on << "redis"
      end

      if services.include?("mysql")
        compose["services"]["mysql"] = {
          "image" => "mysql:8",
          "ports" => ["3306:3306"],
          "environment" => {
            "MYSQL_ROOT_PASSWORD" => "secret",
            "MYSQL_DATABASE" => "app_db"
          }
        }
        depends_on << "mysql"
      end

      if services.include?("mongodb")
        compose["services"]["mongodb"] = {
          "image" => "mongo:6",
          "ports" => ["27017:27017"]
        }
        depends_on << "mongodb"
      end

      web_service["depends_on"] = depends_on unless depends_on.empty?
      compose["services"]["web"] = web_service

      # Declare named volumes if Postgres is used
      if services.include?("postgres")
        compose["volumes"] = {
          "pgdata" => {}
        }
      end

      File.write(File.join(path, "docker-compose.yml"), compose.to_yaml)
    end
  end
end
