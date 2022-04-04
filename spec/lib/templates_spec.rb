require 'rails_helper'

describe MagicLinks::Templates do
  let(:name) { 'test_name' }
  let(:pattern) { '/test/:token' }
  let(:strength) { MagicLinks::MagicToken::TOKEN_STRENGTHS.keys.sample }
  let(:action_scope) { {customer: :dashboard} }
  let(:expiry) { 1.day }
  let(:params) { {name: name, pattern: pattern, action_scope: action_scope, strength: strength, expiry: expiry} }

  describe 'adding a template' do
    subject { described_class.add params }

    it 'creates a new template with the given values' do
      subject
      expect(described_class.find(name)).to have_attributes(pattern: pattern,
                                                            action_scope: action_scope,
                                                            strength: strength,
                                                            expiry: expiry)
    end

    context 'when an invalid pattern is given' do
      let(:pattern) { 'invalid/pattern/:token' }

      it 'fails' do
        expect { described_class.add params }.to raise_error ArgumentError
      end
    end
  end

  describe '.match?' do
    subject { described_class.tap { described_class.add params } }

    context 'for valid tokens' do
      it { is_expected.to be_match(pattern.sub(':token', 'test_token')) }
      it { is_expected.not_to be_match('/some_page/test_token') }
    end

    context 'for invalid tokens' do
      it { is_expected.not_to be_match(pattern.sub(':token', 'AbCd*123_')) }
    end

    context 'with multiple templates' do
      before { subject.add params.merge(name: :test2, pattern: '/magic/:token') }

      it { is_expected.to be_match('/test/test_token') }
      it { is_expected.to be_match('/magic/test_token') }
    end
  end

  describe '.token_for' do
    let(:token) { Devise.friendly_token(8) }
    subject { described_class.tap { described_class.add params } }

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
      before { subject.add params.merge(name: :test2, pattern: '/magic/:token') }

      it 'returns the given token in any matching path' do
        expect(subject.token_for("/test/#{token}")).to eq token
        expect(subject.token_for("/magic/#{token}")).to eq token
      end

      it 'returns nil for a non-matching path' do
        expect(subject.token_for("/xyz/#{token}")).to be_nil
      end
    end
  end
end
