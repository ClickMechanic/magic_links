module MagicLinks
  class Engine < ::Rails::Engine

    initializer 'magic_links.url_helpers' do
      Rails.application.reloader.to_prepare do
        ActiveSupport.on_load(:action_controller) do
          include MagicLinks::UrlHelper
        end
      end  
    end

    initializer 'magic_links.middleware_redirect', before: :build_middleware_stack do |app|
      app.config.middleware.insert_after ActionDispatch::Cookies, MagicLinks::Middleware::MagicTokenRedirect
    end

    initializer 'magic_links.devise_strategy' do
      Warden::Strategies.add(:magic_token_authentication, MagicLinks::Strategies::MagicTokenAuthentication)
      Devise.setup do |config|
        config.warden do |manager|
          manager.default_strategies(scope: :user).unshift :magic_token_authentication
        end
      end
    end
  end
end
