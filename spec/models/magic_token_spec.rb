require 'rails_helper'

describe MagicLinks::MagicToken do
  subject { create :magic_token }

  it { is_expected.to belong_to :magic_token_authenticatable }

  it { is_expected.to validate_presence_of :token }
  it { is_expected.to validate_presence_of :target_path }
  it { is_expected.to validate_presence_of :action_scope }

  describe 'token_generation' do
    it 'automatically generates a moderate secure token' do
      expect(subject.token).not_to be_empty
      expect(subject).to be_moderate
    end

    it 'uses Devise.friendly_token' do
      expected = Devise.friendly_token(16)
      expect(Devise).to receive(:friendly_token).and_return(expected)
      expect(subject.token).to eq expected
    end

    context 'when a token already exists' do
      subject { build :magic_token }

      before { create :magic_token, token: subject.token }

      it 'generates a new token before saving' do
        original_token = subject.token
        subject.save
        expect(subject.token).not_to eq original_token
      end
    end
  end

  describe 'expiry' do
    context 'when the expiry is nil' do
      it { is_expected.not_to be_expired }
      it { is_expected.to be_valid }
    end

    context 'when the expiry is in the future' do
      before { subject.expires_at = Time.zone.now.advance(minutes: 5) }

      it { is_expected.not_to be_expired }
      it { is_expected.to be_valid }
    end

    context 'when the expiry is in past' do
      before { subject.expires_at = Time.zone.now.advance(minutes: -1) }

      it { is_expected.to be_expired }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#expire_in' do
    [5.hours, 1.day, 2.minutes].each do |expiry|
      context expiry.inspect do
        around do |example|
          travel_to Time.zone.now do
            example.run
          end
        end

        it "expires in #{expiry.inspect}" do
          subject.expire_in(expiry)
          expect(subject.expires_at).to eq Time.zone.now + expiry
        end

        it 'returns itself' do
          expect(subject.expire_in(expiry)).to be subject
        end
      end
    end
  end

  describe '.for' do
    let(:user) { create :user }
    let(:dummy) { build :magic_token }
    let(:strength) { %i[mild moderate strong].sample }
    let(:params) { {authenticatable: user, target_path: dummy.target_path, action_scope: dummy.action_scope, strength: strength} }

    subject { described_class.for(params) }

    it 'creates a token of the correct strength' do
      expect(subject).to be_persisted
      expect(subject.send(:strength)).to be strength
    end

    it 'sets the token attributes' do
      expect(subject.magic_token_authenticatable).to eq user
      expect(subject.target_path).to eq dummy.target_path
      expect(subject.action_scope).to eq dummy.action_scope
    end

    context 'when the expiry is specified as' do
      [5.hours, 1.day, 2.minutes].each do |expiry|
        context expiry.inspect do
          subject { described_class.for(params.merge(expiry: expiry)) }

          around do |example|
            travel_to Time.zone.now do
              example.run
            end
          end

          it "sets the token to expire in #{expiry.inspect}" do
            subject.expire_in(expiry)
            expect(subject.expires_at).to eq Time.zone.now + expiry
          end
        end
      end
    end
  end

  describe '.mild' do
    let(:user) { create :user }
    let(:dummy) { build :magic_token }

    subject { described_class.mild(user, dummy.target_path, dummy.action_scope) }

    it 'creates a mild strength token' do
      expect(subject).to be_persisted
      expect(subject).to be_mild
    end

    it 'sets the token attributes' do
      expect(subject.magic_token_authenticatable).to eq user
      expect(subject.target_path).to eq dummy.target_path
      expect(subject.action_scope).to eq dummy.action_scope
    end
  end

  describe '.moderate' do
    let(:user) { create :user }
    let(:dummy) { build :magic_token }

    subject { described_class.moderate(user, dummy.target_path, dummy.action_scope) }

    it 'creates a mild strength token' do
      expect(subject).to be_persisted
      expect(subject).to be_moderate
    end

    it 'sets the token attributes' do
      expect(subject.magic_token_authenticatable).to eq user
      expect(subject.target_path).to eq dummy.target_path
      expect(subject.action_scope).to eq dummy.action_scope
    end
  end

  describe '.moderate' do
    let(:user) { create :user }
    let(:dummy) { build :magic_token }

    subject { described_class.strong(user, dummy.target_path, dummy.action_scope) }

    it 'creates a mild strength token' do
      expect(subject).to be_persisted
      expect(subject).to be_strong
    end

    it 'sets the token attributes' do
      expect(subject.magic_token_authenticatable).to eq user
      expect(subject.target_path).to eq dummy.target_path
      expect(subject.action_scope).to eq dummy.action_scope
    end
  end

  describe 'association with User' do
    let(:user) { create :user }

    before do
      subject.magic_token_authenticatable = user
      subject.save
      subject.reload
    end

    it 'returns the associated user' do
      expect(subject.magic_token_authenticatable).to eq user
    end

    describe 'scope' do
      it 'returns the sybmolized name of the authenticatable scope' do
        expect(subject.scope).to be :user
      end
    end
  end
end
