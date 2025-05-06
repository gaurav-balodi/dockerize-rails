# frozen_string_literal: true

require "minitest/autorun"
# require "dockerize_rails/database_creator"
# require "fileutils"

require "test_helper"

module DockerizeRails
  class DatabaseCreatorTest < Minitest::Test
    def setup
      @path = "test/tmp/test_project"
      @db_name = "my_database"
      FileUtils.mkdir_p(File.join(@path, "config"))
      File.write(File.join(@path, "config", "database.yml"), { "development" => { "database" => @db_name } }.to_yaml)
    end

    def teardown
      FileUtils.rm_rf(@path)
    end

    def test_create_database_success
      DatabaseCreator.stub(:system, true) do
        output = capture_io do
          DatabaseCreator.create(@path, @db_name)
        end.first

        assert_match(/Creating database 'my_database'/, output)
        assert_match(/created successfully/, output)
      end
    end

    def test_create_database_failure
      DatabaseCreator.stub(:system, false) do
        output = capture_io do
          DatabaseCreator.create(@path, @db_name)
        end.first

        assert_match(/Creating database 'my_database'/, output)
        assert_match(/Failed to create database/, output)
      end
    end

    def test_parse_database_yml
      result = DatabaseCreator.parse_database_yml(@path)
      assert_equal "my_database", result["development"]["database"]
    end

    def test_parse_database_yml_raises_error_if_missing
      FileUtils.rm_rf(File.join(@path, "config", "database.yml"))
      assert_raises(RuntimeError) { DatabaseCreator.parse_database_yml(@path) }
    end
  end
end
