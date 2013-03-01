require 'fileutils'
require 'net/scp'

module Keyble
  autoload(:ArgumentParser, 'keyble/argument_parser')
  autoload(:Operation, 'keyble/operation')
  autoload(:Strategy, 'keyble/strategy')

  def servers_parse(data)
    result = { }

    data.split(/\r?\n/).collect do |line|
      name, groups = line.split(/\s*\#\s*/)
      groups = groups.to_s.split(/\s+|\s*\,\s*/)

      if (name and !name.empty?)
        result[name] = groups
      end
    end

    result
  end

  def keys_parse(data)
    result = { }

    data.split(/\r?\n/).collect do |line|
      type, key, comment = line.split(/\s+/)

      if (comment and !comment.empty? and comment.match(/\S+\@\S+/))
        result[comment] = line
      end
    end

    result
  end

  def servers_read(path)
    result = { }

    File.open(path) do |f|
      result = servers_parse(f.read)
    end

    result
  end

  def servers_write(path, data)
    File.open(path, 'w') do |f|
      data.each do |server, groups|
        if (groups.any?)
          f.puts("#{server} \# #{groups.join(' ')}")
        else
          f.puts(server)
        end
      end
    end
  end

  def keys_read(path)
    result = { }

    File.open(path) do |f|
      result = keys_parse(f.read)
    end

    result
  end

  def keys_write(path, data)
    File.open(path, 'w') do |f|
      data.each do |key, line|
        f.puts(line)
      end
    end
  end

  def ssh_authorized_keys_path
    ".ssh/authorized_keys"
  end

  def cache_path=(value)
    @cache_path = value && value.to_s
  end

  def cache_path
    @cache_path || ENV['KEYBLE_CACHE_PATH'] || "#{ENV['HOME']}/.keyble"
  end

  def cache_file_path=(value)
    @cache_file_path = value && value.to_s
  end

  def cache_file_path(context)
    @cache_file_path or File.expand_path(context.to_s, cache_path)
  end

  def servers_cache
    @servers_cache ||= begin
      path = cache_file_path(:servers)

      if (File.exist?(path))
        servers_read(path)
      else
        { }
      end
    end
  end

  def servers_cache_save!
    return unless (@servers_cache)

    path = cache_file_path(:servers)
    dir = File.dirname(path)

    unless (File.exist?(path))
      FileUtils.mkdir_p(dir)
    end

    servers_write(path, @servers_cache)
  end

  def keys_cache
    @keys_cache ||= begin
      path = cache_file_path(:keys)

      if (File.exist?(path))
        keys_read(path)
      else
        { }
      end
    end
  end

  def keys_cache_merge!(data)
    keys_cache.merge!(data)

    keys_cache
  end

  def keys_cache_save!
    return unless (@keys_cache)

    path = cache_file_path(:keys)
    dir = File.dirname(path)

    unless (File.exist?(path))
      FileUtils.mkdir_p(dir)
    end

    keys_write(path, @keys_cache)
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
        existing = keys_parse(scp.download!(ssh_authorized_keys_path))

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

  def keys_delete(keys)
    if (keys.respond_to?(:keys))
      keys = keys.keys
    end

    keys.each do |key|
      cache.delete(key)
    end

    cache_save!
  end

  def keys_import(file)
    imported = read(file)

    cache_merge!(imported)
    cache_save!

    imported
  end

  def servers_add(servers, groups = nil)
    servers.each do |server|
      server_groups = servers_cache[server] ||= [ ]
      server_groups += groups if (groups)

      server_groups.uniq!
      server_groups.sort!
    end

    servers_cache_save!
  end

  def servers_display(servers)
    longest_key = servers.keys.collect { |k| k.to_s.length }.sort[-1]

    servers.sort.each do |server, groups|
      if (groups.any?)
        puts "%-#{longest_key}s  [%s]" % [ server, groups.join(' ') ]
      else
        puts server
      end
    end
  end

  def keys_display(keys)
    longest_key = keys.keys.collect { |k| k.to_s.length }.sort[-1]

    keys.sort.each do |key, line|
      puts "%-#{longest_key}s  %s" % [ key, line.split(/\s+/)[1][-20, 20] ]
    end
  end

  extend self
end
