# frozen_string_literal: true

require_relative "lib/aissue/version"

Gem::Specification.new do |spec|
  spec.name = "aissue"
  spec.version = Aissue::VERSION
  spec.authors = ["ysk91"]
  spec.email = ["ysk91.engineer@gmail.com"]

  spec.summary = "This gem creates a new issue on GitHub by using AI."
  spec.description = "This gem creates a new issue on GitHub by using AI."
  spec.homepage = "https://github.com/ysk91/aissue"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ysk91/aissue"
  spec.metadata["changelog_uri"] = "https://github.com/ysk91/aissue"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'dotenv'
  spec.add_dependency 'octokit'
  spec.add_dependency 'thor'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
