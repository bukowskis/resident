require 'spec_helper'
require 'resident'

include NationalIdentificationNumber

describe Finnish do
  describe '#valid?' do
    it "recognizes valid numbers" do
      expect( Finnish.new('311280-999J') ).to be_valid
      expect( Finnish.new('131052-308T') ).to be_valid
      expect( Finnish.new('290164-862u') ).to be_valid
      expect( Finnish.new('270368A172X') ).to be_valid
      expect( Finnish.new('310145A586a') ).to be_valid
      expect( Finnish.new('080266+183P') ).to be_valid
      expect( Finnish.new('290248+145c') ).to be_valid
    end

    it "recognizes invalid numbers" do
      expect( Finnish.new('671301A172V') ).to_not be_valid # valid checksum, invalid month
      expect( Finnish.new('830231A172M') ).to_not be_valid # valid checksum, invalid day
      expect( Finnish.new('311180-999J') ).to_not be_valid
      expect( Finnish.new('131052-308S') ).to_not be_valid
      expect( Finnish.new('290164X862U') ).to_not be_valid
      expect( Finnish.new('670368A172X') ).to_not be_valid
      expect( Finnish.new('310145--586A') ).to_not be_valid
      expect( Finnish.new('asdf') ).to_not be_valid
      expect( Finnish.new('1234567890') ).to_not be_valid
      expect( Finnish.new('0000000000000') ).to_not be_valid
      expect( Finnish.new('000000-0000') ).to_not be_valid
      expect( Finnish.new('') ).to_not be_valid
      expect( Finnish.new(1234567890) ).to_not be_valid
      expect( Finnish.new(:really_bad_input_value) ).to_not be_valid
    end
  end

  describe 'sanitize' do
    context 'valid numbers' do
      it 'is the formatted number' do
        expect(Finnish.new('311280-999J').sanitize).to eq '311280-999J'
        expect(Finnish.new('131052-308T').sanitize).to eq '131052-308T'
        expect(Finnish.new('290164-862u').sanitize).to eq '290164-862U'
        expect(Finnish.new('270368A172X').sanitize).to eq '270368A172X'
        expect(Finnish.new('310145A586a').sanitize).to eq '310145A586A'
        expect(Finnish.new('080266+183P').sanitize).to eq '080266+183P'
        expect(Finnish.new('290248+145c').sanitize).to eq '290248+145C'
      end
    end

    context 'invalid numbers' do
      it 'is nil' do
        expect(Finnish.new('671301A172V').sanitize).to be nil
        expect(Finnish.new('830231A172M').sanitize).to be nil
        expect(Finnish.new('311180-999J').sanitize).to be nil
        expect(Finnish.new('131052-308S').sanitize).to be nil
        expect(Finnish.new('290164X862U').sanitize).to be nil
        expect(Finnish.new('670368A172X').sanitize).to be nil
        expect(Finnish.new('310145--586A').sanitize).to be nil
        expect(Finnish.new('asdf').sanitize).to be nil
        expect(Finnish.new('1234567890').sanitize).to be nil
        expect(Finnish.new('0000000000000').sanitize).to be nil
        expect(Finnish.new('000000-0000').sanitize).to be nil
        expect(Finnish.new('').sanitize).to be nil
        expect(Finnish.new(1234567890).sanitize).to be nil
        expect(Finnish.new(:really_bad_input_value).sanitize).to be nil
      end
    end
  end

  describe 'age' do

    before do
      Timecop.freeze Date.parse('2014-05-20')
    end

    it "recognizes valid numbers" do
      expect( Finnish.new('230118-999H').age ).to eq 96
      expect( Finnish.new('311280-999J').age ).to eq 33
      expect( Finnish.new('131052-308T').age ).to eq 61
      expect( Finnish.new('290164-862u').age ).to eq 50
      expect( Finnish.new('270368A172X').age ).to be_nil # Birthday in the future
      expect( Finnish.new('310145A586a').age ).to be_nil # Birthday in the future
      expect( Finnish.new('080266+183P').age ).to eq 148
      expect( Finnish.new('290248+145c').age ).to eq 166
    end

    it "is nil for invalid numbers" do
      expect( Finnish.new('671301A172V').age ).to be_nil
      expect( Finnish.new('830231A172M').age ).to be_nil
      expect( Finnish.new('311180-999J').age ).to be_nil
      expect( Finnish.new('131052-308S').age ).to be_nil
      expect( Finnish.new('290164X862U').age ).to be_nil
      expect( Finnish.new('670368A172X').age ).to be_nil
      expect( Finnish.new('310145--586A').age ).to be_nil
      expect( Finnish.new('asdf').age ).to be_nil
      expect( Finnish.new('1234567890').age ).to be_nil
      expect( Finnish.new('0000000000000').age ).to be_nil
      expect( Finnish.new('000000-0000').age ).to be_nil
      expect( Finnish.new('').age ).to be_nil
      expect( Finnish.new(1234567890).age ).to be_nil
      expect( Finnish.new(:really_bad_input_value).age ).to be_nil
    end
  end

  describe '#to_s' do

    it "repairs missing dashes, even if the number is invalid" do
      expect( Finnish.new('311280999K').to_s ).to eq '311280-999K'
    end

    it "returns the number normalized if the number is valid" do
      expect( Finnish.new('311280999J').to_s ).to eq '311280-999J'
      expect( Finnish.new('270368A172X  ').to_s ).to eq '270368A172X'
      expect( Finnish.new('xx270368A172X  ').to_s ).to eq '270368A172X'
      expect( Finnish.new('xxx270368A172Xt  ').to_s ).to eq '270368A172X'
      expect( Finnish.new('\t050126-1853').to_s ).to eq '050126-1853'
    end

    it "is always injection safe, valid or not" do
      expect( Finnish.new(%Q{270368"A172   \tX}).to_s ).to eq '270368A172X'
      expect( Finnish.new(%Q{270368"A172\tX\n\n}).to_s ).to eq '270368A172X'
      expect( Finnish.new(%Q{270368"A172X}).to_s ).to eq '270368A172X'
      expect( Finnish.new(%Q{270368A<172X}).to_s ).to eq '270368A172X'
      expect( Finnish.new(%Q{270368A'172X}).to_s ).to eq '270368A172X'
      expect( Finnish.new(%Q{270368A>172X}).to_s ).to eq '270368A172X'
    end

  end
end
