# frozen_string_literal: true

module DockerizeRails
  class DockerIgnoreGenerator
    DEFAULT_IGNORED_PATHS = [
      'config/database.yml',
      'log/',
      'tmp/',
      '.git/'
    ].freeze

    def initialize(project_root = Dir.pwd)
      @dockerignore_path = File.join(project_root, '.dockerignore')
    end

    def ensure_ignored
      existing_lines = File.exist?(@dockerignore_path) ? File.readlines(@dockerignore_path).map(&:strip) : []
      new_lines = DEFAULT_IGNORED_PATHS.reject { |line| existing_lines.include?(line) }

      return if new_lines.empty?

      File.open(@dockerignore_path, 'a') do |file|
        new_lines.each { |line| file.puts line }
      end
    end
  end
end
