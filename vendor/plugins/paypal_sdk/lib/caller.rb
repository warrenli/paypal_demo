puts "*** Loading paypal caller"

require 'net/http'
require 'net/https'
require 'uri'
#require 'profile'
require 'audit'
# The module has a class and a wrapper method wrapping NET:HTTP methods to simplify calling PayPal APIs.

module PPCallers
  class Caller
    attr_reader :ssl_strict

    # Proxy server information hash
    @@pi=PP_proxy_info
    # merchant credentials hash
    @@cre=PP_credentials
    # client information such as version, source hash
    @@ci=PP_client_info
    # endpoints of PayPal hash
    @@ep=PP_endpoints
    @@PayPalLog=PPUtils::Audit.getLogger

    def initialize(ssl_verify_mode=false)
      @ssl_strict = ssl_verify_mode
      @@headers = {'Content-Type' => 'html/text'}
    end

    def hash2cgiString(h)
      h.each { |key,value| h[key] = CGI::escape(value.to_s) if (value) }
      h.map { |a| a.join('=') }.join('&')
    end
    # This method uses HTTP::Net library to talk to PayPal WebServices.
    # This is the method what merchants should mostly care about.
    # It expects an hash arugment which has the method name and paramter values of a particular PayPal API.
    # It assumes and uses the credentials of the merchant
    # It assumes and uses the client
    # It will also work behind a proxy server.
    # If the calls need be to made via a proxy sever, set USE_PROXY flag to true and specify proxy server and port information.
    def call(requesth)
    # convert hash values to CGI request (NVP) format
      req_data= "#{hash2cgiString(requesth)}&#{hash2cgiString(@@cre)}&#{hash2cgiString(@@ci)}"
      if (@@pi["USE_PROXY"])
        if( @@pi["USER"].nil? || @@pi["PASSWORD"].nil? )
          http = Net::HTTP::Proxy(@@pi["ADDRESS"],@@pi["PORT"]).new(@@ep["SERVER"], 443)
        else
          http = Net::HTTP::Proxy(@@pi["ADDRESS"],@@pi["PORT"],@@pi["USER"], @@pi["PASSWORD"]).new(@@ep["SERVER"], 443)
        end
      else
        http = Net::HTTP.new(@@ep["SERVER"], 443)
      end
      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless ssl_strict
      http.use_ssl        = true
      maskeddata=req_data.sub(/PWD=[^&]*\&/,'PWD=XXXXXX&')
      @@PayPalLog.info "Sent: #{maskeddata}"
      contents, unparseddata = http.post2(@@ep["SERVICE"], req_data, @@headers)
      @@PayPalLog.info "Received: #{CGI.unescape(unparseddata)}"
      data =CGI::parse(unparseddata)
      transaction = Transaction.new(data)
    end
  end
  # Wrapper class to wrap response hash from PayPal as an object and to provide nice helper methods
  class Transaction
    def initialize(data)
     @success = data["ACK"].to_s != "Failure"
     @response = data
   end
    def success?
      @success
    end
    def response
      @response
    end
  end

  class Pdt
    attr_accessor :params
    attr_accessor :success
    @@PayPalLog=PPUtils::Audit.getLogger
    @@pdt = PP_pdt_endpoints

    def initialize(post)
      empty!
      post_back(post)
    end

    def success?
      @success
    end

    def empty!
      @params  = Hash.new
    end

    def get_params
      @params
    end

    def hash2cgiString(h)
      h.each { |key,value| h[key] = CGI::escape(value.to_s) if (value) }
      h.map { |a| a.join('=') }.join('&')
    end

    def post_back(post_data)
      req_data= "#{hash2cgiString(post_data)}"
      http = Net::HTTP.new(@@pdt["SERVER"], 443)
      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl        = true
      response = http.request_post(@@pdt["SERVICE"], req_data)
      rawdata = response.read_body

#      data=CGI::unescape(rawdata)
      response_array = rawdata.split(/\n/)
      @success = response_array[0] == "SUCCESS"
      if @success
        response_array.slice!(0)
        response_array.each do |element|
          part = /=/.match(element)
          if part
            @params["#{part.pre_match}"] = "#{CGI::unescape(part.post_match)}"
          end
        end
        @@PayPalLog.info "PDT_verified: #{@params.inspect}"
      else
        @@PayPalLog.info "PDT_verification_failed: #{CGI::unescape(rawdata.inspect)}"
      end
    end

  end

  class Ipn
    attr_accessor :result
    attr_accessor :params
    @@PayPalLog=PPUtils::Audit.getLogger
    @@pdt = PP_pdt_endpoints

    def initialize(post_data)
      @params  = Hash.new
      parse(post_data)
      post_back(post_data)
    end

    private

    def parse(post_data)
      for line in post_data.split('&')
        key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
        @params[key] = CGI.unescape(value)
      end
    end

    def post_back(post_data)
      @@PayPalLog.info "IPN_post_back: #{post_data}"
      http = Net::HTTP.new(@@pdt["SERVER"], 443)
      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl        = true
      response = http.request_post("#{@@pdt["SERVICE"]}?cmd=_notify-validate", post_data)
      @result = response.read_body
      @@PayPalLog.info "IPN_after_post_back: #{@result}"
    end
  end

end


