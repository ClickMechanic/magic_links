# frozen_string_literal: true
module MagicLinks
  module Strategies
    class MagicTokenAuthentication < Devise::Strategies::Base
      def valid?
        magic_token_cookie.present?
      end

      def authenticate!
        return unless magic_token.present? && magic_token.valid?
        return unless valid_devise_mapping?
        return unless permitted_action?

        success!(resource)
      end

      def store?
        false
      end

      def clean_up_csrf?
        false
      end

      private

      def valid_devise_mapping?
        mapping.to == resource.class
      end

      def permitted_action?
        return false unless permitted_controller?

        Array(action_scope[controller]).include? action
      end

      def permitted_controller?
        action_scope.keys.include? controller
      end

      def action_scope
        magic_token.action_scope.with_indifferent_access
      end

      def resource
        magic_token.magic_token_authenticatable
      end

      def magic_token
        @magic_token ||= MagicToken.find_by token: magic_token_cookie
      end

      def magic_token_key
        "#{scope}_magic_token"
      end

      def magic_token_cookie
        @magic_token_cookie ||= cookies.signed[magic_token_key]
      end

      def controller
        params[:controller]
      end

      def action
        params[:action]
      end
    end
  end
end
