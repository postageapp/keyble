class Keyble::Operation
  def initialize(strategy)
    @strategy = strategy
  end

  def errors?
    @strategy.return_code != 0
  end

  def message
    @strategy.message
  end

  def return_code
    @strategy.return_code
  end

  def perform!
    case (@strategy.context)
    when :servers
      case (@strategy.command)
      when :add
        unless (@strategy.keys)
          STDERR.puts "Cannot add keys to servers listing."
          exit(-12)
        end

        unless (@strategy.keys)
          STDERR.puts "Cannot add keys to servers listing."
          exit(-12)
        end
        
        Keyble.servers_add(args[:servers], groups)
      when :list
        if (Keyble.servers_cache.any?)
          Keyble.servers_display(Keyble.servers_cache)
        else
          puts "No servers in cache."
          exit(0)
        end
      end
    when :keys
      case (command)
      when :add
        if (args[:keys].any?)
          if (args[:servers].any?)
            keys = Keyble.keys_cache.slice(args[:keys])

            Keyble.keys_add(keys, args[:servers])
          else
            STDERR.puts "No servers specified."
            exit(-11)
          end
        else
          puts parser
          exit(-1)
        end
      when :remove
        if (args[:keys].any?)
          if (args[:servers].any?)
            Keyble.keys_remove(args[:keys], args[:servers])
          else
            STDERR.puts "No servers specified."
            exit(-11)
          end
        else
          puts parser
          exit(-1)
        end
      when :delete
        if (args[:keys].any?)
          Keyble.keys_delete(args[:keys])
          
          if (args[:servers].any?)
            Keyble.keys_remove(args[:keys], args[:servers])
          end
        else
          puts parser
          exit(-1)
        end
      when :import
        if (args[:servers].any? or args[:files].any?)
          imported = { }

          if (args[:servers].any?)
            server_keys = Keyble.keys_get(args[:servers])
            
            server_keys.each do |server, keys|
              imported.merge!(keys)
            end
          end

          if (args[:files].any?)
            args[:files].each do |file|
              imported.merge!(Keyble.keys_read(file))
            end
          end

          Keyble.keys_cache_merge!(imported)
          Keyble.keys_cache_save!

          Keyble.keys_display(imported)
        else
          STDERR.puts "No servers or files specified"
          exit(-11)
        end
      when :list
        if (args[:servers].any?)
          collected = { }

          Keyble.keys_get(args[:servers]).each do |server, keys|
            if (args[:keys].any?)
              keys.reject! do |key, v|
                !args[:keys][key]
              end
            end

            if (keys.any?)
              collected[server] = keys
            end
          end

          collected.each do |server, keys|
            if (collected.length > 1)
              puts server
              puts '-' * 78
            end

            Keyble.keys_display(keys)
          end
        else
          if (Keyble.keys_cache.any?)
            Keyble.keys_display(Keyble.keys_cache)
          else
            puts "No keys in #{Keyble.cache_file_path(:keys)}"
          end
        end
      end
    end  
  end
end
