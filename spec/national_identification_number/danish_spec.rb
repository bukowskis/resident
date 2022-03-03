require 'spec_helper'
require 'resident'

describe NationalIdentificationNumber::Danish do
  describe '#valid?' do
    it 'recognizes valid numbers' do
      expect(described_class.new('311257-1735')).to be_valid
      expect(described_class.new('290444-0305')).to be_valid
      expect(described_class.new('300168-0330')).to be_valid
    end

    it 'recognizes invalid numbers' do
      expect(described_class.new('251379-4001')).not_to be_valid # invalid month
      expect(described_class.new('300279-4001')).not_to be_valid # invalid day
      expect(described_class.new('asdf')).not_to be_valid
      expect(described_class.new('1234567890')).not_to be_valid
      expect(described_class.new('0000000000000')).not_to be_valid
      expect(described_class.new('000000-0000')).not_to be_valid
      expect(described_class.new('')).not_to be_valid
      expect(described_class.new(1234567890)).not_to be_valid
      expect(described_class.new(:really_bad_input_value)).not_to be_valid
    end
  end

  describe 'sanitize' do
    context 'with valid numbers' do
      it 'is the formatted number' do
        expect(described_class.new('3112571735').sanitize).to eq '311257-1735'
        expect(described_class.new('290444.0305').sanitize).to eq '290444-0305'
        expect(described_class.new('30.01.68.03.30').sanitize).to eq '300168-0330'
      end
    end

    context 'with invalid numbers' do
      it 'is nil' do
        expect(described_class.new('251379-4001').sanitize).to be_nil
        expect(described_class.new('300279-4001').sanitize).to be_nil
        expect(described_class.new('asdf').sanitize).to be_nil
        expect(described_class.new('1234567890').sanitize).to be_nil
        expect(described_class.new('0000000000000').sanitize).to be_nil
        expect(described_class.new('000000-0000').sanitize).to be_nil
        expect(described_class.new('').sanitize).to be_nil
        expect(described_class.new(1234567890).sanitize).to be_nil
        expect(described_class.new(:really_bad_input_value).sanitize).to be_nil
      end
    end
  end

  describe 'age' do
    before do
      Timecop.freeze Date.parse('2022-03-04')
    end

    it 'recognizes valid numbers' do
      expect(described_class.new('110779-4101').age).to eq 42
      expect(described_class.new('010100-1000').age).to eq 122
      expect(described_class.new('110736-4002').age).to be_nil # Birthday in the future
      expect(described_class.new('030320-5006').age).to eq 2
      expect(described_class.new('110952-3113').age).to eq 69
      expect(described_class.new('211164-2234').age).to eq 57
    end

    it 'is nil for invalid numbers' do
      expect(described_class.new('251379-4001').age).to be_nil # invalid month
      expect(described_class.new('300279-4001').age).to be_nil # invalid day
      expect(described_class.new('asdf').age).to be_nil
      expect(described_class.new('1234567890').age).to be_nil
      expect(described_class.new('0000000000000').age).to be_nil
      expect(described_class.new('000000-0000').age).to be_nil
      expect(described_class.new('').age).to be_nil
      expect(described_class.new(1234567890).age).to be_nil
      expect(described_class.new(:really_bad_input_value).age).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns the number normalized regardless of wether its valid' do
      expect(described_class.new('251.379.4001').to_s).to eq '251379-4001'
    end
  end
end
