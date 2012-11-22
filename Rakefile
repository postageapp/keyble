# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = "keyble"
  gem.homepage = "http://github.com/twg/keyble"
  gem.license = "MIT"
  gem.summary = %Q{SSH Key Management}
  gem.description = %Q{Unubtrusive SSH key management}
  gem.email = "scott@twg.ca"
  gem.authors = [ "Scott Tadman" ]
  # Dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
