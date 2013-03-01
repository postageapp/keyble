require 'optparse'

class Keyble::ArgumentParser
  # == Extensions ===========================================================
  
  # == Constants ============================================================

  # == Properties ===========================================================

  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize
    @strategy = Keyble::Strategy.new
  end

  def parse
    parser.parse!(*args)

    @strategy
  end

  def parser
    OptionParser.new do |parser|
      parser.on("-c", "--cache-path=s") do |path|
        @strategy.cache_path = path
      end
      parser.on("-s", "--servers") do
        @strategy.context = :servers
      end
      parser.on("-a", "--add") do
        @strategy.command = :add
      end
      parser.on("-r", "--remove") do
        @strategy.command = :remove
      end
      parser.on("-d", "--delete") do
        @strategy.command = :delete
      end
      parser.on("-i", "--import") do
        @strategy.command = :import
      end
      parser.on("-l", "--list") do
        @strategy.command = :list
      end
      parser.on("-f", "--find") do
        @strategy.command = :find
      end
      parser.on("-h", "--help") do
        @strategy.message = parser.to_s
      end
    end
  end

  def interpret_args(args)
    args.collect do |arg|
      if (arg.match(/@/))
        (@strategy.keys ||= [ ]) << arg
      elsif (arg.match(/^\+/))
        (@strategy.server_groups ||= [ ]) << arg
      elsif (arg.match(/^#/))
        (@strategy.key_groups ||= [ ]) << arg
      elsif (File.exist?(arg))
        (@strategy.files ||= [ ]) << arg
      else
        (@strategy.servers ||= [ ]) << arg
      end
    end
  end
end
