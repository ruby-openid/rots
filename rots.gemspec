# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rots/version"

Gem::Specification.new do |spec|
  spec.name            = "rots"
  spec.version         = Rots::VERSION
  spec.platform        = Gem::Platform::RUBY
  spec.summary         = "an OpenID server for making tests of OpenID clients implementations"

  spec.description = <<-EOF
Ruby OpenID Test Server (ROTS) provides a basic OpenID server made in top of the Rack gem.
With this small server, you can make dummy OpenID request for testing purposes,
the success of the response will depend on a parameter given on the URL of the authentication request.
  EOF

  spec.files = Dir[
    # Splats (alphabetical)
    "{exe,lib}/**/*",
    # Files (alphabetical)
    "AUTHORS",
    "README",
  ]
  # bin/ is scripts, in any available language, for development of this specific gem
  # exe/ is for ruby scripts that will ship with this gem to be used by other tools
  spec.bindir = "exe"
  spec.executables = %w[
    rots
  ]
  spec.require_path    = 'lib'
  spec.author          = 'Roman Gonzalez'
  spec.email           = 'romanandreg@gmail.com'
  spec.homepage        = 'http://github.com/roman'
  spec.rubyforge_project = 'rots'
  spec.license         = 'MIT'

  spec.add_dependency "date"
  spec.add_dependency "net-http"
  spec.add_dependency "openssl"
  spec.add_dependency "optparse"
  spec.add_dependency "rack", ">= 2"
  spec.add_dependency "rackup", ">= 2"
  spec.add_dependency "ruby-openid2", "~> 3.0"
  spec.add_dependency "stringio"
  spec.add_dependency "webrick"
  spec.add_dependency "yaml", "~> 0.3"
  spec.add_dependency "psych", "~> 5.1"

  spec.add_development_dependency("rspec", "~> 3.13")
  spec.add_development_dependency("rake", ">= 13")
end
