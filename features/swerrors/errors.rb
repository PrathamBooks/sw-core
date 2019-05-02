module SWErrors
  module PrintDetails
    def print_details
      puts "Error Message :: #{message}"
      puts backtrace.inspect
    end
  end

  class LoginRequiredError < Exception
    include SWErrors::PrintDetails
    attr_accessor :message
    MESSAGE = 'Login Required to proceed further'

    def initialize(message = MESSAGE)
      @message = message
    end
  end

end
