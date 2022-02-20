require 'rails_helper'

describe MagicLinks::MiddleWare::MagicTokenRedirect do
  let(:app) { ->() { [200, {'Content-Type' => 'text/plain'}, ['OK']] } }
  let(:magic_token) { create :magic_token }
  let(:pattern) { "/#{('a'..'z').to_a.sample(2).join}/:token" }
  let(:path) { pattern.sub(':token', magic_token.token) }
  let(:request) { Rack::MockRequest.new(subject) }

  before { MagicLinks::MagicLinksHelper.add_template(name: :test, pattern: pattern, action_scope: magic_token.action_scope, strength: :mild) }

  subject { described_class.new(app) }

  context 'when the magic token is present' do
    # The middleware depends on ActionDispatch::Cookies middleware.
    # The following ensures the relevant `action_dispatch` env settings are in place
    # to support calls to ActionDispatch::Request
    let(:request) do
      ActionDispatch::TestRequest.create.tap do |request|
        request.path = path
      end
    end

    it 'redirects to the target path' do
      response = Rack::MockResponse.new(*subject.call(request.env))
      expect(response.status).to eq 302
      expect(response.header['Location']).to eq magic_token.target_path
    end

    it 'sets the token as a signed cookie for the given scope' do
      # the cookie itself is written by ActionDispatch::Cookies middleware
      # which acts on the response after MagicTokenRedirect.
      # Therefore we need only test that our middleware sets the cookie via ActionDispatch
      Rack::MockResponse.new(*subject.call(request.env))
      expect(request.cookie_jar.signed[:user_magic_token]).to eq magic_token.token
    end

    context 'when the authenticatable target no longer exists' do
      before { magic_token.magic_token_authenticatable.delete }

      it 'does not set a cookie' do
        Rack::MockResponse.new(*subject.call(request.env))
        expect(request.cookie_jar.to_hash).to be_empty
      end
    end
  end

  context 'when path is not a magic token' do
    let(:path) { '/test/path' }

    it 'forwards to the next app' do
      response = request.get(path)
      expect(response.status).to eq 200
      expect(response.body).to eq 'OK'
    end
  end

  context 'when the corresponding magic token does not exist' do
    let(:path) { pattern.sub(':token', 'abcd1234') }

    it 'redirects to the home page' do
      response = request.get(path)
      expect(response.status).to eq 302
      expect(response.header['Location']).to eq '/'
    end
  end

  describe MagicLinks::Middleware::MagicTokenRedirect::Handler do
    let(:env) {
      {
        'PATH_INFO' => path
      }
    }
    let(:handler) { described_class.new(env) }

    subject { handler }

    describe 'path' do
      subject { handler.path }

      it 'matches the path' do
        expect(subject).to eq path
      end
    end

    describe 'token' do
      subject { handler.token }

      it 'matches the token given in the path' do
        expect(subject).to eq magic_token.token
      end

      context 'with an invalid path' do
        let(:path) { '/xyz/cdef1234'}

        it { is_expected.to be_nil }
      end
    end

    describe 'magic_token' do
      subject { handler.magic_token }

      it 'matches the token for the path' do
        expect(subject).to eq magic_token
      end

      context 'with an invalid token' do
        let(:path) { pattern.sub(':token', 'abcd1234') }

        it { is_expected.to be_nil }
      end
    end

    describe 'scope' do
      let(:user) { create :user }

      before do
        magic_token.magic_token_authenticatable = user
        magic_token.save!
      end

      it 'returns the sybmolized name of the authenticatable scope' do
        expect(subject.scope).to be :user
      end
    end
  end
end
