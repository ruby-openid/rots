# frozen_string_literal: true

#### IMPORTANT #######################################################
# Gemfile is for local development ONLY; Gemfile is NOT loaded in CI #
####################################################### IMPORTANT ####

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in ranked-model.gemspec
gemspec

gem "net-http", "~> 0.4", ">= 0.4.1"
gem "uri", "~> 0.13", ">= 0.13.1"
gem "logger", "~> 1.6", ">= 1.6.1"
gem "rexml", "~> 3.3", ">= 3.3.7"

platform :mri do
  # Debugging
  gem "byebug", ">= 11"
end
