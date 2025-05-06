require 'minitest/autorun'
require "dockerize_rails"

module DockerizeRails
  class DockerfileGeneratorTest < Minitest::Test
    def setup
      # You can create a temporary directory for testing the generation of Dockerfile
      @path = Dir.mktmpdir
    end

    def teardown
      # Clean up the temporary directory after tests
      FileUtils.rm_rf(@path)
    end

    def test_generate_dockerfile_for_rails
      # Generate the Dockerfile for a Rails app
      DockerfileGenerator.generate(@path, :rails)

      # Read the generated Dockerfile
      dockerfile = File.read(File.join(@path, 'Dockerfile'))

      # Check that the expected Rails CMD is present
      assert_includes dockerfile, 'CMD ["rails", "s", "-b", "0.0.0.0"]'
      assert_includes dockerfile, 'EXPOSE 3000'
    end

    def test_generate_dockerfile_for_sinatra
      # Generate the Dockerfile for a Sinatra app
      DockerfileGenerator.generate(@path, :sinatra)

      # Read the generated Dockerfile
      dockerfile = File.read(File.join(@path, 'Dockerfile'))

      # Check that the expected Sinatra CMD is present
      assert_includes dockerfile, 'CMD ["ruby", "app.rb"]'
      assert_includes dockerfile, 'EXPOSE 4567'
    end
  end
end
