require 'spec_helper'
require 'resident'

describe NationalIdentificationNumber::Norwegian do
  describe '#valid?' do
    it 'recognizes valid numbers' do
      expect(described_class.new('11077941012')).to be_valid
    end

    it 'recognizes invalid numbers' do
      expect(described_class.new('671301A172V')).not_to be_valid # valid checksum, invalid month
      expect(described_class.new('830231A172M')).not_to be_valid # valid checksum, invalid day
      expect(described_class.new('11077941010')).not_to be_valid
      expect(described_class.new('670368A172X')).not_to be_valid
      expect(described_class.new('310145--586A')).not_to be_valid
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
        expect(described_class.new('11077941012').sanitize).to eq '11077941012'
        expect(described_class.new('11.07.79.410.12').sanitize).to eq '11077941012'
        expect(described_class.new('11 07 79 41012').sanitize).to eq '11077941012'
      end
    end

    context 'with invalid numbers' do
      it 'is nil' do
        expect(described_class.new('11077941010').sanitize).to be_nil
        expect(described_class.new('671301A172V').sanitize).to be_nil
        expect(described_class.new('830231A172M').sanitize).to be_nil
        expect(described_class.new('311180-999J').sanitize).to be_nil
        expect(described_class.new('131052-308S').sanitize).to be_nil
        expect(described_class.new('290164X862U').sanitize).to be_nil
        expect(described_class.new('670368A172X').sanitize).to be_nil
        expect(described_class.new('310145--586A').sanitize).to be_nil
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
      expect(described_class.new('11077941012').age).to eq 42
      expect(described_class.new('01010010000').age).to eq 122
      expect(described_class.new('11077950020').age).to eq 142
      expect(described_class.new('03032050068').age).to eq 2
      expect(described_class.new('11095231138').age).to eq 69
      expect(described_class.new('21116422341').age).to eq 57
    end

    it 'is nil for invalid numbers' do
      expect(described_class.new('671301A172V').age).to be_nil
      expect(described_class.new('830231A172M').age).to be_nil
      expect(described_class.new('311180-999J').age).to be_nil
      expect(described_class.new('131052-308S').age).to be_nil
      expect(described_class.new('290164X862U').age).to be_nil
      expect(described_class.new('670368A172X').age).to be_nil
      expect(described_class.new('310145--586A').age).to be_nil
      expect(described_class.new('asdf').age).to be_nil
      expect(described_class.new('1234567890').age).to be_nil
      expect(described_class.new('0000000000000').age).to be_nil
      expect(described_class.new('000000-0000').age).to be_nil
      expect(described_class.new('').age).to be_nil
      expect(described_class.new(1234567890).age).to be_nil
      expect(described_class.new(:really_bad_input_value).age).to be_nil
    end
  end

  describe '#date' do
    it 'reads the century from the individual number' do
      expect(described_class.new('15010000995').date).to eq Date.new(1900, 1, 15)
      expect(described_class.new('15016549999').date).to eq Date.new(1965, 1, 15)
      expect(described_class.new('15015474960').date).to eq Date.new(1854, 1, 15)
      expect(described_class.new('15019950910').date).to eq Date.new(1899, 1, 15)
      expect(described_class.new('15014099961').date).to eq Date.new(1940, 1, 15)
      expect(described_class.new('15016595052').date).to eq Date.new(1965, 1, 15)
      expect(described_class.new('15019990971').date).to eq Date.new(1999, 1, 15)
      expect(described_class.new('15010099959').date).to eq Date.new(2000, 1, 15)
      expect(described_class.new('15013950951').date).to eq Date.new(2039, 1, 15)
    end

    it 'is invalid when the individual number is never issued for that year' do
      expect(described_class.new('15016589869')).not_to be_valid
      expect(described_class.new('15016575965')).not_to be_valid
      expect(described_class.new('15015374869')).not_to be_valid
    end
  end

  describe '#to_s' do
    it 'returns the number normalized regardless of wether it is valid' do
      expect(described_class.new('311280999J').to_s).to eq '311280999'
      expect(described_class.new('27..036.8A172X  ').to_s).to eq '270368172'
      expect(described_class.new('xx270368A172X  ').to_s).to eq '270368172'
      expect(described_class.new('xxx270368A172Xt  ').to_s).to eq '270368172'
      expect(described_class.new('\t050126-1853').to_s).to eq '0501261853'
    end
  end
end
