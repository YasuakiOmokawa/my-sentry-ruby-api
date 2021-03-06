require 'httmultiparty'
require 'json'

module SentryApi
  # @private
  class Request
    include HTTMultiParty

    format :json
    headers "Content-Type" => "application/json"
    parser proc { |body, _| parse(body) }
    attr_accessor :auth_token, :endpoint, :default_org_slug

    # Converts the response body to an ObjectifiedHash.
    def self.parse(body)
      body = decode(body)

      if body.is_a? Hash
        ObjectifiedHash.new body
      elsif body.is_a? Array
        if body[0].is_a? Array
          body
        else
          PaginatedResponse.new(body.collect! { |e| ObjectifiedHash.new(e) })
        end
      elsif body
        true
      elsif !body
        false
      elsif body.nil?
        false
      else
        raise Error::Parsing.new "Couldn't parse a response body"
      end
    end

    # Decodes a JSON response into Ruby object.
    def self.decode(response)
      JSON.load response
    rescue JSON::ParserError
      raise Error::Parsing.new "The response is not a valid JSON"
    end

    def get(path, options={})
      set_httparty_config(options)
      set_authorization_header(options)
      validate self.class.get(@endpoint + path, options)
    end

    def post(path, options={})
      set_httparty_config(options)
      set_json_body(options)
      set_authorization_header(options, path)
      validate self.class.post(@endpoint + path, options)
    end

    def put(path, options={})
      set_httparty_config(options)
      set_json_body(options)
      set_authorization_header(options)
      validate self.class.put(@endpoint + path, options)
    end

    def delete(path, options={})
      set_httparty_config(options)
      set_authorization_header(options)
      validate self.class.delete(@endpoint + path, options)
    end

    def upload(path, options={})
      set_httparty_config(options)
      set_authorization_header(options)
      validate self.class.post(@endpoint + path, options)
    end

    # Checks the response code for common errors.
    # Returns parsed response for successful requests.
    def validate(response)
      error_klass = case response.code
                      when 400 then
                        Error::BadRequest
                      when 401 then
                        Error::Unauthorized
                      when 403 then
                        Error::Forbidden
                      when 404 then
                        Error::NotFound
                      when 405 then
                        Error::MethodNotAllowed
                      when 409 then
                        Error::Conflict
                      when 422 then
                        Error::Unprocessable
                      when 500 then
                        Error::InternalServerError
                      when 502 then
                        Error::BadGateway
                      when 503 then
                        Error::ServiceUnavailable
                    end
      fail error_klass.new(response) if error_klass

      parsed = response.parsed_response
      parsed.client = self if parsed.respond_to?(:client=)
      parsed.parse_headers!(response.headers) if parsed.respond_to?(:parse_headers!)
      parsed
    end

    # Sets a base_uri and default_params for requests.
    # @raise [Error::MissingCredentials] if endpoint not set.
    def set_request_defaults
      self.class.default_params
      raise Error::MissingCredentials.new("Please set an endpoint to API") unless @endpoint
    end

    private

    # Sets a Authorization header for requests.
    # @raise [Error::MissingCredentials] if auth_token and auth_token are not set.
    def set_authorization_header(options, path=nil)
      unless path == '/session'
        raise Error::MissingCredentials.new("Please provide a auth_token for user") unless @auth_token
        options[:headers] = {'Authorization' => "Bearer #{@auth_token}"}
      end
    end

    # Set http post or put body as json string if content type is application/json
    def set_json_body(options)
      headers = self.class.headers
      if headers and headers["Content-Type"] == "application/json"
        options[:body] = options[:body].to_json
      end
    end

    # Set HTTParty configuration
    # @see https://github.com/jnunemaker/httparty
    def set_httparty_config(options)
      options.merge!(httparty) if httparty
    end
  end
end
