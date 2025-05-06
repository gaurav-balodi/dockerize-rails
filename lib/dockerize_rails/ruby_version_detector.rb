# frozen_string_literal: true

module DockerizeRails
  class RubyVersionDetector
    def self.detect(gemfile_path)
      return nil unless File.exist?(gemfile_path)

      File.foreach(gemfile_path) do |line|
        if line =~ /^\s*ruby\s+['"](\d+\.\d+(\.\d+)?)['"]/
          return $1
        end
      end

      nil
    end
  end
end
