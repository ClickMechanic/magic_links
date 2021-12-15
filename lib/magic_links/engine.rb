require 'devise'

module MagicLinks
  class Engine < ::Rails::Engine
    isolate_namespace MagicLinks

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
