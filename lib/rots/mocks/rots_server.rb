module Rots
  module Mocks
    class RotsServer
      extend Forwardable
      SERVER_URL = "http://localhost:9292"
      DEFAULT_CONFIG = {
        "identity" => "john.doe",
        "sreg" => {
          "nickname" => "jdoe",
          "fullname" => "John Doe",
          "email" => "jhon@doe.com",
          "dob" => Date.parse("1985-09-21"),
          "gender" => "M",
        }.freeze,
      }.freeze

      attr_reader :app, :config

      def_delegator :@app, :call

      # @param config [Hash, nil] - the configuration of the app's authorizable identity
      def initialize(config = nil)
        @config ||= DEFAULT_CONFIG
        raise ArgumentError, "config must be a Hash" unless self.config.is_a?(Hash)

        @app = rack_app
      end

      private

      def rack_app
        # block passed to new is evaluated with instance_eval,
        #   which searches `binding` for local variables,
        #   while `self` is searched for instance variables and methods.
        # A local pointer in `binding` to @config makes it accessible.
        config = @config
        Rack::Builder.new do
          map("/%s" % config["identity"]) do
            run(Rots::IdentityPageApp.new(config, {}))
          end

          map("/server") do
            run(Rots::ServerApp.new(config, storage: Dir.tmpdir))
          end
        end
      end
    end
  end
end
