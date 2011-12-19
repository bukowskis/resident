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

    protected

    def repair
      @number = @number.to_s.upcase.gsub(/\s/, '')
    end

    def validate
      raise 'You need to implement at least this method in subclasses.'
    end

  end
end
