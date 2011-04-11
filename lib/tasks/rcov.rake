task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

namespace :spec do
  task(:rcov).clear_prerequisites.clear_actions
  desc "Run all examples using rcov"
  RSpec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features,spec/*"]
    t.rcov_opts << %[ --sort coverage --aggregate coverage.data]
  end
end

namespace :cucumber do
  task(:rcov).clear_prerequisites.clear_actions
  desc "Run cucumber features using rcov"
  Cucumber::Rake::Task.new :rcov => :cleanup_rcov_files do |t|
    t.cucumber_opts = %w{--format progress}
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features,spec/*"]
    t.rcov_opts << %[ --sort coverage --aggregate coverage.data]
    t.rcov_opts << %[ --output #{Rails.root}/cuc_coverage]
  end
end