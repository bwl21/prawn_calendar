require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'rake/clean'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./**/*_spec.rb" # don't need this, it's default.
  t.rspec_opts = ['-fd -fd --out ./testresults/test_results.log -fh --out ./testresults/test_results.html']
  # Put spec opts in a file named .rspec in root
end


desc "document (yard) all AUTOSAR ruby helpers defined here"
task :doc do
   sh "yard  --markup markdown doc . "
end
