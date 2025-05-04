require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/dockerize_rails/docker_compose_generator'

class DockerComposeGeneratorTest < Minitest::Test
  def setup
    @test_path = 'tmp/test_app'
    FileUtils.mkdir_p(@test_path)
  end

  def teardown
    FileUtils.rm_rf(@test_path)
  end

  def test_generates_compose_with_all_services
    DockerizeRails::DockerComposeGenerator.generate(@test_path, :sinatra, ['mysql', 'mongodb', 'redis'])
    content = File.read(File.join(@test_path, 'docker-compose.yml'))
    assert_includes content, 'mysql:8'
    assert_includes content, 'mongo:6'
    assert_includes content, 'redis:6'
  end
end
