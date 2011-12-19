require 'spec_helper'
require 'resident'

include NationalIdentificationNumber

describe Swedish, '.generate' do

  it "should generate valid numbers" do
    50.times { Swedish.new(Swedish.generate).should be_valid } # I know, it feels weird :)
  end

end

describe Swedish, 'valid?' do

  it "should recognize valid numbers" do
    Swedish.new("19180123-2669").should be_valid
    Swedish.new("00180123-2669").should be_valid
    Swedish.new("000180123-2669").should be_valid
    Swedish.new("050126-1853").should be_valid
    Swedish.new("0asdfghj501261853").should be_valid
    Swedish.new("050112-2451").should be_valid
    Swedish.new("450202-6950").should be_valid
    Swedish.new("19450202-6950").should be_valid
  end

  it "should recognize invalid numbers" do
    Swedish.new("991301-1236").should_not be_valid # valid checksum, invalid month
    Swedish.new("830231-5554").should_not be_valid # valid checksum, invalid day
    Swedish.new("050112--2451").should_not be_valid
    Swedish.new("123456-1239").should_not be_valid
    Swedish.new("180123-2668").should_not be_valid
    Swedish.new("150D1261853").should_not be_valid
    Swedish.new("750112-2451").should_not be_valid
    Swedish.new("123").should_not be_valid
    Swedish.new("000000-0000").should_not be_valid
    Swedish.new("0000000000").should_not be_valid
    Swedish.new("asdfghj").should_not be_valid
    Swedish.new("").should_not be_valid
    Swedish.new(12345678).should_not be_valid
    Swedish.new(:really_bad_input).should_not be_valid
  end

end

describe Swedish, 'to_s' do

  it "should repair missing dashes and a superfluous century, even if the number is invalid" do
    Swedish.new('1234561239').to_s.should == '123456-1239'
    Swedish.new('123456-1239').to_s.should == '123456-1239'
    Swedish.new("191234561239").to_s.should == '123456-1239'
    Swedish.new("19123456-1239").to_s.should == '123456-1239'
  end

  it "should return the number normalized if the number is valid" do
    Swedish.new('0501261853').to_s.should == '050126-1853'
    Swedish.new('050126-1853').to_s.should == '050126-1853'
    Swedish.new("190501261853").to_s.should == '050126-1853'
    Swedish.new("19050126-1853").to_s.should == '050126-1853'
    Swedish.new("19050126-185d3").to_s.should == '050126-1853'
    Swedish.new("19050126-185d3\n").to_s.should == '050126-1853'
  end

  it "should always be injection safe, valid or not" do
    Swedish.new("    180 123  -  2669 \n\n\t").to_s.should == '180123-2669'
    Swedish.new("    180 123  -  2669 \n").to_s.should == '180123-2669'
    Swedish.new(%Q{180123-"2669}).to_s.should == '180123-2669'
    Swedish.new(%Q{180123-<2669}).to_s.should == '180123-2669'
    Swedish.new(%Q{1801D23-'2669}).to_s.should == '180123-2669'
    Swedish.new(%Q{180s123->2669}).to_s.should == '180123-2669'
    Swedish.new(%Q{19180s123->2669}).to_s.should == '180123-2669'
  end

end

describe Swedish, 'date' do # For testing only, no public API

  it "should recognize babies born today" do
    today = Date.today.strftime("%y%m%d")
    born_today = Swedish.new("#{today}-000#{Swedish.luhn_algorithm("#{today}000")}")
    born_today.should be_valid
    born_today.date.should == Date.today
  end

  it "should recognize babies born yesterday" do
    today = (Date.today - 1).strftime("%y%m%d")
    born_yesterday = Swedish.new("#{today}-000#{Swedish.luhn_algorithm("#{today}000")}")
    born_yesterday.should be_valid
    born_yesterday.date.should == (Date.today - 1)
  end

  it "should recognize people born in the year 2000" do
    beginning_of_year = Swedish.new("000101-0008")
    beginning_of_year.should be_valid
    beginning_of_year.date.should == Date.new(2000, 1, 1)
    leap_year = Swedish.new("000229-0005") # 2000 was a leap year, 1900 not
    leap_year.should be_valid
    leap_year.date.should == Date.new(2000, 2, 29)
    end_of_year = Swedish.new("001231-0009")
    end_of_year.should be_valid
    end_of_year.date.should == Date.new(2000, 12, 31)
  end

  it "should recognize people born in the year 1999" do
    beginning_of_year = Swedish.new("990101-0000")
    beginning_of_year.should be_valid
    beginning_of_year.date.should == Date.new(1999, 1, 1)
    end_of_year = Swedish.new("991231-0001")
    end_of_year.should be_valid
    end_of_year.date.should == Date.new(1999, 12, 31)
  end

  it "should recognize all other people less than 100 years old" do
    will_turn_99_this_year = Date.new(Date.today.year - 99, 12, 31).strftime("%y%m%d")
    soon_99 = Swedish.new("#{will_turn_99_this_year}-000#{Swedish.luhn_algorithm("#{will_turn_99_this_year}000")}")
    soon_99.should be_valid
    soon_99.date.should == Date.new(Date.today.year - 99, 12, 31)
    turned_99_this_year = Date.new(Date.today.year - 99, 1, 1).strftime("%y%m%d")
    already_99 = Swedish.new("#{turned_99_this_year}-000#{Swedish.luhn_algorithm("#{turned_99_this_year}000")}")
    already_99.should be_valid
    already_99.date.should == Date.new(Date.today.year - 99, 1, 1)
  end

  it "should recognize people that turn 100 years in this year" do
    will_turn_100_this_year = Date.new(Date.today.year - 100, 12, 31).strftime("%y%m%d")
    soon_100 = Swedish.new("#{will_turn_100_this_year}+000#{Swedish.luhn_algorithm("#{will_turn_100_this_year}000")}")
    soon_100.should be_valid
    soon_100.date.should == Date.new(Date.today.year - 100, 12, 31)
    turned_100_this_year = Date.new(Date.today.year - 100, 1, 1).strftime("%y%m%d")
    already_100 = Swedish.new("#{turned_100_this_year}+000#{Swedish.luhn_algorithm("#{turned_100_this_year}000")}")
    already_100.should be_valid
    already_100.date.should == Date.new(Date.today.year - 100, 1, 1)
  end

  it "should recognize people older than 100 years born after 1900" do
    normal = Swedish.new("010101+0007")
    normal.should be_valid
    normal.date.should == Date.new(1901, 1, 1)
  end

  it "should recognize people older than 100 years born before 1900" do
    normal = Swedish.new("991231+0001")
    normal.should be_valid
    normal.date.should == Date.new(1899, 12, 31)
  end

end