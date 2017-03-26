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

require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "debilinguifier"
  gem.homepage = "http://github.com/apapamichalis/debilinguifier"
  gem.license = "MIT"
  gem.summary = %Q{A [greek, latin] debilinguifier}
  gem.description = %Q{The purpose of this gem is to return a phrase written using two charsets due to user's mistake. The reason behind this is that we have a db we want to migrate populated with such entries and we want to somehow sanitize it. The db contains company and product names in capital letters (e.g. the user might have written "komπολοι".upcase instead of "κομπολοι".upcase", resulting in a string that in capital letters seems to be the same, but in practice is not)}
  gem.email = "dimxer@hotmail.com"
  gem.authors = ["apapamichalis"]

  # dependencies defined in Gemfile
end
Juwelier::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "debilinguifier #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
