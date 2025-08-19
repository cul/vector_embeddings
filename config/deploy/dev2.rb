# frozen_string_literal: true

server 'diglib-rails-dev1.cul.columbia.edu', user: 'renserv', roles: %w[app db web]
# Current branch is suggested by default in development
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
