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
  require "kettle-soup-cover"
  #   this next line has a side-effect of running `.simplecov`
  require "simplecov" if defined?(Kettle::Soup::Cover) && Kettle::Soup::Cover::DO_COV
rescue LoadError
  # check the error message and re-raise when unexpected
  nil
end

# External RSpec & related config
require "kettle/test/rspec"

# this gem:
require "rots"
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
# this gem's library files of test helpers:
require "rots/test/request_helper"
require "config/rspec/rots"
