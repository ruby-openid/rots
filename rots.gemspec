# Get the GEMFILE_VERSION without *require* "my_gem/version", for code coverage accuracy
# See: https://github.com/simplecov-ruby/simplecov/issues/557#issuecomment-825171399
load "lib/rots/version.rb"
gem_version = Rots::Version::VERSION
Rots::Version.send(:remove_const, :VERSION)

Gem::Specification.new do |spec|
  spec.name = "rots"
  spec.version = gem_version
  spec.authors = ["Peter Boling", "Roman Gonzalez"]
  spec.email = ["peter.boling@gmail.com", "romanandreg@gmail.com"]
  spec.homepage = "http://github.com/oauth-xx/#{spec.name}"

  # See CONTRIBUTING.md
  spec.cert_chain = [ENV.fetch("GEM_CERT_PATH", "certs/#{ENV.fetch("GEM_CERT_USER", ENV["USER"])}.pem")]
  spec.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $PROGRAM_NAME.end_with?("gem")

  spec.summary = "an OpenID server for making tests of OpenID clients implementations"
  spec.description = <<~EOF
    Ruby OpenID Test Server (ROTS) provides a basic OpenID server made in top of the Rack gem.
    With this small server, you can make dummy OpenID request for testing purposes,
    the success of the response will depend on a parameter given on the URL of the authentication request.
  EOF

  spec.metadata["homepage_uri"] = "https://railsbling.com/tags/rots/"
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata["wiki_uri"] = "#{spec.homepage}/wiki"
  spec.metadata["funding_uri"] = "https://liberapay.com/pboling"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    # Splats (alphabetical)
    "{exe,lib}/**/*",
    # Files (alphabetical)
    "AUTHORS",
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE.txt",
    "README.md",
    "SECURITY.md"
  ]
  # bin/ is scripts, in any available language, for development of this specific gem
  # exe/ is for ruby scripts that will ship with this gem to be used by other tools
  spec.bindir = "exe"
  spec.executables = %w[
    rots
  ]
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.add_dependency("date")
  spec.add_dependency("net-http", "~> 0.4", ">= 0.4.1")
  spec.add_dependency("openssl")
  spec.add_dependency("optparse")
  spec.add_dependency("psych", "~> 5.1")
  spec.add_dependency("rack", ">= 2")
  spec.add_dependency("rackup", ">= 2")
  spec.add_dependency("ruby-openid2", "~> 3.0", ">= 3.0.3")
  spec.add_dependency("stringio")
  spec.add_dependency("version_gem", "~> 1.1", ">= 1.1.4")
  spec.add_dependency("webrick")
  spec.add_dependency("yaml", "~> 0.3")

  spec.add_development_dependency("rack-openid2", ">= 2")
  spec.add_development_dependency("rack-session", ">= 1")

  # Documentation
  spec.add_development_dependency("yard", "~> 0.9", ">= 0.9.34")
  spec.add_development_dependency("yard-junk", "~> 0.0.10")

  # Coverage
  spec.add_development_dependency("kettle-soup-cover", "~> 1.0", ">= 1.0.2")

  # Unit tests
  spec.add_development_dependency("minitest", ">= 5", "< 6") # Use assert_nil if expecting nil
  spec.add_development_dependency("rake", ">= 10")
  spec.add_development_dependency("rspec", "~> 3.13")
  spec.add_development_dependency("rspec-block_is_expected", "~> 1.0", ">= 1.0.6")

  # Linting
  spec.add_development_dependency("rubocop-lts", "~> 10.1") # Lint & Style Support for Ruby 2.3+
  spec.add_development_dependency("rubocop-packaging", "~> 0.5", ">= 0.5.2")
  spec.add_development_dependency("rubocop-rspec", "~> 3.0")
  spec.add_development_dependency("standard", "~> 1.40")
end
