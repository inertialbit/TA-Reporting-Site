# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
source 'http://rubygems.org'

gem 'rails', '3.0.4'

gem 'RedCloth'
gem 'authlogic', :git => 'http://github.com/binarylogic/authlogic.git'
gem 'formtastic'
gem 'acts_as_revisable', {
  :git => "git://github.com/inertialbit/acts_as_revisable.git",
  :branch => 'rails3'
}
gem 'fastercsv'
gem 'rmagick', :require => 'RMagick2'
gem 'pdfkit'

group :development, :test do
  gem 'cucumber-rails'
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'webrat'
  gem 'database_cleaner'
  gem 'launchy'
end

group :production do
  gem 'mysql'
end

