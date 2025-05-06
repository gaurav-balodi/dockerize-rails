require 'minitest/autorun'
require 'fileutils'
require 'yaml'
require "dockerize_rails"

class DockerComposeGeneratorTest < Minitest::Test
  FIXTURES_PATH = File.expand_path("../fixtures", __FILE__)
  TMP_PATH = File.expand_path("../tmp", __FILE__)

  def setup
    FileUtils.mkdir_p(TMP_PATH)
  end

  def teardown
    FileUtils.rm_rf(Dir[File.join(TMP_PATH, "*")])
  end

  def test_generate_compose_for_rails_with_postgres_and_redis
    path = FileUtils.mkdir_p(File.join(TMP_PATH, "rails_postgres_redis"))
    DockerizeRails::DockerComposeGenerator.generate(path, :rails, [:postgres, :redis])

    data = YAML.load_file(File.join(path, "docker-compose.yml"))

    assert_equal "3", data["version"]
    assert_equal ".", data["services"]["web"]["build"]
    assert_includes data["services"]["web"]["volumes"], "./:/app"
    assert_includes data["services"]["web"]["ports"], "3000:3000"
    assert_equal %w[postgres redis], data["services"]["web"]["depends_on"]

    assert_equal "postgres:15", data["services"]["postgres"]["image"]
    assert_equal "redis:6", data["services"]["redis"]["image"]
  end

  def test_generate_compose_for_rails_with_mongodb
    path = FileUtils.mkdir_p(File.join(TMP_PATH, "rails_mongodb"))
    DockerizeRails::DockerComposeGenerator.generate(path, :rails, [:mongodb])

    data = YAML.load_file(File.join(path, "docker-compose.yml"))

    assert_equal "3", data["version"]
    assert_equal ".", data["services"]["web"]["build"]
    assert_includes data["services"]["web"]["volumes"], "./:/app"
    assert_includes data["services"]["web"]["ports"], "3000:3000"
    assert_equal ["mongodb"], data["services"]["web"]["depends_on"]

    assert_equal "mongo:6", data["services"]["mongodb"]["image"]
  end

  def test_generate_compose_for_sinatra_with_postgres
    path = FileUtils.mkdir_p(File.join(TMP_PATH, "sinatra_postgres"))
    DockerizeRails::DockerComposeGenerator.generate(path, :sinatra, [:postgres])

    data = YAML.load_file(File.join(path, "docker-compose.yml"))

    assert_equal "3", data["version"]
    assert_equal ".", data["services"]["web"]["build"]
    assert_includes data["services"]["web"]["volumes"], "./:/app"
    assert_includes data["services"]["web"]["ports"], "3000:3000"
    assert_equal ["postgres"], data["services"]["web"]["depends_on"]

    assert_equal "postgres:15", data["services"]["postgres"]["image"]
  end

  def test_generate_compose_for_sinatra_with_redis_and_mysql
    path = FileUtils.mkdir_p(File.join(TMP_PATH, "sinatra_redis_mysql"))
    DockerizeRails::DockerComposeGenerator.generate(path, :sinatra, [:redis, :mysql])

    data = YAML.load_file(File.join(path, "docker-compose.yml"))

    assert_equal "3", data["version"]
    assert_equal ".", data["services"]["web"]["build"]
    assert_includes data["services"]["web"]["volumes"], "./:/app"
    assert_includes data["services"]["web"]["ports"], "3000:3000"
    assert_equal %w[redis mysql], data["services"]["web"]["depends_on"]

    assert_equal "redis:6", data["services"]["redis"]["image"]
    assert_equal "mysql:8", data["services"]["mysql"]["image"]
  end

  def test_generate_compose_for_sinatra_with_all_services
    path = FileUtils.mkdir_p(File.join(TMP_PATH, "sinatra_all"))
    DockerizeRails::DockerComposeGenerator.generate(path, :sinatra, [:postgres, :redis, :mysql, :mongodb])

    data = YAML.load_file(File.join(path, "docker-compose.yml"))

    assert_equal "3", data["version"]
    assert_equal ".", data["services"]["web"]["build"]
    assert_includes data["services"]["web"]["volumes"], "./:/app"
    assert_includes data["services"]["web"]["ports"], "3000:3000"
    assert_equal %w[postgres redis mysql mongodb], data["services"]["web"]["depends_on"]

    assert data["services"].key?("postgres")
    assert data["services"].key?("redis")
    assert data["services"].key?("mysql")
    assert data["services"].key?("mongodb")
  end
end
