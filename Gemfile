# frozen_string_literal: true

source 'https://rubygems.org'

gem 'sinatra'
# NOTE: This torch-rb version must be built with libtorch 2.6, so that's why we're pinning the minor version.
gem 'torch-rb', github: 'cul/torch.rb', branch: '0.19.1-cul'
gem 'transformers-rb', '~> 0.1.6'
group :development do
  gem 'capistrano', '~> 3.19.2', require: false
  gem 'capistrano-bundler'
  gem 'capistrano-cul', require: false
  gem 'capistrano-passenger'
  gem 'rubocul', '~> 4.0'
  gem 'sinatra-contrib', require: false
end
group :test do
  gem 'rack-test'
  gem 'rspec', '~> 3.0'
  gem 'simplecov', require: false
end
