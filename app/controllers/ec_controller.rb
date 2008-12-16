class EcController < ApplicationController
  def set_ec
    @ECRedirectURL = PAYPAL_EC_URL
    clear_session_data
    dump_params("SetExpressCheckout")

    options = {
                :method           => 'SetExpressCheckout',
                :amt              => params[:ec][:amt],
                :currencycode     => params[:ec][:currencycode],
                :paymentaction    => params[:ec][:paymentaction],
                :localecode       => params[:ec][:localecode],
                :cancelurl        => params[:ec][:cancelurl],
                :returnurl        => params[:ec][:returnurl]
              }

    if params[:ec][:pagestyle]
      options.merge!({ :pagestyle => "#{params[:ec][:pagestyle]}" })
    end

    if params[:ec][:shipping_option]
      puts "*** shipping_option: [" + params[:ec][:shipping_option] + "]"
      case params[:ec][:shipping_option].to_s
      when "NoShipping" then
        options.merge!({ :noshipping => "1" })
      when "ReqConfirmShipping" then
        options.merge!({ :reqconfirmshipping => "1" })
      when "AddressOverride" then
        options.merge!({ :addroverride => "1" })
      end
    else
      puts "*** shipping_option is nil"
    end

    dump_options(options)

    @caller = PPCallers::Caller.new(false)
    @transaction = @caller.call( options  )

    dump_response(@transaction.response, "SetExpressCheckout")

    if @transaction.success?
      session[:pp_errors] = nil
      @token = @transaction.response["TOKEN"].to_s
      redirect_to(@ECRedirectURL + @token)
    else
      session[:pp_errors] = @transaction.response
      flash[:notice] = "SetExpressCheckout Failed:" + @transaction.response.inspect
      redirect_to :controller => 'checkout', :action => 'index'
    end

  rescue Errno::ENOENT => exception
    flash[:notice] = "SetExpressCheckout Exception: " + exception
    redirect_to :controller => 'checkout', :action => 'index'
  end

  def get_ec_details
    dump_params("GetExpressCheckoutDetails")
    @token = params[:token]
    @payerid = params[:PayerID]

    options = {
                :method  => 'GetExpressCheckoutDetails',
                :token   => @token,
                :payerid => @payerid
              }

    dump_options(options)

    @caller = PPCallers::Caller.new(false)
    @transaction = @caller.call( options  )

    dump_response(@transaction.response, "GetExpressCheckoutDetails")

    if @transaction.success?
      session[:pp_errors] = nil
      session[:ec_response]=@transaction.response
      redirect_to :action => 'review_response'
    else
      session[:pp_errors] = @transaction.response
      flash[:notice] = "GetExpressCheckoutDetails Failed:" + @transaction.response.inspect
      redirect_to :controller => 'checkout', :action => 'index'
    end

  rescue Errno::ENOENT => exception
    flash[:notice] = "GetExpressCheckoutDetails Exception: " + exception
    redirect_to :controller => 'checkout', :action => 'index'
  end

  def review_response
    @amt           = session[:ec_response]["AMT"]
    @currencycode  = session[:ec_response]["CURRENCYCODE"]
    @token         = session[:ec_response]["TOKEN"]
    @payerid       = session[:ec_response]["PAYERID"]

#    @lastname      = session[:ec_response]["LASTNAME"]
#    @firstname     = session[:ec_response]["FIRSTNAME"]
#    @email         = session[:ec_response]["EMAIL"]
#    @payerstatus   = session[:ec_response]["PAYERSTATUS"]

#    @recipent      = session[:ec_response]["SHIPTONAME"]
#    @addr_line_1   = session[:ec_response]["SHIPTOSTREET"]
#    @addr_line_2   = session[:ec_response]["SHIPTOSTREET2"]
#    @city          = session[:ec_response]["SHIPTOCITY"]
#    @state         = session[:ec_response]["SHIPTOSTATE"]
#    @zip           = session[:ec_response]["SHIPTOZIP"]
#    @country       = session[:ec_response]["SHIPTOCOUNTRYNAME"].to_s + "(" + session[:ec_response]["SHIPTOCOUNTRYCODE"].to_s + ")"
#    @addressstatus = session[:ec_response]["ADDRESSSTATUS"]

#    @handlingamt   = session[:ec_response]["HANDLINGAMT"]
#    @insuranceamt  = session[:ec_response]["INSURANCEAMT"]
#    @shipdiscamt   = session[:ec_response]["SHIPDISCAMT"]
#    @shippingamt   = session[:ec_response]["SHIPPINGAMT"]
#    @taxamt        = session[:ec_response]["TAXAMT"]
  end

  def do_ec_payment
    dump_params("DOExpressCheckoutPayment")
    @token         = params[:ec][:token]
    @payerid       = params[:ec][:payerid]
    @amt           = params[:ec][:amt]
    @currencycode  = params[:ec][:currencycode]

    options = {
                :method        => 'DOExpressCheckoutPayment',
                :token         => @token,
                :payerid       => @payerid,
                :amt           => @amt,
                :currencycode  => @currencycode,
                :paymentaction => 'Sale'
              }

    dump_options(options)

    @caller = PPCallers::Caller.new(false)
    @transaction = @caller.call( options  )

    dump_response(@transaction.response, "DOExpressCheckoutPayment")

    if @transaction.success?
      session[:pp_errors] = nil
      session[:ec_final] = @transaction.response
    else
      session[:pp_errors] = @transaction.response
      flash[:notice] = "DOExpressCheckoutPayment Failed:" + @transaction.response.inspect
    end
    redirect_to :action => 'show_results'

  rescue Errno::ENOENT => exception
    flash[:notice] = "DOExpressCheckoutPayment Exception: " + exception
    redirect_to :controller => 'checkout', :action => 'index'
  end

  def show_results
  
  end

  private
  
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
