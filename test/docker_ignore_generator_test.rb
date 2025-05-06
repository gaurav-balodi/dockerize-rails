require "minitest/autorun"
require "fileutils"
require "dockerize_rails"

class DockerIgnoreGeneratorTest < Minitest::Test
  def setup
    @tmp_dir = Dir.mktmpdir
    @dockerignore_path = File.join(@tmp_dir, ".dockerignore")
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  def test_creates_dockerignore_with_all_default_paths
    updater = DockerizeRails::DockerIgnoreGenerator.new(@tmp_dir)
    updater.ensure_ignored

    content = File.read(@dockerignore_path)
    DockerizeRails::DockerIgnoreGenerator::DEFAULT_IGNORED_PATHS.each do |line|
      assert_includes content, line
    end
  end

  def test_does_not_duplicate_existing_entries
    File.write(@dockerignore_path, "log/\n")

    updater = DockerizeRails::DockerIgnoreGenerator.new(@tmp_dir)
    updater.ensure_ignored

    content = File.read(@dockerignore_path).lines.map(&:strip)
    assert_equal 1, content.count { |line| line == "log/" }
  end
end
