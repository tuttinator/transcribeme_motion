# TranscribeMe
module TranscribeMe
  # XMLBuilder utility class for SOAP using Cocoa classes
  class XMLBuilder

    attr_reader :options

    DEFAULT_XML_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"

    def initialize(options = {})
      @options = options
    end

  end
end