require 'national_identification_number/base'

module NationalIdentificationNumber
  class Norwegian < Base
    attr_reader :date

    protected

    def repair
      super
      @number.gsub!(/[^0-9]/, '')
    end

    def validate
      if (matches = @number.match(/\A(?<day>\d{2})(?<month>\d{2})(?<year>\d{2})(?<serial>\d{3})(?<checksum>\d{2})\z/))
        day, month, year, serial, checksum = %i[day month year serial checksum].map { |group| matches[group] }

        sans_checksum = "#{day}#{month}#{year}#{serial}"

        if checksum == calculate_checksum(sans_checksum)
          begin
            @date = Date.parse("#{full_year(serial, year)}-#{month}-#{day}")
            @valid = true
            @number = "#{sans_checksum}#{checksum}"
          rescue ArgumentError
          end
        end
      end
    end

    private

    def full_year(serial, year)
      century(serial) + year.to_i
    end

    def century(serial)
      case serial.to_i
      when 0..499 then 1900
      else 2000 # or 1800, not possible to tell.
      end
    end

    def calculate_checksum(number)
      digits = number.split('').map(&:to_i)
      w1 = [3, 7, 6, 1, 8, 9, 4, 5, 2]
      w2 = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2]

      k1 = weighted_modulo_11(digits.zip(w1))
      k2 = weighted_modulo_11([*digits, k1].zip(w2))
      "#{k1}#{k2}"
    end

    def weighted_modulo_11(digits_and_weights)
      result = 11 - (digits_and_weights.map do |terms|
                       terms.reduce(:*)
                     end.reduce(:+) % 11)
      result > 9 ? 0 : result
    end
  end
end
