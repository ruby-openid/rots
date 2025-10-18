# Not in the runtime dependencies.
# If you use the mocks, you need to add `rack-openid2` to your Gemfile.
require "rack/openid" # rack-openid2

# this gem's test support files:
require_relative "mocks/mock_fetcher"
require_relative "mocks/rots_server"
require_relative "mocks/client_app"
