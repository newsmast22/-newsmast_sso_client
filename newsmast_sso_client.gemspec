# frozen_string_literal: true

require_relative "lib/newsmast_sso_client/version"

Gem::Specification.new do |spec|
  spec.name = "newsmast_sso_client"
  spec.version = NewsmastSsoClient::VERSION
  spec.authors = ["yarzar"]
  spec.email = ["yarzarminwai97@gmail.com"]

  spec.summary = "Newsmast authentication gem"
  spec.description = "Newsmast authentication gem"
  spec.homepage = "https://github.com/newsmast22/newsmast_sso_client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://github.com/newsmast22/newsmast_sso_client"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/newsmast22/newsmast_sso_client"
  spec.metadata["changelog_uri"] = "https://github.com/newsmast22/newsmast_sso_client"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
