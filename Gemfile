source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 5.2.1'

gem 'mysql2', '>= 0.4.4', '< 0.6.0'

gem 'puma', '~> 3.11'

# gem 'sass-rails', '~> 5.0'
gem 'jquery-rails'
gem 'sassc'
# gem 'bootstrap-sass'
gem 'bootstrap', '~> 4.1.3'

gem 'uglifier', '>= 1.3.0'

gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

gem 'redis', '~> 4.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'mini_magick', '~> 4.8'

gem 'bootsnap', '>= 1.1.0', require: false

gem 'devise'

gem 'sidekiq'

gem 'figaro'

gem 'backbone-on-rails'
gem 'ejs'

gem 'geocoder'
gem 'timezone', '~> 1.0'

gem 'stripe'

# gem 'wowza_player', git: 'git@github.com:WowzaMediaSystems/wowza-player-rails.git'
gem 'wowza_player', git: 'https://github.com/jessethebuilder/wowza-player-rails' # forked from above

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'faker'
end

# gem 'sendgrid-ruby'
gem 'sendgrid-actionmailer'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'selenium-webdriver'
  gem 'chromedriver-helper', '1.2.0'
  gem 'autoprefixer-rails', '8.6.5'
  # gem 'chromedriver-helper'
  gem 'capybara'
  gem 'factory_bot_rails'
  # gem 'poltergeist'
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'webmock'
  gem 'guard-rspec'
  gem 'vcr'
  gem 'launchy'
  gem 'rails-controller-testing'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'wdm', '>= 0.1.0' if Gem.win_platform?

ruby '2.5.3'
