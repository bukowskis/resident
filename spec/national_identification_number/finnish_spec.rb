require 'spec_helper'
require 'resident'

include NationalIdentificationNumber

describe Finnish, 'valid?' do

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

describe Finnish, 'to_s' do

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