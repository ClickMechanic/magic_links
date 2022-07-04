require 'rails_helper'

describe MagicLinks::Strategies::MagicTokenAuthentication do
  let(:action_scope) do
    {
      bookings: %i[show edit update],
      'bookings/availability': :show
    }
  end
  let(:controller) { 'bookings' }
  let(:action) { 'show' }
  let(:magic_token) { create(:magic_token, action_scope: action_scope) }
  let(:request) do
    ActionDispatch::TestRequest.create.tap do |req|
      req.request_parameters = { controller: controller, action: action }
    end
  end
  let(:env) { request.env }

  subject { described_class.new(env, magic_token.scope) }

  describe '#valid?' do
    context 'when there is no cookie for the requested scope' do
      it { is_expected.not_to be_valid }

      context 'when there is a cookie for the requested scope' do
        before { request.cookie_jar.encrypted["#{magic_token.scope}_magic_token"] = magic_token.token }

        it { is_expected.to be_valid }
      end
    end
  end

  describe '#authenticate!' do
    before { request.cookie_jar.encrypted["#{magic_token.scope}_magic_token"] = magic_token.token }

    context 'when all is correct' do
      it 'succeeds with the authenticatable scope' do
        expect(subject).to receive(:success!).with magic_token.magic_token_authenticatable
        subject.authenticate!
      end

      context 'when the action is defined in the singular' do
        let(:controller) { 'bookings/availability'}
        let(:action) { 'show' }

        it 'succeeds with the authenticatable scope' do
          expect(subject).to receive(:success!).with magic_token.magic_token_authenticatable
          subject.authenticate!
        end
      end
    end

    context 'when the magic token does not exist' do
      before { request.cookie_jar.encrypted["#{magic_token.scope}_magic_token"] = SecureRandom.urlsafe_base64(8) }

      it 'does not authenticate' do
        expect(subject).not_to receive(:success!)
        subject.authenticate!
      end
    end

    context 'when the magic token is not valid' do
      before { magic_token.update_attribute :expires_at, Time.zone.now.advance(minutes: -1) }

      it 'does not authenticate' do
        expect(subject).not_to receive(:success!)
        subject.authenticate!
      end
    end

    context 'when the token is for a different authenticatable scope' do
      it 'does not authenticate' do
        subject.tap do |s|
          # set the authenticatable scope to something other than user:
          magic_token.magic_token_authenticatable = create(:booking)
          magic_token.save!
          expect(s).not_to receive(:success!)
          s.authenticate!
        end
      end
    end

    context 'when the controller is not permitted' do
      let(:controller) { 'mechanics' }

      it 'does not authenticate' do
        expect(subject).not_to receive(:success!)
        subject.authenticate!
      end
    end

    context 'when the action is not permitted' do
      let(:action) { 'destroy' }

      it 'does not authenticate' do
        expect(subject).not_to receive(:success!)
        subject.authenticate!
      end
    end
  end

  describe '#store?' do
    it 'is false' do
      expect(subject.store?).to be_falsey
    end
  end
end
