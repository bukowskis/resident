require 'date'

module NationalIdentificationNumber
  class Base

    def initialize(number)
      @number = number
      repair
      validate
    end

    def valid?
      !!@valid
    end

    def to_s
      @number
    end

    def sanitize
      to_s if valid?
    end

    def age
      age_for_dob date
    end

    def ==(other)
      other.class == self.class && other&.to_s == to_s
    end

    protected

    # stackoverflow.com/questions/819263
    def age_for_dob(dob)
      today = Time.now.utc.to_date
      return nil unless dob && today >= dob
      today.year - dob.year - ((today.month > dob.month || (today.month == dob.month && today.day >= dob.day)) ? 0 : 1)
    end

    def repair
      @number = @number.to_s.upcase.gsub(/\s/, '')
    end

    def validate
      raise 'You need to implement at least this method in subclasses.'
    end
  end
end
