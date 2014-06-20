task :environment do
  require './backendapp'
end

desc "Run those specs"
task :spec do
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w{--colour --format documentation}
  end
end

