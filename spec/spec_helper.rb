# External library dependencies
require "rack/openid" # rack-openid2
require "rack/openid/simple_auth" # Not loaded by rack-openid2, by default
require "version_gem/ruby"
require "rack/mock"
require "minitest/assertions"

# RSpec Configs
require "config/byebug"
require "config/rspec/rspec_block_is_expected"
require "config/rspec/rspec_core"
require "config/rspec/version_gem"

# Last thing before loading this gem is to setup code coverage
begin
  # This does not require "simplecov", but
  require "kettle-soup-cover"
  #   this next line has a side-effect of running `.simplecov`
  require "simplecov" if defined?(Kettle::Soup::Cover) && Kettle::Soup::Cover::DO_COV
rescue LoadError
  nil
end

# this gem:
require "rots"
# this gem's library files of test helpers:
require "rots/test/request_helper"
require "config/rspec/rots"
