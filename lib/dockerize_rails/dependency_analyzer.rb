module DockerizeRails
  class DependencyAnalyzer
    def initialize(path)
      @path = path
    end

    def detect_framework
      return :rails if File.exist?(File.join(@path, "config/application.rb"))
      return :sinatra if File.readlines(File.join(@path, "Gemfile")).grep(/sinatra/).any? rescue false
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
  end
end
