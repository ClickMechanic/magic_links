module MagicLinks
  module Templates
    class << self
      def add(name:, pattern:, action_scope:, strength:, expiry: nil)
        templates[name] = Template.new(pattern: pattern,
                                       action_scope: action_scope,
                                       strength: strength,
                                       expiry: expiry)
      end

      def find(name)
        templates[name]
      end

      def match?(path)
        templates.values.any? do |template|
          template.match? path
        end
      end

      def token_for(path)
        templates.values.find { |template| template.match?(path) }&.token_for(path)
      end

      private

      def templates
        @templates ||= {}
      end
    end
  end
end
