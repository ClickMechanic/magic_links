require 'rails_helper'

describe MagicLinks::Template do
  let(:action_scope) do
    {
      'bookings' => %w[show edit update]
    }
  end
  let(:pattern) { '/test_path/:token' }
  let(:strength) { 'moderate' }
  let(:expiry) { 5.days }
  let(:unit) {
    described_class.new(pattern: pattern,
                        action_scope: action_scope,
                        strength: strength,
                        expiry: expiry)
  }

  describe 'initialization' do
    subject { unit }

    it 'initializes without raising an exception' do
      expect { subject }.to_not raise_error
    end

    context 'when the pattern is invalid' do
      let(:pattern) { 'invalid pattern' }

      it ' raises an ArgumentError' do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#match?' do
    let(:path) { 'test_path' }

    subject { unit.match?(path) }

    it { is_expected.to be false }

    context 'when the path matches the pattern' do
      let(:path) { pattern.sub(':token', 'TestToken') }

      it { is_expected.to be true }
    end
  end

  describe '#token_for' do
    let(:token) { 'TestToken' }
    let(:path) { pattern.sub(':token', token) }

    subject { unit.token_for(path) }

    it 'returns the token contained in the path' do
      expect(subject).to eq token
    end
  end

  describe '#magic_link_for' do
    let(:user) { create(:user) }
    let(:target_path) { '/bookings/1/show' }

    subject { unit.magic_link_for(user, target_path) }

    around do |example|
      travel_to(Time.now) do
        example.run
      end
    end

    it 'creates a MagicToken' do
      expect { subject }.to change { MagicLinks::MagicToken.count }.by 1
      new_token = MagicLinks::MagicToken.last
      expect(new_token).to have_attributes(magic_token_authenticatable: user,
                                           action_scope: action_scope,
                                           target_path: target_path,
                                           expires_at: expiry.from_now)
    end

    it 'returns a magic link path with the new token' do
      result = subject
      new_token = MagicLinks::MagicToken.last
      expect(result).to eq pattern.sub(':token', new_token.token)
    end

    context 'when an expiry value is provided' do
      let(:expiry_value) { 1.year }

      subject { unit.magic_link_for(user, target_path, expiry_value) }

      it 'creates a token with the provided expiry' do
        expect { subject }.to change { MagicLinks::MagicToken.count }.by 1
        new_token = MagicLinks::MagicToken.last
        expect(new_token).to have_attributes(expires_at: expiry_value.from_now)
      end
    end
  end

  describe '#magic_url_for' do
    let(:user) { double(:user) }
    let(:path) { double(:path) }
    let(:expiry) { double(:expiry) }
    let(:magic_link_path) { '/test_path/test_token' }

    subject { unit.magic_url_for(user, path, expiry) }

    before do
      allow(unit).to receive(:magic_link_for).with(user, path, expiry).and_return magic_link_path
    end

    it 'returns a full URL for the magic token' do
      expect(subject).to eq "http://test.host#{magic_link_path}"
    end
  end
end
