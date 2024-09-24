require "rots/mocks"
require "rots/test"

OpenID.fetcher = Rots::Mocks::Fetcher.new(Rots::Mocks::RotsServer.new)

# This is mostly a copy of the specs from rack-openid2
# This is to ensure that this library does not accidentally
#   break the underlying functionality of rack-openid2.
RSpec.describe "integration" do
  describe "headers" do
    it "builds header" do
      assert_equal 'OpenID identity="http://example.com/"',
        Rack::OpenID.build_header(identity: "http://example.com/")
      assert_equal 'OpenID identity="http://example.com/?foo=bar"',
        Rack::OpenID.build_header(identity: "http://example.com/?foo=bar")

      header = Rack::OpenID.build_header(identity: "http://example.com/", return_to: "http://example.org/")

      assert_match(/OpenID /, header)
      assert_match(/identity="http:\/\/example\.com\/"/, header)
      assert_match(/return_to="http:\/\/example\.org\/"/, header)

      header = Rack::OpenID.build_header(identity: "http://example.com/", required: ["nickname", "email"])

      assert_match(/OpenID /, header)
      assert_match(/identity="http:\/\/example\.com\/"/, header)
      assert_match(/required="nickname,email"/, header)
    end

    it "parses header" do
      assert_equal(
        {"identity" => "http://example.com/"},
        Rack::OpenID.parse_header('OpenID identity="http://example.com/"'),
      )
      assert_equal(
        {"identity" => "http://example.com/?foo=bar"},
        Rack::OpenID.parse_header('OpenID identity="http://example.com/?foo=bar"'),
      )
      assert_equal(
        {"identity" => "http://example.com/", "return_to" => "http://example.org/"},
        Rack::OpenID.parse_header('OpenID identity="http://example.com/", return_to="http://example.org/"'),
      )
      assert_equal(
        {"identity" => "http://example.com/", "required" => ["nickname", "email"]},
        Rack::OpenID.parse_header('OpenID identity="http://example.com/", required="nickname,email"'),
      )

      # ensure we don't break standard HTTP basic auth
      assert_empty(
        Rack::OpenID.parse_header('Realm="Example"'),
      )
    end
  end

  describe "openid" do
    include Rots::Test::RackTestHelpers

    subject(:app) { Rots::Mocks::ClientApp.new(**options) }

    let(:options) { {} }

    it "with_get" do
      mock_openid_request(app, "/", method: "GET")
      follow_openid_redirect!(app)

      assert_equal 200, @response.status
      assert_equal "GET", @response.headers["X-Method"]
      assert_equal "/", @response.headers["X-Path"]
      assert_equal "success", @response.body
    end

    it "with_deprecated_identity" do
      mock_openid_request(app, "/", method: "GET", identity: "#{Rots::Mocks::RotsServer::SERVER_URL}/john.doe?openid.success=true")
      follow_openid_redirect!(app)

      assert_equal 200, @response.status
      assert_equal "GET", @response.headers["X-Method"]
      assert_equal "/", @response.headers["X-Path"]
      assert_equal "success", @response.body
    end

    it "with_post_method" do
      mock_openid_request(app, "/", method: "POST")
      follow_openid_redirect!(app)

      assert_equal 200, @response.status
      assert_equal "POST", @response.headers["X-Method"]
      assert_equal "/", @response.headers["X-Path"]
      assert_equal "success", @response.body
    end

    context "with_custom_return_to" do
      let(:options) { {return_to: "http://example.org/complete"} }

      it "succeeds wth GET" do
        mock_openid_request(app, "/", method: "GET")
        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/complete", @response.headers["X-Path"]
        assert_equal "success", @response.body
      end

      it "succeeds with POST" do
        mock_openid_request(app, "/", method: "POST")
        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/complete", @response.headers["X-Path"]
        assert_equal "success", @response.body
      end
    end

    context "with nested_params_custom_return_to" do
      let(:options) { {return_to: "http://example.org/complete?user[remember_me]=true"} }

      it "succeeds with GET" do
        mock_openid_request(app, "/", method: "GET")
        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/complete", @response.headers["X-Path"]
        assert_equal "success", @response.body
        assert_match(/remember_me/, @response.headers["X-Query-String"])
      end

      it "succeeds with POST" do
        mock_openid_request(app, "/", method: "POST")

        assert_equal 303, @response.status
        env = Rack::MockRequest.env_for(@response.headers["Location"])
        _status, headers, _body = Rots::Mocks::RotsServer.new.call(env)

        _uri, input = headers["Location"].split("?", 2)
        mock_openid_request(app, "http://example.org/complete?user[remember_me]=true", method: "POST", input: input)

        assert_equal 200, @response.status
        assert_equal "POST", @response.headers["X-Method"]
        assert_equal "/complete", @response.headers["X-Path"]
        assert_equal "success", @response.body
        assert_match(/remember_me/, @response.headers["X-Query-String"])
      end
    end

    context "with custom return method" do
      let(:options) { {method: "put"} }

      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")
        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "PUT", @response.headers["X-Method"]
        assert_equal "/", @response.headers["X-Path"]
        assert_equal "success", @response.body
      end
    end

    context "with simple registration fields" do
      let(:options) { {required: ["nickname", "email"], optional: "fullname"} }

      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")
        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/", @response.headers["X-Path"]
        assert_equal "success", @response.body
      end
    end

    context "with attribute exchange" do
      let(:options) {
        {
          required: ["http://axschema.org/namePerson/friendly", "http://axschema.org/contact/email"],
          optional: "http://axschema.org/namePerson",
        }
      }

      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")
        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/", @response.headers["X-Path"]
        assert_equal "success", @response.body
      end
    end

    context "with oauth" do
      let(:options) {
        {
          "oauth[consumer]": "www.example.com",
          "oauth[scope]": ["http://docs.google.com/feeds/", "http://spreadsheets.google.com/feeds/"],
        }
      }

      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")
        location = @response.headers["Location"]

        assert_match(/openid.oauth.consumer/, location)
        assert_match(/openid.oauth.scope/, location)

        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/", @response.headers["X-Path"]
        assert_equal "success", @response.body
      end
    end

    context "with page" do
      let(:options) {
        {
          "pape[preferred_auth_policies]": ["test_policy1", "test_policy2"],
          "pape[max_auth_age]": 600,
        }
      }

      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")

        location = @response.headers["Location"]

        assert_match(/pape\.preferred_auth_policies=test_policy1\+test_policy2/, location)
        assert_match(/pape\.max_auth_age=600/, location)

        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/", @response.headers["X-Path"]
        assert_equal "success", @response.body
      end
    end

    context "with realm wildcard" do
      let(:options) { {realm_domain: "*.example.org"} }

      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")

        location = @response.headers["Location"]

        assert_match(/openid.realm=http%3A%2F%2F%2A.example.org/, location)

        follow_openid_redirect!(app)

        assert_equal 200, @response.status
      end
    end

    context "with inferred realm" do
      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")

        location = @response.headers["Location"]

        assert_match(/openid.realm=http%3A%2F%2Fexample.org/, location)

        follow_openid_redirect!(app)

        assert_equal 200, @response.status
      end
    end

    context "with missing id" do
      let(:options) { {identifier: "#{Rots::Mocks::RotsServer::SERVER_URL}/john.doe"} }

      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")
        follow_openid_redirect!(app)

        assert_equal 400, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/", @response.headers["X-Path"]
        assert_equal "cancel", @response.body
      end
    end

    context "with timeout" do
      let(:options) { {identifier: Rots::Mocks::RotsServer::SERVER_URL} }

      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")

        assert_equal 400, @response.status
        assert_equal "GET", @response.headers["X-Method"]
        assert_equal "/", @response.headers["X-Path"]
        assert_equal "missing", @response.body
      end
    end

    context "with sanitized query string" do
      it "succeeds" do
        mock_openid_request(app, "/", method: "GET")
        follow_openid_redirect!(app)

        assert_equal 200, @response.status
        assert_equal "/", @response.headers["X-Path"]
        assert_equal "", @response.headers["X-Query-String"]
      end
    end

    context "with passthrough standard http basic auth" do
      it "succeeds" do
        mock_openid_request(app, "/", :method => "GET", "MOCK_HTTP_BASIC_AUTH" => "1")

        assert_equal 401, @response.status
      end
    end

    describe "simple auth" do
      include Rots::Test::RackTestHelpers

      it "can login" do
        app = simple_app("#{Rots::Mocks::RotsServer::SERVER_URL}/john.doe?openid.success=true")
        mock_openid_request(app, "/dashboard")
        follow_openid_redirect!(app)

        assert_equal 303, @response.status
        assert_equal "http://example.org/dashboard", @response.headers["Location"]

        cookie = @response.headers["Set-Cookie"].split(";").first
        mock_openid_request(app, "/dashboard", "HTTP_COOKIE" => cookie)

        assert_equal 200, @response.status
        assert_equal "Hello", @response.body
      end

      it "fails login" do
        app = simple_app("#{Rots::Mocks::RotsServer::SERVER_URL}/john.doe")

        mock_openid_request(app, "/dashboard")
        follow_openid_redirect!(app)

        assert_match Rots::Mocks::RotsServer::SERVER_URL, @response.headers["Location"]
      end

      private

      def simple_app(identifier)
        rack_app = lambda { |env| [200, {"Content-Type" => "text/html"}, ["Hello"]] }
        rack_app = Rack::OpenID::SimpleAuth.new(rack_app, identifier)
        Rack::Session::Pool.new(rack_app)
      end
    end
  end
end
