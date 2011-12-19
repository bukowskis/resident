require 'spec_helper'
require 'resident'

include NationalIdentificationNumber

class TestBaseChild < NationalIdentificationNumber::Base
  def set_valid_to_nil
    @valid = nil
  end
  protected
  def validate
    @valid = 'validates_to_true'
  end
end

describe Base, 'new' do

  it "should instantiate correctly" do
    TestBaseChild.new('12345').should be_an_instance_of TestBaseChild
  end

 it "should repair on initialization" do
   TestBaseChild.new(' 12345abc ').to_s.should == '12345ABC'
 end

 it "should validate on initialization" do
   lambda {  NationalIdentificationNumber::Base.new('12345') }.should raise_error(RuntimeError, 'You need to implement at least this method in subclasses.')
 end

end

describe Base, 'valid?' do

  it "should return true if it is valid" do
    TestBaseChild.new('12345abc').should be_valid
  end

  it "should return true if it is valid" do
    base = TestBaseChild.new('12345abc')
    base.set_valid_to_nil
    base.should_not be_valid
  end

end

describe Base, 'to_s' do

  it "should return the number" do
    TestBaseChild.new('12345ABC').to_s.should == '12345ABC'
  end

end

describe Base, 'repair' do

  it "should be a protected method" do
    lambda { TestBaseChild.new('12345').repair }.should raise_error NoMethodError
  end

  it "should strip whitespaces and capitalize everything" do
    TestBaseChild.new(' 123  45  abc %&/ ').to_s.should == '12345ABC%&/'
  end

  it "should make it a string" do
    TestBaseChild.new(:symbol).to_s.should == 'SYMBOL'
    TestBaseChild.new(1234).to_s.should == '1234'
    TestBaseChild.new(nil).to_s.should == ''
  end

  it "should strip newlines and tabs" do
    TestBaseChild.new("one\ntwo\tthree\n").to_s.should == 'ONETWOTHREE'
  end

end
