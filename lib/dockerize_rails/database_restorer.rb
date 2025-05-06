# frozen_string_literal: true

# module DockerizeRails
#   class DatabaseRestorer
#     def self.restore(path, dump_file)
#       puts "✔ Restoring database from dump file '#{dump_file}' inside Docker container..."

#       # Execute the docker-compose exec command to restore the database from the dump file
#       container_name = "app"  # Assuming the container is named 'app', adjust if needed
#       command = "docker-compose exec -T #{container_name} bash -c 'pg_restore --clean --no-acl --no-owner -U postgres -d #{db_name} < #{dump_file}'"

#       result = system(command)

#       if result
#         puts "✔ Database restored successfully from '#{dump_file}'."
#       else
#         puts "❌ Failed to restore database from '#{dump_file}'. Please check the logs for errors."
#       end
#     end
#   end
# end

module DockerizeRails
  class DatabaseRestorer
    def self.restore(dump_file, config)
      raise "Dump file '#{dump_file}' does not exist." unless File.exist?(dump_file)

      db_name = config[:database]
      puts "✔ Restoring database '#{db_name}' from dump file '#{dump_file}' inside Docker container..."

      container_name = "app" # You may later make this configurable
      command = "docker-compose exec -T #{container_name} bash -c 'pg_restore --clean --no-acl --no-owner -U #{config[:username]} -d #{db_name} < #{dump_file}'"

      result = system(command)

      if result
        puts "✔ Database restored successfully from '#{dump_file}'."
      else
        puts "❌ Failed to restore database from '#{dump_file}'. Please check the logs for errors."
      end
    end
  end
end
