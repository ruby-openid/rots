# frozen_string_literal: true

# kettle-jem:freeze
# To retain chunks of comments & code during kettle-jem templating:
# Wrap custom sections with freeze markers (e.g., as above and below this comment chunk).
# kettle-jem will then preserve content between those markers across template runs.
# kettle-jem:unfreeze

source "https://gem.coop"

git_source(:codeberg) { |repo_name| "https://codeberg.org/#{repo_name}" }
git_source(:gitlab) { |repo_name| "https://gitlab.com/#{repo_name}" }

#### IMPORTANT #######################################################
# Gemfile is for local development ONLY; Gemfile is NOT loaded in CI #
####################################################### IMPORTANT ####

# Include dependencies from rots.gemspec
gemspec

gem 'kettle-family', '~> 1.2', '>= 1.2.97'

# Local workspace dependency wiring for *_local.gemfile overrides
gem "nomono", "~> 1.1", ">= 1.1.4", require: false # ruby >= 3.2.0

# Direct sibling dependencies (env-switched via RUBY_OPENID_DEV)
direct_sibling_gems = %w[
  ruby-openid2
]
direct_sibling_dev = ENV.fetch("RUBY_OPENID_DEV", "")
direct_sibling_local =
  !direct_sibling_dev.empty? && !%w[false 0 no off].include?(direct_sibling_dev.downcase)
direct_sibling_templating = ENV.fetch("K_JEM_TEMPLATING", "false").casecmp("true").zero?

if direct_sibling_gems.any? &&
    (direct_sibling_local ||
      ENV.fetch("K_JEM_TEMPLATING", "false").casecmp("true").zero?)
  direct_sibling_dev_was_set = ENV.key?("RUBY_OPENID_DEV")
  direct_sibling_dev_original = ENV.fetch("RUBY_OPENID_DEV", nil)
  require "nomono/bundler"
  begin
    ENV["RUBY_OPENID_DEV"] = File.expand_path("..", __dir__) if direct_sibling_templating && !direct_sibling_local

    eval_nomono_gems(
      gems: direct_sibling_gems,
      prefix: "RUBY_OPENID",
      path_env: "RUBY_OPENID_DEV",
      root: ["src", "my", "ruby-openid"]
    )
  ensure
    if direct_sibling_templating && !direct_sibling_local
      if direct_sibling_dev_was_set
        ENV["RUBY_OPENID_DEV"] = direct_sibling_dev_original
      else
        ENV.delete("RUBY_OPENID_DEV")
      end
    end
  end
end

# Templating (env-switched: STRUCTUREDMERGE_DEV=/path/to/structuredmerge/ruby/gems for local paths)
eval_gemfile "gemfiles/modular/templating.gemfile" if ENV.fetch("K_JEM_TEMPLATING", "false").casecmp("true").zero?

# Debugging
eval_gemfile "gemfiles/modular/debug.gemfile"

# Code Coverage (env-switched: KETTLE_DEV_DEV=true for local paths)
eval_gemfile "gemfiles/modular/coverage.gemfile"

# Linting
eval_gemfile "gemfiles/modular/style.gemfile"

# Documentation
eval_gemfile "gemfiles/modular/documentation.gemfile"

# Optional
eval_gemfile "gemfiles/modular/optional.gemfile"

### Std Lib Extracted Gems
eval_gemfile "gemfiles/modular/x_std_libs.gemfile"

# See unlocked_deps appraisal for more details on irb inclusion
gem "irb", "~> 1.17" # ruby >= 2.7
