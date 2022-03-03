require 'national_identification_number/base'

module NationalIdentificationNumber
  class Danish < Base
    attr_reader :date

    protected

    def repair
      super
      @number.gsub!(/[^0-9]/, '')
      if (matches = @number.match(/\A(?<birthday>[0-9]{6})(?<checksum>[0-9]{4})\z/))
        birthday, checksum = matches.values_at(:birthday, :checksum)
        @number = "#{birthday}-#{checksum}"
      end
    end

    def validate
      if (matches = @number.match(/\A(?<day>\d{2})(?<month>\d{2})(?<year>\d{2})-(?<serial>\d{3})(?<checksum>\d{1})\z/))
        day, month, year, serial, checksum = matches.values_at(:day, :month, :year, :serial, :checksum)
        begin
          @date = Date.parse("#{full_year(serial, year)}-#{month}-#{day}")
          @valid = true
          @number = "#{day}#{month}#{year}-#{serial}#{checksum}"
        rescue ArgumentError
        end
      end
    end

    private

    def full_year(serial, year)
      century(serial, year.to_i) + year.to_i
    end

    def century(serial, year)
      first_digit = serial[0].to_i
      return 1800 if (5..8).include?(first_digit) && year > 57
      return 2000 if (4..9).include?(first_digit) && year < 37
      1900
    end
  end
end
