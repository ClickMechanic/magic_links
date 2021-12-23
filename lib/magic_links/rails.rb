module MagicLinks
  class Engine < ::Rails::Engine

    initializer 'magic links url helpers' do
      ActiveSupport.on_load(:action_controller) do
        include MagicLinks::MagicLinksHelper
      end
    end

    initializer 'magic links middleware', before: :build_middleware_stack do |app|
      app.config.middleware.insert_after ActionDispatch::Cookies, MagicLinks::MagicTokenRedirect
    end

  end
end
