require "bundler/gem_tasks"

task :default => [:bundle_dependencies, :rspec]

task :bundle_dependencies do
  sh "bundle"
end

task :rspec do
  sh "rspec spec"
end
