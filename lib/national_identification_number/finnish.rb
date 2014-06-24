require 'national_identification_number/base'

module NationalIdentificationNumber
  class Finnish < Base

    attr_reader :date

    CHECKSUMS = %w{ 0 1 2 3 4 5 6 7 8 9 A B C D E F H J K L M N P R S T U V W X Y }

    protected

    def repair
      super
      if @number.match(/(\d{6})(\-{0,1})(\d{3})([#{CHECKSUMS.join('')}]{1})/)
        @number = "#{$1}-#{$3}#{$4}"
      else
        @number.gsub!(/[^#{CHECKSUMS.join('')}\-\+]/, '')
      end
    end

    def validate
      if @number.match(/(\d{2})(\d{2})(\d{2})([\-\+A]{0,1})(\d{3})([#{CHECKSUMS.join('')}]{1})/)
        checksum = self.class.calculate_checksum("#{$1}#{$2}#{$3}#{$5}")
        if checksum == $6

          day     = $1.to_i
          month   = $2.to_i
          year    = $3.to_i
          divider ||= $4 ||'-'
          serial  = $5.to_i

          century = case divider
          when '+' then 1800
          when 'A' then 2000
          else          1900
          end

          begin
            @date = Date.parse("#{century+year}-#{month}-#{day}")
            @valid = true
            @number = ("#{$1}#{$2}#{$3}#{divider}#{$5}#{checksum}")
          rescue ArgumentError
          end
        end
      end
    end

    private

    def self.calculate_checksum(number)
      CHECKSUMS[number.to_i % 31]
    end

  end
end
