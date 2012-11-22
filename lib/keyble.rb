module Keyble
  def parse(data)
    result = { }

    data.split(/\r?\n/).collect do |line|
      type, key, comment = line.split(/\s+/)

      if (comment and !comment.empty? and comment.match(/\S+\@\S+/))
        result[comment] = line
      end
    end

    result
  end

  def read(path)
    result = { }

    File.open(path) do |f|
      result = parse(f.read)
    end

    result
  end

  def write(path, data)
    File.open(path, 'w') do |f|
      data.each do |key, line|
        f.puts(line)
      end
    end
  end

  def ssh_authorized_keys_path
    ".ssh/authorized_keys"
  end

  def cache_file_path=(value)
    @cache_file_path = value
  end

  def cache_file_path
    @cache_file_path or File.expand_path(".keyble", ENV['HOME'])
  end

  def cache
    @cache ||=
      if (File.exist?(cache_file_path))
        read(cache_file_path)
      else
        { }
      end
  end

  def cache_merge!(data)
    cache.merge!(data)

    cache
  end

  def cache_save!
    return unless (@cache)

    write(cache_file_path, @cache)
  end

  def keys_get(servers)
    result = { }

    servers.each do |server|
      Net::SCP.start(server, nil) do |scp|
        result[server] = parse(scp.download!(ssh_authorized_keys_path))
      end
    end

    result
  end

  def keys_reassign(servers)
    servers.each do |server|
      Net::SCP.start(server, nil) do |scp|
        existing = parse(scp.download!(ssh_authorized_keys_path))

        merged = yield(server, existing.dup)

        if (merged != existing)
          authorized_keys = StringIO.new(merged.values.join("\n"))

          scp.upload!(authorized_keys, ssh_authorized_keys_path)
        end
      end
    end
  end

  def keys_add(keys, servers)
    keys_reassign(servers) do |server, existing_keys|
      existing_keys.merge(keys)
    end
  end

  def keys_remove(keys, servers)
    if (keys.respond_to?(:keys))
      keys = keys.keys
    end

    keys_reassign(servers) do |server, existing_keys|
      keys.each do |key|
        existing_keys.delete(key)
      end

      existing_keys
    end
  end

  def keys_import(file)
    imported = read(file)

    cache_merge!(imported)
    cache_save!

    imported
  end

  def keys_display(keys)
    longest_key = keys.keys.collect { |k| k.to_s.length }.sort[-1]

    keys.sort.each do |key, line|
      puts "%-#{longest_key}s  %s" % [ key, line.split(/\s+/)[1][-20, 20] ]
    end
  end

  extend self
end
