require 'spec_helper'
require 'resident'

include NationalIdentificationNumber

describe Finnish, 'valid?' do

  it "should recognize valid numbers" do
    Finnish.new('311280-999J').should be_valid
    Finnish.new('131052-308T').should be_valid
    Finnish.new('290164-862u').should be_valid
    Finnish.new('270368A172X').should be_valid
    Finnish.new('310145A586a').should be_valid
    Finnish.new('080266+183P').should be_valid
    Finnish.new('290248+145c').should be_valid
  end

  it "should recognize invalid numbers" do
    Finnish.new('671301A172V').should_not be_valid # valid checksum, invalid month
    Finnish.new('830231A172M').should_not be_valid # valid checksum, invalid day
    Finnish.new('311180-999J').should_not be_valid
    Finnish.new('131052-308S').should_not be_valid
    Finnish.new('290164X862U').should_not be_valid
    Finnish.new('670368A172X').should_not be_valid
    Finnish.new('310145--586A').should_not be_valid
    Finnish.new('asdf').should_not be_valid
    Finnish.new('1234567890').should_not be_valid
    Finnish.new('0000000000000').should_not be_valid
    Finnish.new('000000-0000').should_not be_valid
    Finnish.new('').should_not be_valid
    Finnish.new(1234567890).should_not be_valid
    Finnish.new(:really_bad_input_value).should_not be_valid
  end

end

describe Finnish, 'to_s' do

  it "should repair missing dashes, even if the number is invalid" do
    Finnish.new('311280999K').to_s.should == '311280-999K'
  end

  it "should return the number normalized if the number is valid" do
    Finnish.new('311280999J').to_s.should == '311280-999J'
    Finnish.new('270368A172X  ').to_s.should == '270368A172X'
    Finnish.new('xx270368A172X  ').to_s.should == '270368A172X'
    Finnish.new('xxx270368A172Xt  ').to_s.should == '270368A172X'
    Finnish.new('\t050126-1853').to_s.should == '050126-1853'
  end

  it "should always be injection safe, valid or not" do
    Finnish.new(%Q{270368"A172   \tX}).to_s.should == '270368A172X'
    Finnish.new(%Q{270368"A172\tX\n\n}).to_s.should == '270368A172X'
    Finnish.new(%Q{270368"A172X}).to_s.should == '270368A172X'
    Finnish.new(%Q{270368A<172X}).to_s.should == '270368A172X'
    Finnish.new(%Q{270368A'172X}).to_s.should == '270368A172X'
    Finnish.new(%Q{270368A>172X}).to_s.should == '270368A172X'
  end

end