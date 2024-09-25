# ROTS - Ruby OpenID Test Server

<div id="badges">

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/gem/v/rots.svg)](https://rubygems.org/gems/rots)
[![Downloads Today](https://img.shields.io/gem/rd/rots.svg)](https://github.com/oauth-xx/rots)
[![CodeCov][🖇codecov-img♻️]][🖇codecov]
[![CI Supported Build][🚎s-wfi]][🚎s-wf]
[![CI Unsupported Build][🚎us-wfi]][🚎us-wf]
[![CI Style Build][🚎st-wfi]][🚎st-wf]
[![CI Coverage Build][🚎cov-wfi]][🚎cov-wf]
[![CI Heads Build][🚎hd-wfi]][🚎hd-wf]
[![CI Ancient Build][🚎an-wfi]][🚎an-wf]

[🖇codecov-img♻️]: https://codecov.io/gh/oauth-xx/rots/graph/badge.svg?token=qycnWzl6qM
[🖇codecov]: https://codecov.io/gh/oauth-xx/rots
[🚎s-wf]: https://github.com/oauth-xx/rots/actions/workflows/supported.yml
[🚎s-wfi]: https://github.com/oauth-xx/rots/actions/workflows/supported.yml/badge.svg
[🚎us-wf]: https://github.com/oauth-xx/rots/actions/workflows/unsupported.yml
[🚎us-wfi]: https://github.com/oauth-xx/rots/actions/workflows/unsupported.yml/badge.svg
[🚎st-wf]: https://github.com/oauth-xx/rots/actions/workflows/style.yml
[🚎st-wfi]: https://github.com/oauth-xx/rots/actions/workflows/style.yml/badge.svg
[🚎cov-wf]: https://github.com/oauth-xx/rots/actions/workflows/coverage.yml
[🚎cov-wfi]: https://github.com/oauth-xx/rots/actions/workflows/coverage.yml/badge.svg
[🚎hd-wf]: https://github.com/oauth-xx/rots/actions/workflows/heads.yml
[🚎hd-wfi]: https://github.com/oauth-xx/rots/actions/workflows/heads.yml/badge.svg
[🚎an-wf]: https://github.com/oauth-xx/rots/actions/workflows/ancient.yml
[🚎an-wfi]: https://github.com/oauth-xx/rots/actions/workflows/ancient.yml/badge.svg

</div>

-----

<div align="center">

[![Liberapay Patrons][⛳liberapay-img]][⛳liberapay]
[![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor]
[![Polar Shield][🖇polar-img]][🖇polar]
[![Donate to my FLOSS or refugee efforts at ko-fi.com][🖇kofi-img]][🖇kofi]
[![Donate to my FLOSS or refugee efforts using Patreon][🖇patreon-img]][🖇patreon]

[⛳liberapay-img]: https://img.shields.io/liberapay/patrons/pboling.svg?logo=liberapay
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇sponsor-img]: https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github
[🖇sponsor]: https://github.com/sponsors/pboling
[🖇polar-img]: https://polar.sh/embed/seeks-funding-shield.svg?org=pboling
[🖇polar]: https://polar.sh/pboling
[🖇kofi-img]: https://img.shields.io/badge/buy%20me%20coffee-donate-yellow.svg
[🖇kofi]: https://ko-fi.com/O5O86SNP4
[🖇patreon-img]: https://img.shields.io/badge/patreon-donate-yellow.svg
[🖇patreon]: https://patreon.com/galtzo

<span class="badge-buymealatte">
<a href="https://www.buymeacoffee.com/pboling"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a latte&emoji=&slug=pboling&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff" /></a>
</span>

</div>
</div>

Ruby OpenID Test Server (ROTS) is a dummy OpenID server that makes consumer tests dead easy.

ROTS is a minimal implementation of an OpenID server, developed on top of the Rack middleware, this
server provides an easy to use interface to make testing OpenID consumers really easy.

## No more mocks

Have you always wanted to test the authentication of an OpenID consumer implementation, but find your self
in a point where is to hard to mock? A lot of people have been there.

With ROTS, you only need to specify an identity url provided by the dummy server, passing with it a flag
saying that you want the authentication to be successful. It handles SREG extensions as well.

### Or do use mocks, maybe?

You can also require a library of mocks and request helpers which might be useful in your tests (perhaps in your `spec_helper.rb`):

```ruby
require "rots/mocks"
require "rots/test"

OpenID.fetcher = Rots::Mocks::Fetcher.new(Rots::Mocks::RotsServer.new)

RSpec.configure do |config|
  config.include(Rots::Test::RackTestHelpers)
end
```

Helpers are written with minitest syntax,
but RSpec supports that, so it should work in both RSpec and MiniTest,
and you don't need to switch your other tests to use minitest syntax.
Use them interchangeably, as needed.
```ruby
RSpec.configure do |config|
  config.expect_with(:rspec, :minitest)
end
```

And in another file (see `spec/rots/mocks/integration_spec.rb` for more):

```ruby
RSpec.describe("openid") do
  subject(:app) { Rots::Mocks::ClientApp.new(**options) }

  let(:options) { {identifier: "#{Rots::Mocks::RotsServer::SERVER_URL}/john.doe?openid.success=true"} }

  it "with_get" do
    mock_openid_request(app, "/", method: "GET")
    follow_openid_redirect!(app)

    assert_equal 200, @response.status
    assert_equal "GET", @response.headers["X-Method"]
    assert_equal "/", @response.headers["X-Path"]
    assert_equal "success", @response.body
  end
end
```

### Note about the deprecation of stdlib gems `logger`, `rexml`, `stringio`, `net-http`, and `uri`

They will not be direct dependencies until the situation with bundler is resolved.
You will need to add them directly to downstream tools.

See [this discussion](https://github.com/rubygems/rubygems/issues/7178#issuecomment-2372558363) for more information.

## How does it work?

When you install the ROTS gem, a binary called rots is provided for starting the server (for more
info about what options you have when executing this file, check the -h option).

By default, rots will have a test user called "John Doe", with an OpenID identity "john.doe".
If you want to use your own test user name, you can specify a config file to rots. The
default configuration file looks like this:

### Default configuration file
```yaml
identity: john.doe
sreg:
  nickname: jdoe
  fullname: John Doe
  email: jhon@doe.com
  dob: 1985-09-21
  gender: M
```

You can specify a new config file using the option `--config`.

## Getting Started

The best way to get started, is running the rots server, and then starting to execute your OpenID consumer tests/specs. You just have to specify the identity url of your test user, if you want the OpenID response be successful just add the openid.success=true flag to the user identity url. If you don't specify the flag it
will return a cancel response instead.

Example:
```ruby
it "should authenticate with OpenID" do
  post("/consumer_openid_login", "identity_url" => "http://localhost:1132/john.doe?openid.success=true")
end
```

## 🤝 Contributing

See [CONTRIBUTING.md][🤝contributing]

[🤝contributing]: CONTRIBUTING.md

### Code Coverage

If you need some ideas of where to help, you could work on adding more code coverage.

[![Coverage Graph][🔑codecov-g]][🖇codecov]

[🔑codecov-g]: https://codecov.io/gh/oauth-xx/rots/graphs/tree.svg?token=qycnWzl6qM

## 🌈 Contributors

[![Contributors][🖐contributors-img]][🖐contributors]

Made with [contributors-img][🖐contrib-rocks].

[🖐contrib-rocks]: https://contrib.rocks
[🖐contributors]: https://github.com/oauth-xx/rots/graphs/contributors
[🖐contributors-img]: https://contrib.rocks/image?repo=oauth-xx/rots

## Star History

<a href="https://star-history.com/#oauth-xx/rots&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oauth-xx/rots&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=oauth-xx/rots&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=oauth-xx/rots&type=Date" />
 </picture>
</a>

## 🪇 Code of Conduct

Everyone interacting in this project's codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of conduct][🪇conduct].

[🪇conduct]: CODE_OF_CONDUCT.md

## 📌 Versioning

This Library adheres to [Semantic Versioning 2.0.0][📌semver].
Violations of this scheme should be reported as bugs.
Specifically, if a minor or patch version is released that breaks backward compatibility,
a new version should be immediately released that restores compatibility.
Breaking changes to the public API will only be introduced with new major versions.

To get a better understanding of how SemVer is intended to work over a project's lifetime,
read this article from the creator of SemVer:

- ["Major Version Numbers are Not Sacred"][📌major-versions-not-sacred]

As a result of this policy, you can (and should) specify a dependency on these libraries using
the [Pessimistic Version Constraint][📌pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency("rots", "~> 1.0")
```

See [CHANGELOG.md][📌changelog] for list of releases.

[comment]: <> ( 📌 VERSIONING LINKS )

[📌pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[📌semver]: http://semver.org/
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📌changelog]: CHANGELOG.md

## 📄 License

The gem is available as open source under the terms of
the [MIT License][📄license] [![License: MIT][📄license-img]][📄license-ref].
See [LICENSE.txt][📄license] for the official [Copyright Notice][📄copyright-notice-explainer].

[comment]: <> ( 📄 LEGAL LINKS )

[📄copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year
[📄license]: LICENSE.txt
[📄license-ref]: https://opensource.org/licenses/MIT
[📄license-img]: https://img.shields.io/badge/License-MIT-green.svg

### © Copyright

*  Copyright (c) 2009 - 2011, 2013 - 2014, 2017 Roman Gonzalez <romanandreg@gmail.com>
*  Copyright (c) 2024 [Peter H. Boling][peterboling] of [Rails Bling][railsbling]

[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[bundle-group-pattern]: https://gist.github.com/pboling/4564780
[documentation]: http://rdoc.info/github/oauth-xx/rots/frames
[homepage]: https://github.com/oauth-xx/rots
