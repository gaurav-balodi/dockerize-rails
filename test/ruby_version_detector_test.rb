# frozen_string_literal: true

require "fileutils"
require 'minitest/autorun'
require "dockerize_rails"

class RubyVersionDetectorTest < Minitest::Test
  def setup
    @gemfile_path = "Gemfile"
  end

  def teardown
    File.delete(@gemfile_path) if File.exist?(@gemfile_path)
  end

  def test_detects_ruby_version_with_patch
    File.write(@gemfile_path, <<~GEMFILE)
      source 'https://rubygems.org'
      ruby '3.2.1'
    GEMFILE

    version = DockerizeRails::RubyVersionDetector.detect(@gemfile_path)
    assert_equal "3.2.1", version
  end

  def test_detects_ruby_version_without_patch
    File.write(@gemfile_path, <<~GEMFILE)
      ruby "2.7"
      gem 'rails'
    GEMFILE

    version = DockerizeRails::RubyVersionDetector.detect(@gemfile_path)
    assert_equal "2.7", version
  end

  def test_returns_nil_if_ruby_not_specified
    File.write(@gemfile_path, <<~GEMFILE)
      source 'https://rubygems.org'
      gem 'rails'
    GEMFILE

    version = DockerizeRails::RubyVersionDetector.detect(@gemfile_path)
    assert_nil version
  end

  def test_returns_nil_if_file_does_not_exist
    File.delete(@gemfile_path) if File.exist?(@gemfile_path)

    version = DockerizeRails::RubyVersionDetector.detect(@gemfile_path)
    assert_nil version
  end
end
