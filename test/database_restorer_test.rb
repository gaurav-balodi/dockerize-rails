# frozen_string_literal: true

require "minitest/autorun"
require "dockerize_rails/database_restorer"
require "fileutils"

module DockerizeRails
  class DatabaseRestorerTest < Minitest::Test
    def setup
      @project_path = "test/tmp/test_project_restore"
      FileUtils.mkdir_p(@project_path)
      @restore_file = File.join(@project_path, "backup.sql")
      File.write(@restore_file, "-- Dummy SQL dump")
    end

    def teardown
      FileUtils.rm_rf(@project_path)
    end

    def test_restore_from_valid_file
      config = {
        adapter: "postgresql",
        database: "my_app_restore",
        username: "postgres",
        password: "",
        host: "localhost"
      }

      DockerizeRails::DatabaseRestorer.stub(:system, true) do
        assert_output(/Restoring database 'my_app_restore'/) do
          DockerizeRails::DatabaseRestorer.restore(@restore_file, config)
        end
      end
    end

    def test_restore_command_fails
      config = {
        adapter: "postgresql",
        database: "my_app_restore",
        username: "postgres",
        password: "",
        host: "localhost"
      }

      DockerizeRails::DatabaseRestorer.stub(:system, false) do
        assert_output(/❌ Failed to restore database from '.*backup\.sql'/) do
          DockerizeRails::DatabaseRestorer.restore(@restore_file, config)
        end
      end
    end

    def test_restore_file_missing
      missing_file = File.join(@project_path, "missing.sql")
      config = {
        adapter: "postgresql",
        database: "db",
        username: "u",
        password: "p",
        host: "localhost"
      }

      error = assert_raises(RuntimeError) do
        DockerizeRails::DatabaseRestorer.restore(missing_file, config)
      end

      assert_match(/Dump file .* does not exist/, error.message)
    end
  end
end
