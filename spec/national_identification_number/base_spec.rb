require 'spec_helper'
require 'national_identification_number/base'

class TestBaseChild < NationalIdentificationNumber::Base
  def set_valid_to_nil
    @valid = nil
  end

  protected

  def validate
    @valid = 'validates_to_true'
  end
end

describe NationalIdentificationNumber::Base do

  describe '#initialize' do

    it "instantiates correctly" do
      expect( TestBaseChild.new('12345') ).to be_an_instance_of TestBaseChild
    end

    it "repairs on initialization" do
      expect( TestBaseChild.new(' 12345abc ').to_s ).to eq '12345ABC'
    end

    it "validates on initialization" do
      expect { NationalIdentificationNumber::Base.new('12345') }.to raise_error(RuntimeError, 'You need to implement at least this method in subclasses.')
    end

  end

  describe '#valid?' do

    it "should return true if it is valid" do
      expect( TestBaseChild.new('12345abc') ).to be_valid
    end

    it "should return true if it is valid" do
      base = TestBaseChild.new('12345abc')
      base.set_valid_to_nil
      expect( base ).to_not be_valid
    end

  end

  describe '#to_s' do

    it "should return the number" do
      expect( TestBaseChild.new('12345ABC').to_s ).to eq '12345ABC'
    end

  end

  describe '#repair' do

    it "should be a protected method" do
      expect { TestBaseChild.new('12345').repair }.to raise_error NoMethodError
    end

    it "should strip whitespaces and capitalize everything" do
      expect( TestBaseChild.new(' 123  45  abc %&/ ').to_s ).to eq '12345ABC%&/'
    end

    it "should make it a string" do
      expect( TestBaseChild.new(:symbol).to_s ).to eq 'SYMBOL'
      expect( TestBaseChild.new(1234).to_s ).to eq '1234'
      expect( TestBaseChild.new(nil).to_s ).to eq ''
    end

    it "should strip newlines and tabs" do
      expect( TestBaseChild.new("one\ntwo\tthree\n").to_s ).to eq 'ONETWOTHREE'
    end
  end

end
