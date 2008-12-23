# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd54213a4a3f922715d3e2fdf4d8dee5c'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  def get_server_path
    @host=request.host.to_s
    @port=request.port.to_s
    @serverURL="http://#{@host}"
    @serverURL = @serverURL + ":#{@port}"  unless @port == "80"
  end

  def clear_session_data
    session[:ec_response] = nil
    session[:ec_final] = nil
  end

  def dump_params(method)
    puts "\n*** Invoking " + method
    puts "   Parameters"
    for k,v in params
       puts "#{k}: #{v}" unless ( "#{k}" == "ec")
    end

    puts "\n  ec Parameters" if params[:ec]
    for k1,v1 in params[:ec]
      puts "#{k1}: #{v1}"
    end if params[:ec]

    puts "*****************************\n\n"
  end

  def dump_response(response, method)
    puts "\n*** Invoking " + method
    puts "   Response"
    for k,v in response
       puts "#{k}: #{v}"
    end
    puts "*****************************\n\n"
  end

  def dump_options(options)
    puts "\n*** Options "
    for k,v in options
       puts "#{k}: #{v}"
    end
    puts "*****************************\n\n"
  end
end
