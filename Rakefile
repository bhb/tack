require "bundler/gem_tasks"

 require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tack #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :tack do

  task :acceptance do
    command = 'bin/tack -u -s -Itest test/acceptance'
    puts 'Running acceptance tests'
    puts `#{command}`
  end

  task :unit do
    command = 'bin/tack -u -s -Itest test/unit'
    puts 'Running unit tests'
    puts `#{command}`
  end

  task :compare do
    puts "Comparing results of running tests with Tack to those when running tests with Ruby"
    tack_command = 'bin/tack -s -u -Itest test'
    puts 'Running tests with tack'
    tack_output = `#{tack_command}`
    ### "24 tests, 0 failures, 0 pending"
    match = tack_output.match(/(\d+) tests, (\d+) failures, (\d+) pending/)
    tack_tests, tack_failures, tack_pending = match[1..3].map(&:to_i)
    
    ruby_command = 'rake test'
    puts 'Running tests with ruby'
    ruby_output = `#{ruby_command}`
    ruby_pending = ruby_output.scan(/DEFERRED\:/).length
    match = ruby_output.match(/(\d+) tests, \d+ assertions, (\d+) failures, (\d+) errors/)
    ruby_tests = match[1].to_i + ruby_pending
    ruby_failures = match[2].to_i + match[3].to_i

    if tack_tests != ruby_tests
      puts "!!! Tack reported #{tack_tests} tests while Ruby reported #{ruby_tests} !!!"
    end
    if tack_failures != ruby_failures
      puts "!!! Tack reported #{tack_failures} failures while Ruby reported #{ruby_failures} !!!"
    end
    if tack_pending != ruby_pending
      puts "!!! Tack reported #{tack_pending} pending while Ruby reported #{ruby_pending} !!!"
    end
    puts "Comparison complete"
  end
  
  task :all => [:unit, :acceptance]

end

