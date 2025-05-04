require_relative 'generator'

module DockerizeRails
  class CLI
    def self.start(argv)
      options = {
        path: Dir.pwd,
        framework: nil,
        use: [],
        restore: nil
      }

      while argv.any?
        case arg = argv.shift
        when '--path' then options[:path] = argv.shift
        when '--framework' then options[:framework] = argv.shift&.to_sym
        when '--use' then options[:use] = argv.shift&.split(',')
        when '--restore' then options[:restore] = argv.shift
        end
      end

      Generator.new(**options).run
    end
  end
end
