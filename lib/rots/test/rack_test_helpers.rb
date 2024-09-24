module Rots
  module Test
    module RackTestHelpers
      def mock_openid_request(app, *args)
        env = Rack::MockRequest.env_for(*args)
        @response = Rack::MockResponse.new(*app.call(env))
      end

      def follow_openid_redirect!(app)
        assert(@response)
        assert_equal(303, @response.status)

        env = Rack::MockRequest.env_for(@response.headers["Location"])
        _status, headers, _body = Rots::Mocks::RotsServer.new.call(env)

        uri = URI(headers["Location"])
        mock_openid_request(app, "#{uri.path}?#{uri.query}")
      end
    end
  end
end
