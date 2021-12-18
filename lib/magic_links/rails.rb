module MagicLinks
  class Engine < ::Rails::Engine

    initializer 'magic links url helpers' do
      ActiveSupport.on_load(:action_controller) do
        include MagicLinks::MagicLinksHelper
      end
    end

  end
end
