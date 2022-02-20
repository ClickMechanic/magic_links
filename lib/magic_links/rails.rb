module MagicLinks
  class Engine < ::Rails::Engine

    initializer 'magic_links.url_helpers' do
      ActiveSupport.on_load(:action_controller) do
        include MagicLinks::MagicLinksHelper
      end
    end

    initializer 'magic_links.middleware_redirect', before: :build_middleware_stack do |app|
      app.config.middleware.insert_after ActionDispatch::Cookies, MagicLinks::Middleware::MagicTokenRedirect
    end

  end
end
