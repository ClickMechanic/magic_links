$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "magic_links/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "magic_links"
  spec.version     = MagicLinks::VERSION
  spec.authors     = ["James wozniak"]
  spec.email       = ["wozza35@hotmail.com"]
  spec.homepage    = "https://github.com/ClickMechanic/magic_links"
  spec.summary     = "Token based authentication"
  spec.description = "Manages the creation and use of 'magic' tokens. These can be used to provide authenticated access to a subset of controller actions, avoiding the need for users to be signed in."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 5.2"
  spec.add_dependency "devise"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'shoulda-matchers'
end
