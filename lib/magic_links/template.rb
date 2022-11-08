module MagicLinks
  class Template
    VALID_TEMPLATE_PATTERN = %r{^/([A-Za-z0-9_\-]+)/(:token)$}.freeze

    attr_reader :name, :pattern, :action_scope, :strength, :expiry

    def initialize(pattern:, action_scope:, strength:, expiry:)
      raise ArgumentError, "Pattern must be of the form '/xyz/:token'" unless VALID_TEMPLATE_PATTERN.match?(pattern)

      @pattern = pattern
      @action_scope = action_scope
      @strength = strength
      @expiry = expiry
    end

    def match?(path)
      matcher.match?(path)
    end

    def token_for(path)
      matcher.match(path)&.captures&.first
    end

    def magic_link_for(user, path, expiry = nil)
      expiry ||= self.expiry
      magic_token = magic_token_for(user, path, expiry)
      pattern.sub(':token', magic_token.token)
    end

    def magic_url_for(user, path, expiry = nil)
      url_for(magic_link_for(user, path, expiry))
    end

    private

    def url_for(path)
      ActionDispatch::Http::URL.url_for(default_url_options.merge(path: path))
    end

    def default_url_options
      Rails.application.routes.default_url_options
    end

    def magic_token_for(user, path, expiry)
      MagicToken.for(**magic_token_params_for(user, path, expiry))
    end

    def magic_token_params_for(user, path, expiry)
      {
        authenticatable: user,
        target_path: path,
        action_scope: action_scope,
        strength: strength,
        expiry: expiry
      }
    end

    def matcher
      @matcher ||= build_matcher
    end

    def build_matcher
      sections = VALID_TEMPLATE_PATTERN.match(pattern).captures
      %r{^/#{sections[0]}/([A-Za-z0-9_\-]+)$}
    end
  end
end
