require 'spec_helper'
require 'national_identification_number/swedish'

include NationalIdentificationNumber

describe Swedish, '.generate' do

  it "generates valid numbers" do
    50.times { expect( Swedish.new(Swedish.generate) ).to be_valid } # I know, it feels weird :)
  end

  describe '#valid?' do

    it "recognizes valid numbers" do
      expect( Swedish.new("19180123-2669") ).to be_valid
      expect( Swedish.new("00180123-2669") ).to be_valid
      expect( Swedish.new("000180123-2669") ).to be_valid
      expect( Swedish.new("050126-1853") ).to be_valid
      expect( Swedish.new("0asdfghj501261853") ).to be_valid
      expect( Swedish.new("050112-2451") ).to be_valid
      expect( Swedish.new("450202-6950") ).to be_valid
      expect( Swedish.new("19450202-6950") ).to be_valid
    end

    it "recognizes invalid numbers" do
      expect( Swedish.new("991301-1236") ).to_not be_valid # valid checksum, invalid month
      expect( Swedish.new("830231-5554") ).to_not be_valid # valid checksum, invalid day
      expect( Swedish.new("050112--2451") ).to_not be_valid
      expect( Swedish.new("123456-1239") ).to_not be_valid
      expect( Swedish.new("180123-2668") ).to_not be_valid
      expect( Swedish.new("150D1261853") ).to_not be_valid
      expect( Swedish.new("750112-2451") ).to_not be_valid
      expect( Swedish.new("123") ).to_not be_valid
      expect( Swedish.new("000000-0000") ).to_not be_valid
      expect( Swedish.new("0000000000") ).to_not be_valid
      expect( Swedish.new("asdfghj") ).to_not be_valid
      expect( Swedish.new("") ).to_not be_valid
      expect( Swedish.new(12345678) ).to_not be_valid
      expect( Swedish.new(:really_bad_input) ).to_not be_valid
    end

  end

  describe '#to_s' do

    it "repair missing dashes and a superfluous century, even if the number is invalid" do
      expect( Swedish.new('1234561239').to_s ).to eq '123456-1239'
      expect( Swedish.new('123456-1239').to_s ).to eq '123456-1239'
      expect( Swedish.new("191234561239").to_s ).to eq '123456-1239'
      expect( Swedish.new("19123456-1239").to_s ).to eq '123456-1239'
    end

    it "return the number normalized if the number is valid" do
      expect( Swedish.new('0501261853').to_s ).to eq '050126-1853'
      expect( Swedish.new('050126-1853').to_s ).to eq '050126-1853'
      expect( Swedish.new("190501261853").to_s ).to eq '050126-1853'
      expect( Swedish.new("19050126-1853").to_s ).to eq '050126-1853'
      expect( Swedish.new("19050126-185d3").to_s ).to eq '050126-1853'
      expect( Swedish.new("19050126-185d3\n").to_s ).to eq '050126-1853'
    end

    it "always be injection safe, valid or not" do
      expect( Swedish.new("    180 123  -  2669 \n\n\t").to_s ).to eq '180123-2669'
      expect( Swedish.new("    180 123  -  2669 \n").to_s ).to eq '180123-2669'
      expect( Swedish.new(%Q{180123-"2669}).to_s ).to eq '180123-2669'
      expect( Swedish.new(%Q{180123-<2669}).to_s ).to eq '180123-2669'
      expect( Swedish.new(%Q{1801D23-'2669}).to_s ).to eq '180123-2669'
      expect( Swedish.new(%Q{180s123->2669}).to_s ).to eq '180123-2669'
      expect( Swedish.new(%Q{19180s123->2669}).to_s ).to eq '180123-2669'
    end

  end

  describe '#date' do

    it "recognizes babies born today" do
      today = Date.today.strftime("%y%m%d")
      born_today = Swedish.new("#{today}-000#{Swedish.luhn_algorithm("#{today}000")}")
      expect( born_today ).to be_valid
      expect( born_today.date).to eq Date.today
    end

    it "recognizes babies born yesterday" do
      today = (Date.today - 1).strftime("%y%m%d")
      born_yesterday = Swedish.new("#{today}-000#{Swedish.luhn_algorithm("#{today}000")}")
      expect( born_yesterday ).to be_valid
      expect( born_yesterday.date ).to eq (Date.today - 1)
    end

    it "recognizes people born in the year 2000" do
      beginning_of_year = Swedish.new("000101-0008")
      expect( beginning_of_year ).to be_valid
      expect( beginning_of_year.date ).to eq Date.new(2000, 1, 1)
      leap_year = Swedish.new("000229-0005") # 2000 was a leap year, 1900 not
      expect( leap_year ).to be_valid
      expect( leap_year.date ).to eq Date.new(2000, 2, 29)
      end_of_year = Swedish.new("001231-0009")
      expect( end_of_year ).to be_valid
      expect( end_of_year.date ).to eq Date.new(2000, 12, 31)
    end

    it "recognizes people born in the year 1999" do
      beginning_of_year = Swedish.new("990101-0000")
      expect( beginning_of_year ).to be_valid
      expect( beginning_of_year.date ).to eq Date.new(1999, 1, 1)
      end_of_year = Swedish.new("991231-0001")
      expect( end_of_year ).to be_valid
      expect( end_of_year.date ).to eq Date.new(1999, 12, 31)
    end

    it "recognizes all other people less than 100 years old" do
      will_turn_99_this_year = Date.new(Date.today.year - 99, 12, 31).strftime("%y%m%d")
      soon_99 = Swedish.new("#{will_turn_99_this_year}-000#{Swedish.luhn_algorithm("#{will_turn_99_this_year}000")}")
      expect( soon_99 ).to be_valid
      expect( soon_99.date ).to eq Date.new(Date.today.year - 99, 12, 31)
      turned_99_this_year = Date.new(Date.today.year - 99, 1, 1).strftime("%y%m%d")
      already_99 = Swedish.new("#{turned_99_this_year}-000#{Swedish.luhn_algorithm("#{turned_99_this_year}000")}")
      expect( already_99 ).to be_valid
      expect( already_99.date ).to eq Date.new(Date.today.year - 99, 1, 1)
    end

    it "recognizes people that turn 100 years in this year" do
      will_turn_100_this_year = Date.new(Date.today.year - 100, 12, 31).strftime("%y%m%d")
      soon_100 = Swedish.new("#{will_turn_100_this_year}+000#{Swedish.luhn_algorithm("#{will_turn_100_this_year}000")}")
      expect( soon_100 ).to be_valid
      expect( soon_100.date ).to eq Date.new(Date.today.year - 100, 12, 31)
      turned_100_this_year = Date.new(Date.today.year - 100, 1, 1).strftime("%y%m%d")
      already_100 = Swedish.new("#{turned_100_this_year}+000#{Swedish.luhn_algorithm("#{turned_100_this_year}000")}")
      expect( already_100 ).to be_valid
      expect( already_100.date ).to eq Date.new(Date.today.year - 100, 1, 1)
    end

    it "recognizes people older than 100 years born after 1900" do
      normal = Swedish.new("010101+0007")
      expect( normal ).to be_valid
      expect( normal.date ).to eq Date.new(1901, 1, 1)
    end

    it "recognizes people older than 100 years born before 1900" do
      normal = Swedish.new("991231+0001")
      expect( normal ).to be_valid
      expect( normal.date ).to eq Date.new(1899, 12, 31)
    end
  end

end