module MagicLinks
  class MagicToken < ApplicationRecord
    belongs_to :magic_token_authenticatable, polymorphic: true

    validates :token, presence: true
    validates :target_path, presence: true
    validates :action_scope, presence: true
    validate :token_expiry

    after_initialize :ensure_token
    before_create :ensure_unique_token

    TOKEN_STRENGTHS = {
      mild: 8,
      moderate: 16,
      strong: 32,
    }.with_indifferent_access.freeze

    class << self
      TOKEN_STRENGTHS.each_key do |strength|
        define_method(strength) do |authenticatable, target_path, action_scope|
          MagicToken.new(target_path: target_path, action_scope: action_scope).tap do |token|
            token.magic_token_authenticatable = authenticatable
            token.send(:strength=, strength)
            token.save!
          end
        end
      end

      def for(authenticatable:, target_path:, action_scope:, strength:, expiry: nil)
        send(strength, authenticatable, target_path, action_scope).tap do |token|
          token.expire_in(expiry) if expiry.present?
        end
      end
    end

    def expired?
      expires_at&.past?
    end

    def expire_in(duration)
      update_attribute :expires_at, (Time.zone.now + duration)
      self
    end

    def mild?
      strength == :mild
    end

    def moderate?
      strength == :moderate
    end

    def strong?
      strength == :strong
    end

    def scope
      return unless magic_token_authenticatable.present?

      magic_token_authenticatable.model_name.singular.to_sym
    end

    private

    def token_expiry
      return unless expired?

      errors.add(:base, 'Token has expired')
    end

    def strength=(val)
      self.token = generate_token(val)
    end

    def strength
      token_strength || :moderate
    end

    def token_strength
      return unless token

      case token.length
      when 32..64
        :strong
      when 16..31
        :moderate
      else
        :mild
      end
    end

    def ensure_token
      self.token ||= generate_token(strength)
    end

    def generate_token(strength)
      Devise.friendly_token(TOKEN_STRENGTHS[strength])
    end

    def ensure_unique_token
      self.token ||= generate_token(strength)
      loop do
        return unless MagicToken.where(token: token).first

        self.token = generate_token(strength)
      end
    end
  end
end
