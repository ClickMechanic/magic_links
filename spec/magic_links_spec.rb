require 'spec_helper'

describe MagicLinks do

  describe '#version' do
    subject { described_class.version }

    it 'returns the version' do
      expect(subject).to eq MagicLinks::VERSION
    end
  end

end
