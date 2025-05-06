# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'stringio'
require "dockerize_rails"

require "test_helper"

class GeneratorTest < Minitest::Test
  def setup
    @tmp_path = File.expand_path("../tmp_generator_test", __dir__)
    FileUtils.rm_rf(@tmp_path)
    FileUtils.mkdir_p(@tmp_path)
  end

  def test_generator_with_explicit_framework_and_services
    fake_analyzer = Minitest::Mock.new
    fake_analyzer.expect(:detect_framework, :rails)
    fake_analyzer.expect(:detect_services, [:postgres])

    DockerizeRails::DependencyAnalyzer.stub :new, fake_analyzer do
      DockerizeRails::DockerfileGenerator.stub :generate, true do
        DockerizeRails::DockerComposeGenerator.stub :generate, true do
          DockerizeRails::DatabaseCreator.stub :create, true do
            generator = DockerizeRails::Generator.new(
              path: @tmp_path,
              framework: :sinatra,
              use: [:redis]
            )

            simulate_stdin("y\n") do
              output = capture_output { generator.run }
              assert_includes output, "✔ Detected framework: sinatra"
              assert_includes output, "✔ Services: redis"
              assert_includes output, "✔ Database not provided. Do you want to create a new database?"
              assert_includes output, "✔ Docker setup generated successfully."
            end
          end
        end
      end
    end
  end

  def test_generator_with_restore_file
    fake_analyzer = Minitest::Mock.new
    fake_analyzer.expect(:detect_framework, :rails)
    fake_analyzer.expect(:detect_services, [:postgres])

    DockerizeRails::DependencyAnalyzer.stub :new, fake_analyzer do
      DockerizeRails::DockerfileGenerator.stub :generate, true do
        DockerizeRails::DockerComposeGenerator.stub :generate, true do
          DockerizeRails::DatabaseRestorer.stub :restore, true do
            generator = DockerizeRails::Generator.new(
              path: @tmp_path,
              restore: "db/dump.sql"
            )
            output = capture_output { generator.run }
            assert_includes output, "✔ Restoring database from dump file 'db/dump.sql'..."
          end
        end
      end
    end
  end

  def test_generator_skips_database_creation
    fake_analyzer = Minitest::Mock.new
    fake_analyzer.expect(:detect_framework, :rails)
    fake_analyzer.expect(:detect_services, [:postgres])

    DockerizeRails::DependencyAnalyzer.stub :new, fake_analyzer do
      DockerizeRails::DockerfileGenerator.stub :generate, true do
        DockerizeRails::DockerComposeGenerator.stub :generate, true do
          generator = DockerizeRails::Generator.new(path: @tmp_path)

          simulate_stdin("n\n") do
            output = capture_output { generator.run }
            assert_includes output, "✔ Skipping database creation."
          end
        end
      end
    end
  end

  private

  def simulate_stdin(*inputs)
    io = StringIO.new
    io.puts(inputs.flatten)
    io.rewind
    $stdin = io
    yield
  ensure
    $stdin = STDIN
  end

  def capture_output
    out = StringIO.new
    $stdout = out
    yield
    out.string
  ensure
    $stdout = STDOUT
  end
end
