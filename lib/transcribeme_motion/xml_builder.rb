# TranscribeMe
module TranscribeMe
  # XMLBuilder utility class for SOAP using Cocoa classes
  class XMLBuilder

    attr_reader :options

    def initialize(operation, message = {})
      @operation, @message = operation, message
    end

  end
end