require "rack/openid" # rack-openid2
require "rack/session"

module Rots
  module Mocks
    class ClientApp
      extend Forwardable

      attr_reader :app, :options

      def_delegator :@app, :call

      def initialize(**options)
        @options = options.dup

        @options[:identifier] ||= "#{Rots::Mocks::RotsServer::SERVER_URL}/john.doe?openid.success=true"

        @app = Rack::Session::Pool.new(Rack::OpenID.new(rack_app))
      end

      private

      def rack_app
        # block passed to new is evaluated with instance_eval,
        #   which searches `binding` for local variables,
        #   while `self` is searched for instance variables and methods.
        # A local pointer in `binding` to @options makes it accessible.
        options = @options
        lambda { |env|
          if (resp = env[Rack::OpenID::RESPONSE])
            headers = {
              "X-Path" => env["PATH_INFO"],
              "X-Method" => env["REQUEST_METHOD"],
              "X-Query-String" => env["QUERY_STRING"],
            }
            if resp.status == :success
              [200, headers, [resp.status.to_s]]
            elsif resp.status == :setup_needed
              headers["Location"] = Rots::Mocks::RotsServer::SERVER_URL # TODO update Rots to properly send user_setup_url. This should come from resp.
              [307, headers, [resp.status.to_s]]
            else
              [400, headers, [resp.status.to_s]]
            end
          elsif env["MOCK_HTTP_BASIC_AUTH"]
            [401, {Rack::OpenID::AUTHENTICATE_HEADER => 'Realm="Example"'}, []]
          else
            [401, {Rack::OpenID::AUTHENTICATE_HEADER => Rack::OpenID.build_header(options)}, []]
          end
        }
      end
    end
  end
end
