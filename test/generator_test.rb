# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'stringio'
require "dockerize_rails"

module DockerizeRails
  class GeneratorTest < Minitest::Test
    def setup
      @test_dir = "tmp_generator_test"
      FileUtils.mkdir_p(@test_dir)

      # Create a fake Gemfile.lock for detecting services
      File.write(File.join(@test_dir, "Gemfile.lock"), <<~LOCK)
        GEM
          specs:
            pg (1.2.3)
            redis (4.2.5)
      LOCK
    end

    def teardown
      FileUtils.rm_rf(@test_dir)
    end

    def test_generator_with_explicit_services
      out = capture_stdout do
        generator = Generator.new(
          path: @test_dir,
          framework: :rails,
          use: ["postgres", "redis"]
        )
        generator.run
      end

      assert_includes out, "✔ Detected framework: rails"
      assert_includes out, "✔ Services: postgres, redis"
      assert File.exist?(File.join(@test_dir, "Dockerfile"))
      assert File.exist?(File.join(@test_dir, "docker-compose.yml"))
    end

    private

    def capture_stdout
      original_stdout = $stdout
      $stdout = StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = original_stdout
    end
  end
end
