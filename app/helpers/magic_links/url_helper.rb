module MagicLinks
  module UrlHelper
    class << self
      def magic_link_for(user, template_name, path, expiry = nil)
        template = MagicLinks::Templates.find(template_name)
        raise ArgumentError, 'Template not found' unless template.present?

        template.magic_link_for(user, path, expiry)
      end

      def magic_url_for(user, template_name, path, expiry = nil)
        template = MagicLinks::Templates.find(template_name)
        raise ArgumentError, 'Template not found' unless template.present?

        template.magic_url_for(user, path, expiry)
      end
    end

    def magic_link_for(user, template_name, path, expiry = nil)
      MagicLinks::UrlHelper.magic_link_for(user, template_name, path, expiry)
    end

    def magic_url_for(user, template_name, path, expiry = nil)
      MagicLinks::UrlHelper.magic_url_for(user, template_name, path, expiry)
    end
  end
end
