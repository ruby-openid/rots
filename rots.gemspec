# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rots/version"

Gem::Specification.new do |s|
  s.name            = "rots"
  s.version         = Rots::VERSION
  s.platform        = Gem::Platform::RUBY
  s.summary         = "an OpenID server for making tests of OpenID clients implementations"

  s.description = <<-EOF
Ruby OpenID Test Server (ROST) provides a basic OpenID server made in top of the Rack gem.
With this small server, you can make dummy OpenID request for testing purposes,
the success of the response will depend on a parameter given on the URL of the authentication request.
  EOF

  s.files = [
    # Splats (alphabetical)
    "{bin,lib}/**/*",
    # Files (alphabetical)
    "AUTHORS",
    "README",
  ]
  # bin/ is scripts, in any available language, for development of this specific gem
  # exe/ is for ruby scripts that will ship with this gem to be used by other tools
  s.bindir = "exe"
  s.executables = %w[
    rots
  ]
  s.require_path    = 'lib'
  s.author          = 'Roman Gonzalez'
  s.email           = 'romanandreg@gmail.com'
  s.homepage        = 'http://github.com/roman'
  s.rubyforge_project = 'rots'
  s.license         = 'MIT'

  s.add_development_dependency 'rspec', "~> 3.13"
  s.add_development_dependency 'rack', "~> 1.6"
  s.add_development_dependency 'ruby-openid2'
end
