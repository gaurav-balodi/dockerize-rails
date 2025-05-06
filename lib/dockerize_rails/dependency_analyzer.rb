# frozen_string_literal: true

module DockerizeRails
  class DependencyAnalyzer
    def initialize(path)
      @path = path
    end

    def detect_framework
      return :rails if File.exist?(File.join(@path, "config/application.rb"))
      return :sinatra if gemfile_lines.grep(/sinatra/).any? rescue false
      :unknown
    end

    def detect_services
      lockfile = File.join(@path, "Gemfile.lock")
      return [] unless File.exist?(lockfile)

      content = File.read(lockfile)
      services = []
      services << "postgres" if content.include?("pg")
      services << "mysql" if content.match?(/mysql2|activerecord-mysql/)
      services << "mongodb" if content.match?(/mongo|mongoid/)
      services << "redis" if content.include?("redis")
      services.uniq
    end

    def ruby_version
      gemfile_path = File.join(@path, "Gemfile")
      return nil unless File.exist?(gemfile_path)

      gemfile_lines.each do |line|
        return line.split.last.gsub(/['"]/, "") if line.strip.start_with?("ruby")
      end
      nil
    end

    private

    def gemfile_lines
      File.readlines(File.join(@path, "Gemfile"))
    end
  end
end
