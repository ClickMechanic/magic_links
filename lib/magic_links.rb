require "magic_links/engine"
require 'magic_links/rails'

module MagicLinks
  module Strategies
    autoload :MagicTokenAuthentication, 'magic_links/strategies/magic_token_authentication'
  end
end
