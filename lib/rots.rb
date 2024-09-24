# stdlib in Ruby < 3, gem after
require "net/http"

# External Libraries
require "date"
require "openssl"
require "optparse"
require "rack"
require "rackup"
require "openid" # ruby-openid2
require "stringio"
require "webrick"
require "yaml"
require "psych"

# This library
require_relative "rots/version"
require_relative "rots/server_app"
require_relative "rots/identity_page_app"
require_relative "rots/test_helper"

# Namespace for this gem
module Rots
end

Rots::Version.class_eval do
  extend VersionGem::Basic
end
