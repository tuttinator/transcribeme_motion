# TranscribeMe
module TranscribeMe
  # Utility class for constructing SOAP requests
  # Implementing Savon's interface
  class Suds

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

  end
end