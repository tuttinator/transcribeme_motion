# TranscribeMe
module TranscribeMe
  # API Client with methods for interacting with the SOAP API
  class APIClient

    # Public: Returns the session id of the current session
    attr_reader :session_id
    # Public: Returns the expiry time of the current session
    attr_reader :session_expiry_time
    # Public: Returns the underlining Suds object
    attr_reader :soap_client

    WSDL = 'http://transcribeme-api.cloudapp.net/PortalAPI.svc?wsdl=wsdl0'
    ENDPOINT = 'http://transcribeme-api.cloudapp.net/PortalAPI.svc'
    NAMESPACE = 'http://TranscribeMe.API.Web'

    # Public: Initializes the API Client class
    #
    def initialize
      # Note: Suds logging is disabled
      @soap_client = Suds.client(endpoint: ENDPOINT,  namespace: NAMESPACE,
                              soap_version: 1, wsdl: WSDL, log: false)
    end

    # Public: Initializes a session on the API server and stores 
    # the expiry time and the session_id in instance variables
    #
    # Returns the session_id GUID
    def initialize_session
      response = @soap_client.call :initialize_session
      # Without ActiveSupport
      #   1.hour.from_now is 3600 seconds from Time.now
      @session_expiry_time = Time.now + 3600
      @session_id = response.body[:initialize_session_response][:initialize_session_result]
    end

    # Public: Calls the 'SignIn' SOAP action
    #
    # username - a String which corresponds to a TranscribeMe Portal 
    #            account username which can be any valid email address
    # password - a String which is the portal account password
    #
    # Returns a GUID of the Customer ID
    def sign_in(username, password)
      
      # If #login_with is called before we have a session_id instance variable
      # then call initialize_session
      initialize_session unless session_valid?

      # Use Suds to call the 'SignIn' SOAP action
      response = @soap_client.call  :sign_in, 
                              message: {  'wsdl:sessionID'  => @session_id, 
                                          'wsdl:username'   =>  username, 
                                          'wsdl:password'   =>  password }

      # Assign the customer_login_id variable to the string in the SOAP response
      @customer_login_id = response.body[:sign_in_response][:sign_in_result]

    end

    # Public: Calls the 'GetCustomerRecordings' SOAP Action
    #
    # requires the user to be logged in
    #
    # Returns an Array of Hashes of with the properties of recording objects
    def get_recordings
      # raise 'Login first!' unless @customer_login_id

      response = @soap_client.call  :get_customer_recordings, 
                              message: {  'wsdl:sessionID' => session_id }

      @recordings = response.body[:get_customer_recordings_response][:get_customer_recordings_result][:recording_info]                                
    end

    # Public: Calls the 'GetUploadUrl' SOAP Action
    #
    # Returns the upload url as a String
    def get_upload_url
      # raise 'Login first!' unless @customer_login_id

      response = @soap_client.call  :get_upload_url, 
                              message: {  'wsdl:sessionID' => @session_id }
                              
      @upload_url = response.body[:get_upload_url_response][:get_upload_url_result] 
    end

    # Public: Calls the 'TranscribeRecording' SOAP Action
    #
    # recording_id - a String in GUID format
    #
    # Returns the SOAP response Hash
    def transcribe_recording(recording_id)
      # initialize_session unless @session.try :valid?

      response = @soap_client.call :transcribe_recording, 
                             message: { 'wsdl:sessionID'   => @session_id, 
                                        'wsdl:recordingId' => recording_id }

      response.body[:transcribe_recording_response][:transcribe_recording_result]
    end

    # Public: Calls the 'TranscribeRecordingWithPromoCode' SOAP Action
    #
    # recording_id - a String in GUID format
    # promocode    - a String
    #
    # Returns the SOAP response Hash
    def transcribe_recording_using_promocode(recording_id, promocode)
      # initialize_session unless @session.try :valid?
      
      response = @soap_client.call :transcribe_recording_using_promocode, 
                             message: { 'wsdl:sessionID'   => @session_id, 
                                        'wsdl:recordingId' => recording_id,
                                        'wsdl:promoCode'   => promocode }

      response.body[:transcribe_recording_using_promocode_response][:transcribe_recording_using_promocode_result]
    end

    # Public: Calls the 'GetRecordingInfo' SOAP Action
    #
    # recording_id - a String in GUID format
    #
    # Returns the SOAP response Hash
    def get_recording_info(recording_id)
      @soap_client.call :get_recording_info,
                  message: { 'wsdl:sessionID'   => @session_id,
                             'wsdl:recordingID' => recording_id }
    end

    # Public: Calls the 'FinalizeSession' SOAP Action to close 
    # the session on the server
    #
    # Returns the SOAP response Hash
    def finalize_session
      @soap_client.call  :finalize_session, 
                   message: { 'wsdl:sessionID' => @session_id }
    end

    private

    # Private: Checks if the session expiry time has passed
    #
    # Returns a Boolean
    def session_valid?
      @session_expiry_time > Time.now if @session_expiry_time
    end

  end

end