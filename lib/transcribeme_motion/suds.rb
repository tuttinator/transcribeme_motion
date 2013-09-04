# TranscribeMe
module TranscribeMe
  # Utility class for constructing SOAP requests
  # Implementing Savon's interface
  class Suds

    # Content type is UTF-8 by default
    CONTENT_TYPE = 'text/xml;charset=UTF-8'

    # 
    attr_reader :endpoint, :namespace

    def initialize(options = {})
      @endpoint, @namespace = options[:endpoint], options[:namespace]
      @soap_action_prefix = "#{@endpoint}/I#{@namespace.match(/\/([A-Za-z]+)\.svc/)[1]}"
    end

    def call(operation, message = {})
      xml_payload = XmlBuilder.new(operation, message)

      BW::HTTP.post(@endpoint, { payload: xml_payload, headers: headers(xml_payload)}) do |response|
        result = XMLReader.dictionaryForXMLData(response.body, error: nil)
        yeild(response) if block_given?
      end

    end


    private

    def remap_recordings(soap_hash)
      soap_hash.map {|a| Hash[a.map { |k,v| [k.sub(/^[a-z]\:/, '').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase.to_sym, v["text"]] }] }
    end

    # By default, +camelize+ converts strings to UpperCamelCase. If the argument
    # to +camelize+ is set to <tt>:lower</tt> then +camelize+ produces
    # lowerCamelCase.
    #
    # +camelize+ will also convert '/' to '::' which is useful for converting
    # paths to namespaces.
    #
    #   'active_model'.camelize                # => "ActiveModel"
    #   'active_model'.camelize(:lower)        # => "activeModel"
    #   'active_model/errors'.camelize         # => "ActiveModel::Errors"
    #   'active_model/errors'.camelize(:lower) # => "activeModel::Errors"
    #
    # As a rule of thumb you can think of +camelize+ as the inverse of
    # +underscore+, though there are cases where that does not hold:
    #
    #   'SSLError'.underscore.camelize # => "SslError"
    def camelize(term, uppercase_first_letter = true)
      string = term.to_s
      if uppercase_first_letter
        string = string.sub(/^[a-z\d]*/) { inflections.acronyms[$&] || $&.capitalize }
      else
        string = string.sub(/^(?:#{inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) { $&.downcase }
      end
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{inflections.acronyms[$2] || $2.capitalize}" }.gsub('/', '::')
    end

    def headers(xml_payload)
      {
        'Content-Type'    => 'text/xml;charset=UTF-8',
        'Content-Length'  => "#{xml_payload.length}",
        'SOAPAction'      => "#{@soap_action_prefix}/#{camelize(operation.to_s)}"
      }
    end

  end
end