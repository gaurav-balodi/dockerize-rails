# frozen_string_literal: true

require 'yaml'
require 'fileutils'

require 'yaml'
require 'fileutils'

module DockerizeRails
  class DockerComposeGenerator
    def self.generate(path, framework, services)
      services = Array(services).map(&:to_sym)
      compose = {
        'version' => '3',
        'services' => {
          'web' => {
            'build' => '.',
            'volumes' => ['./:/app'],
            'ports' => [framework == :sinatra ? '4567:4567' : '3000:3000'],
            'depends_on' => []
          }
        }
      }

      if services.include?(:postgres)
        compose['services']['db'] = {
          'image' => 'postgres',
          'ports' => ['5432:5432'],
          'environment' => ['POSTGRES_PASSWORD=secret']
        }
        compose['services']['web']['depends_on'] << 'db'
      end

      if services.include?(:mysql)
        compose['services']['db'] = {
          'image' => 'mysql',
          'ports' => ['3306:3306'],
          'environment' => [
            'MYSQL_ROOT_PASSWORD=secret',
            'MYSQL_DATABASE=app_db'
          ]
        }
        compose['services']['web']['depends_on'] << 'db'
      end

      if services.include?(:redis)
        compose['services']['redis'] = {
          'image' => 'redis',
          'ports' => ['6379:6379']
        }
        compose['services']['web']['depends_on'] << 'redis'
      end

      if services.include?(:mongodb)
        compose['services']['mongodb'] = {
          'image' => 'mongo',
          'ports' => ['27017:27017']
        }
        compose['services']['web']['depends_on'] << 'mongodb'
      end

      FileUtils.mkdir_p(path)
      File.write(File.join(path, 'docker-compose.yml'), compose.to_yaml(line_width: -1))  # Ensure correct indentation
    end
  end
end
