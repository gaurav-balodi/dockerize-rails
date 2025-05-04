module DockerizeRails
  class DockerComposeGenerator
    def self.generate(path, framework, services)
      content = ["version: '3.8'", "services:", "  app:", "    build: .", "    ports:", "      - \"#{framework == :rails ? 3000 : 4567}:#{framework == :rails ? 3000 : 4567}\"", "    volumes:", "      - .:/app"]
      content << "    depends_on:" if services.any?
      services.each { |svc| content << "      - #{svc}" }

      services.each do |svc|
        case svc
        when "postgres"
          content += ["  postgres:", "    image: postgres:15", "    environment:", "      POSTGRES_USER: user", "      POSTGRES_PASSWORD: password", "    ports:", "      - \"5432:5432\""]
        when "mysql"
          content += ["  mysql:", "    image: mysql:8", "    environment:", "      MYSQL_ROOT_PASSWORD: password", "      MYSQL_DATABASE: app_db", "      MYSQL_USER: user", "      MYSQL_PASSWORD: password", "    ports:", "      - \"3306:3306\""]
        when "mongodb"
          content += ["  mongodb:", "    image: mongo:6", "    ports:", "      - \"27017:27017\"", "    volumes:", "      - ./mongo-data:/data/db"]
        when "redis"
          content += ["  redis:", "    image: redis:6", "    ports:", "      - \"6379:6379\""]
        end
      end

      File.write(File.join(path, "docker-compose.yml"), content.join("\n"))
    end
  end
end
