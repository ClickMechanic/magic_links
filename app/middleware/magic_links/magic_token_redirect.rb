module MagicLinks
  class MagicTokenRedirect
    def initialize(app)
      @app = app
    end

    def call(env)
      Handler.new(env).handle || app.call(env)
    end

    private

    attr_reader :app

    class Handler
      def initialize(env)
        @request = ActionDispatch::Request.new(env)
      end

      def handle
        return unless redirect_request?
        return root unless magic_token.present?

        cookies.signed[magic_token_key] = magic_token.token if scope
        respond_with_redirect magic_token.target_path
      end

      def root
        respond_with_redirect '/', 'to the home page (token not found)'
      end

      attr_reader :request

      def path
        request.path
      end

      def redirect_request?
        MagicLinksHelper.match?(path)
      end

      def magic_token
        return unless token

        @magic_token ||= MagicToken.find_by(token: token)
      end

      def token
        @token ||= MagicLinksHelper.token_for(path)
      end

      def scope
        magic_token&.scope
      end

      private

      def respond_with(status, headers, body)
        ActionDispatch::Response.new(status, headers, body).to_a
      end

      def respond_with_redirect(path, path_desc = '')
        body = %(You are being redirected <a href="#{path}">#{path_desc.present? ? path_desc : path}</a>)
        ActionDispatch::Response.new(302, {'Location' => path}, body).to_a
      end

      def magic_token_key
        "#{scope}_magic_token"
      end

      def cookies
        request.cookie_jar
      end
    end
  end
end
