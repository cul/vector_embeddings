# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.19.2'

set :instance, 'ldpd'
set :application, 'vector_embeddings'
set :repo_url, 'git@github.com:cul/vector_embeddings.git'
set :deploy_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :rvm_custom_path, '~/.rvm-alma8'
set :rvm_ruby_version, fetch(:deploy_name)
set :remote_user, "#{fetch(:instance)}serv"

set :deploy_to,   "/opt/passenger/#{fetch(:deploy_name)}"

# Default value for keep_releases is 5
set :keep_releases, 3

# RVM Setup, for selecting the correct ruby version (instead of capistrano-rvm gem)
set :rvm_ruby_version, fetch(:deploy_name) # This RVM alias must exist on the server
[:rake, :gem, :bundle, :ruby].each do |command_to_prefix|
  SSHKit.config.command_map.prefix[command_to_prefix].push(
    "#{fetch(:rvm_custom_path, '~/.rvm')}/bin/rvm #{fetch(:rvm_ruby_version)} do"
  )
end

set :passenger_restart_with_touch, true

set :ssh_options, { forward_agent: true }

