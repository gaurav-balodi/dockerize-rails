# frozen_string_literal: true

require "minitest/autorun"
require "fileutils"
require_relative "../lib/dockerize_rails/dependency_analyzer"

class DockerizeRails::DependencyAnalyzerTest < Minitest::Test
  def setup
    @test_dir = "test/tmp_app"
    FileUtils.mkdir_p(@test_dir)
  end

  def teardown
    FileUtils.rm_rf(@test_dir)
  end

  def write_file(file, content)
    FileUtils.mkdir_p(File.dirname(File.join(@test_dir, file)))
    File.write(File.join(@test_dir, file), content)
  end

  def test_detect_framework_for_rails
    write_file("config/application.rb", "# Rails app marker")
    analyzer = DockerizeRails::DependencyAnalyzer.new(@test_dir)
    assert_equal :rails, analyzer.detect_framework
  end

  def test_detect_framework_for_sinatra
    write_file("Gemfile", "gem 'sinatra'")
    analyzer = DockerizeRails::DependencyAnalyzer.new(@test_dir)
    assert_equal :sinatra, analyzer.detect_framework
  end

  def test_detect_framework_unknown
    write_file("Gemfile", "gem 'something_else'")
    analyzer = DockerizeRails::DependencyAnalyzer.new(@test_dir)
    assert_equal :unknown, analyzer.detect_framework
  end

  def test_detect_services
    content = <<~LOCK
      GEM
        remote: https://rubygems.org/
        specs:
          pg (1.2.3)
          mysql2 (0.5.3)
          mongo (2.14.0)
          redis (4.2.5)

      PLATFORMS
        ruby

      DEPENDENCIES
        pg
        mysql2
        mongo
        redis
    LOCK

    write_file("Gemfile.lock", content)
    analyzer = DockerizeRails::DependencyAnalyzer.new(@test_dir)
    services = analyzer.detect_services
    assert_includes services, "postgres"
    assert_includes services, "mysql"
    assert_includes services, "mongodb"
    assert_includes services, "redis"
  end

  def test_ruby_version_detection
    write_file("Gemfile", <<~GEMFILE)
      source "https://rubygems.org"
      ruby "3.2.1"
      gem "rails"
    GEMFILE

    analyzer = DockerizeRails::DependencyAnalyzer.new(@test_dir)
    assert_equal "3.2.1", analyzer.ruby_version
  end

  def test_ruby_version_absent
    write_file("Gemfile", <<~GEMFILE)
      source "https://rubygems.org"
      gem "rails"
    GEMFILE

    analyzer = DockerizeRails::DependencyAnalyzer.new(@test_dir)
    assert_nil analyzer.ruby_version
  end
end
