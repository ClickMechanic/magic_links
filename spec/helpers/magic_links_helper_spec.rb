require 'rails_helper'

describe MagicLinks::MagicLinksHelper do
  let(:name) { :test }
  let(:pattern) { '/test/:token' }
  let(:strength) { %i[mild moderate strong].sample }
  let(:action_scope) { { bookings: 'show' }.with_indifferent_access }
  let(:params) { {name: name, pattern: pattern, action_scope: action_scope, strength: strength} }

  describe 'adding a template' do
    subject { described_class.tap { described_class.add_template params } }

    it 'creates a new template with the given name' do
      expect(subject.templates[:test].name).to eq name
    end

    it 'creates a new template with the given pattern' do
      expect(subject.templates[:test].pattern).to eq pattern
    end

    it 'creates a new template with the given e strength' do
      expect(subject.templates[:test].strength).to eq strength
    end

    context 'when the expiry is given' do
      let(:expiry) { [5.hours, 1.day, 2.minutes].sample }

      before { params[:expiry] = expiry }

      it 'creates a new template with the given expiry' do
        expect(subject.templates[:test].expiry).to eq expiry
      end
    end

    context 'when an invalid pattern is given' do
      let(:pattern) { 'invalid/pattern/:token' }

      it 'fails' do
        expect { described_class.add_template params }.to raise_error ArgumentError
      end
    end
  end

  describe '.match?' do
    subject { described_class.tap { described_class.add_template params } }

    context 'for valid tokens' do
      it { is_expected.to be_match('/test/AbCd-123_') }
      it { is_expected.not_to be_match('/xyz/AbCd-123_') }
    end

    context 'for invalid tokens' do
      it { is_expected.not_to be_match('/test/AbCd*123_') }
    end

    context 'with multiple templates' do
      before { subject.add_template params.merge(name: :test2, pattern: '/magic/:token') }

      it { is_expected.to be_match('/test/AbCd-123_') }
      it { is_expected.to be_match('/magic/aBcD_1-23') }
    end
  end

  describe '.token_for' do
    let(:token) { Devise.friendly_token(8) }
    subject { described_class.tap { described_class.add_template params } }

    context 'for valid tokens' do
      it 'returns the given token in a matching path' do
        expect(subject.token_for("/test/#{token}")).to eq token
      end

      it 'returns nil for a non-matching path' do
        expect(subject.token_for("/xyz/#{token}")).to be_nil
      end
    end

    context 'for invalid tokens' do
      let(:token) { "#{Devise.friendly_token}*" }

      it 'returns nil for a matching path' do
        expect(subject.token_for("/test/#{token}")).to be_nil
      end
    end

    context 'with multiple templates' do
      before { subject.add_template params.merge(name: :test2, pattern: '/magic/:token') }

      it 'returns the given token in any matching path' do
        expect(subject.token_for("/test/#{token}")).to eq token
        expect(subject.token_for("/magic/#{token}")).to eq token
      end

      it 'returns nil for a non-matching path' do
        expect(subject.token_for("/xyz/#{token}")).to be_nil
      end
    end
  end

  describe '#magic_link_for' do
    let(:user) { create :user }
    let(:target_path) { '/bookings/1/test' }
    let(:instance) do
      klass = Class.new
      klass.include described_class
      klass.new
    end

    subject do
      described_class.add_template params
      instance.magic_link_for(user, :test, target_path)
      instance
    end

    describe 'MagicToken' do
      subject do
        described_class.add_template params
        instance.magic_link_for(user, :test, target_path)
        MagicLinks::MagicToken.last
      end

      it 'is created for the given target path' do
        expect(subject.target_path).to eq target_path
      end

      it 'is created with the correct action_scope' do
        expect(subject.action_scope).to eq action_scope
      end

      it 'is created with the correct strength' do
        expect(subject.send(:strength)).to eq strength
      end

      context 'when the expiry is given in the template' do
        let(:expiry) { [5.hours, 1.day, 2.minutes].sample }

        around do |example|
          travel_to Time.zone.now do
            example.run
          end
        end

        before { params[:expiry] = expiry }

        it 'is created to expire in the given expiry' do
          expect(subject.expires_at).to eq Time.zone.now + expiry
        end
      end

      context 'when the expiry is overridden' do
        [4.hours, 2.day, 1.minute].each do |expiry|
          context expiry.inspect do
            subject do
              described_class.add_template params
              instance.magic_link_for(user, :test, target_path, expiry)
              MagicLinks::MagicToken.last
            end

            around do |example|
              travel_to Time.zone.now do
                example.run
              end
            end

            it "is created to expire in #{expiry.inspect}" do
              expect(subject.expires_at).to eq Time.zone.now + expiry
            end
          end
        end
      end
    end

    it 'returns a path for the given template and magic token' do
      result = subject.magic_link_for(user, :test, target_path)
      magic_token = MagicLinks::MagicToken.last
      expect(result).to eq "/test/#{magic_token.token}"
    end

    describe '#magic_url_for' do
      let(:pattern) { '/mu/:token' }

      it 'returns a full URL for the given template and magic token' do
        result = subject.magic_url_for(user, :test, target_path)
        magic_token = MagicLinks::MagicToken.last
        expect(result).to eq "http://test.host/mu/#{magic_token.token}"
      end
    end
  end
end
