require "openid" # ruby-openid2
require "rack/utils"
require "net/http" # stdlib in Ruby < 3, gem after
require "net/protocol"

module Rots
  module Mocks
    class Fetcher
      def initialize(app)
        @app = app
      end

      def fetch(url, body = nil, headers = nil, limit = nil)
        opts = (headers || {}).dup
        opts[:input] = body
        opts[:method] = "POST" if body
        env = Rack::MockRequest.env_for(url, opts)

        status, headers, body = @app.call(env)

        buf = []
        buf << "HTTP/1.1 #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}"
        headers.each { |header, value| buf << "#{header}: #{value}" }
        buf << ""
        body.each { |part| buf << part }

        io = Net::BufferedIO.new(StringIO.new(buf.join("\n")))
        res = Net::HTTPResponse.read_new(io)
        res.reading_body(io, true) {}
        OpenID::HTTPResponse._from_net_response(res, url)
      end
    end
  end
end
