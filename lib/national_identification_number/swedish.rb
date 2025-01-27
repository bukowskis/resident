require 'national_identification_number/base'

module NationalIdentificationNumber
  # Inspired by https://github.com/c7/personnummer/blob/master/lib/personnummer.rb
  # Copyright (c) 2008 Peter Hellberg MIT
  class Swedish < Base
    attr_reader :date # used for testing

    # Generator for valid Swedish personnummer: http://en.wikipedia.org/wiki/Personal_identity_number_(Sweden)
    # By Henrik Nyh <http://henrik.nyh.se> 2009-01-29 under the MIT license.
    def self.generate(date=nil, serial=nil)
      date ||= Date.new(1900+rand(100), 1+rand(12), 1+rand(28))
      serial = serial ? serial.to_s : format("%03d", rand(999)+1)  # 001-999
      date_part = date.strftime('%y%m%d')
      pnr = [date_part, serial].join
      digits = []
      pnr.split('').each_with_index do |n,i|
        digits << n.to_i * (2 - i % 2)
      end
      sum = digits.join.split('').inject(0) {|sum,digit| sum + digit.to_i }
      checksum = 10 - sum % 10
      checksum = 0 if checksum == 10
      "#{date_part}-#{serial}#{checksum}"
    end

    protected

    def parse_twelve_digits
      return unless @number.match(/\A(\d{4})(\d{2})(\d{2})(\d{4})\Z/)
      year = $1
      month = $2
      day = $3
      born = Date.new(year.to_i, month.to_i, day.to_i)
      sep = born < Date.today.prev_year(100) ? '+' : '-'
      @number = "#{year[2..]}#{month}#{day}#{sep}#{$4}"
    rescue Date::Error
      nil
    end

    def repair
      super
      return if parse_twelve_digits

      if @number.match(/\A(\d{0}|\d{2})(\d{6})(\-{0,1})(\d{4})\Z/)
        @number = "#{$2}-#{$4}"
      else
        candidate = @number.gsub(/[^\d\-\+]/, '')
        if candidate.match(/\A(\d{0}|\d{2})(\d{6})(\-{0,1})(\d{4})\Z/)
          @number = "#{$2}-#{$4}"
        else
          @number = candidate
        end
      end
    end

    def validate
      if @number.match(/(\d{2})(\d{2})(\d{2})([\-\+]{0,1})(\d{3})(\d{1})/)
        checksum = self.class.luhn_algorithm("#{$1}#{$2}#{$3}#{$5}")
        if checksum == $6.to_i

           year    = $1.to_i
           month   = $2.to_i
           day     = $3.to_i
           divider = $4 || '-'
           serial  = $5.to_i

           today = Date.today
           if year <= (today.year-2000) && divider == '-'
             century = 2000
           elsif year <= (today.year-2000) && divider == '+'
             century = 1900
           elsif divider == '+'
             century = 1800
           else
             preliminary_age = age_for_dob(Date.parse("#{1900 + year}-#{month}-#{day}")) rescue 0
             if preliminary_age > 99
               # It's unlikely that the person is older than 99, so assume a child when no divider was provided.
               century = 2000
             else
               century = 1900
             end
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

    def self.luhn_algorithm(number)
      multiplications = []
      number.split(//).each_with_index do |digit, i|
        if i % 2 == 0
          multiplications << digit.to_i*2
        else
          multiplications << digit.to_i
        end
      end
      sum = 0
      multiplications.each do |number|
        number.to_s.each_byte do |character|
          sum += character.chr.to_i
        end
      end
      if sum % 10 == 0
        control_digit = 0
      else
        control_digit = (sum / 10 + 1) * 10 - sum
      end
      control_digit
    end
  end
end

# if $0 == __FILE__
#   # Randomize every part
#   puts Bukowskis::NationalIdentificationNumber::Swedish.generate
#   # Use given date, randomize serial
#   puts Bukowskis::NationalIdentificationNumber::Swedish.generate(Date.new(1975,1,1))
#   # Use given date and serial, calculate checksum
#   puts Bukowskis::NationalIdentificationNumber::Swedish.generate(Date.new(1975,1,1), 123)
# end
