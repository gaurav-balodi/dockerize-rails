require 'minitest/autorun'
require 'fileutils'
require 'yaml'
require "dockerize_rails"


class DockerizeRails::DockerComposeGeneratorTest < Minitest::Test
  def setup
    @test_path = File.join(Dir.pwd, 'test_docker_compose')
    FileUtils.rm_rf(@test_path)
  end

  def teardown
    FileUtils.rm_rf(@test_path)
  end

  def test_generate_docker_compose_for_rails_with_postgres_and_redis
    DockerizeRails::DockerComposeGenerator.generate(@test_path, :rails, [:postgres, :redis])

    expected = {
      'version' => '3',
      'services' => {
        'web' => {
          'build' => '.',
          'volumes' => ['./:/app'],
          'ports' => ['3000:3000'],
          'depends_on' => ['db', 'redis']
        },
        'db' => {
          'image' => 'postgres',
          'ports' => ['5432:5432'],
          'environment' => ['POSTGRES_PASSWORD=secret']
        },
        'redis' => {
          'image' => 'redis',
          'ports' => ['6379:6379']
        }
      }
    }

    actual = YAML.load_file(File.join(@test_path, 'docker-compose.yml'))
    assert_equal expected, actual
  end

  def test_generate_docker_compose_for_rails_with_postgres
    DockerizeRails::DockerComposeGenerator.generate(@test_path, :rails, [:postgres])

    expected = {
      'version' => '3',
      'services' => {
        'web' => {
          'build' => '.',
          'volumes' => ['./:/app'],
          'ports' => ['3000:3000'],
          'depends_on' => ['db']
        },
        'db' => {
          'image' => 'postgres',
          'ports' => ['5432:5432'],
          'environment' => ['POSTGRES_PASSWORD=secret']
        }
      }
    }

    actual = YAML.load_file(File.join(@test_path, 'docker-compose.yml'))
    assert_equal expected, actual
  end

  def test_generate_docker_compose_for_sinatra_with_mysql_and_redis
    DockerizeRails::DockerComposeGenerator.generate(@test_path, :sinatra, [:mysql, :redis])

    expected = {
      'version' => '3',
      'services' => {
        'web' => {
          'build' => '.',
          'volumes' => ['./:/app'],
          'ports' => ['4567:4567'],
          'depends_on' => ['db', 'redis']
        },
        'db' => {
          'image' => 'mysql',
          'ports' => ['3306:3306'],
          'environment' => [
            'MYSQL_ROOT_PASSWORD=secret',
            'MYSQL_DATABASE=app_db'
          ]
        },
        'redis' => {
          'image' => 'redis',
          'ports' => ['6379:6379']
        }
      }
    }

    actual = YAML.load_file(File.join(@test_path, 'docker-compose.yml'))
    assert_equal expected, actual
  end

  def test_generate_docker_compose_for_sinatra_with_mongodb
    DockerizeRails::DockerComposeGenerator.generate(@test_path, :sinatra, [:mongodb])

    expected = {
      'version' => '3',
      'services' => {
        'web' => {
          'build' => '.',
          'volumes' => ['./:/app'],
          'ports' => ['4567:4567'],
          'depends_on' => ['mongodb']
        },
        'mongodb' => {
          'image' => 'mongo',
          'ports' => ['27017:27017']
        }
      }
    }

    actual = YAML.load_file(File.join(@test_path, 'docker-compose.yml'))
    assert_equal expected, actual
  end
end
