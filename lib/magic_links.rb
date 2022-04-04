require 'magic_links/engine'
require 'magic_links/template'
require 'magic_links/rails'

module MagicLinks
  module Strategies
    autoload :MagicTokenAuthentication, 'magic_links/strategies/magic_token_authentication'
  end

  module Middleware
    autoload :MagicTokenRedirect, 'magic_links/middleware/magic_token_redirect'
  end
end
