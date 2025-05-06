require 'minitest/autorun'
require "dockerize_rails"

class DockerfileGeneratorTest < Minitest::Test
  def setup
    @tmp_dir = File.expand_path('../tmp_dockerfile_test', __dir__)
    FileUtils.rm_rf(@tmp_dir)
    FileUtils.mkdir_p(@tmp_dir)
  end

  def test_generate_dockerfile_for_rails
    DockerizeRails::DockerfileGenerator.generate(@tmp_dir, :rails)
    content = File.read(File.join(@tmp_dir, 'Dockerfile'))

    assert_includes content, 'FROM ruby:3.2'
    assert_includes content, 'EXPOSE 3000'
    assert_includes content, 'CMD ["rails", "s", "-b", "0.0.0.0"]'
  end

  def test_generate_dockerfile_for_sinatra
    DockerizeRails::DockerfileGenerator.generate(@tmp_dir, :sinatra)
    content = File.read(File.join(@tmp_dir, 'Dockerfile'))

    assert_includes content, "FROM ruby:3.2"
    assert_includes content, "apt-get install -y build-essential libpq-dev nodejs"
    assert_includes content, "WORKDIR /app"
    assert_includes content, "COPY . ."
    assert_includes content, "RUN bundle install"
    assert_includes content, "EXPOSE 4567"
    assert_includes content, 'CMD ["ruby", "app.rb", "-b", "0.0.0.0"]'
  end

  def test_generate_dockerfile_uses_ruby_version_from_gemfile
    gemfile_content = <<~GEMFILE
      source 'https://rubygems.org'
      ruby '3.1.4'
      gem 'rails'
    GEMFILE
    File.write(File.join(@tmp_dir, 'Gemfile'), gemfile_content)

    DockerizeRails::DockerfileGenerator.generate(@tmp_dir, :rails)
    content = File.read(File.join(@tmp_dir, 'Dockerfile'))

    assert_includes content, 'FROM ruby:3.1.4'
  end

  def test_generate_dockerfile_falls_back_to_default_if_no_ruby_version
    gemfile_content = <<~GEMFILE
      source 'https://rubygems.org'
      gem 'rails'
    GEMFILE
    File.write(File.join(@tmp_dir, 'Gemfile'), gemfile_content)

    DockerizeRails::DockerfileGenerator.generate(@tmp_dir, :rails)
    content = File.read(File.join(@tmp_dir, 'Dockerfile'))

    assert_includes content, 'FROM ruby:3.2'
  end
end
