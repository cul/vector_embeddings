# frozen_string_literal: true

# In test/prod, suggest latest tag as default version to deploy
ask :branch, proc { `git tag --sort=version:refname`.split("\n").last }
