class EcController < ApplicationController
  def set_ec
    @ECRedirectURL = PAYPAL_EC_URL
    clear_session_data
    dump_params("SetExpressCheckout")

    options = {
                :method           => 'SetExpressCheckout',
                :paymentaction    => params[:ec][:paymentaction],
                :localecode       => params[:ec][:localecode],
                :cancelurl        => params[:ec][:cancelurl],
                :returnurl        => params[:ec][:returnurl],
                :desc             => params[:ec][:desc],
                :invnum           => params[:ec][:invnum],
                :currencycode     => params[:ec][:currencycode],
                :amt              => params[:ec][:amt],
                :handlingamt      => params[:ec][:handlingamt],
                :insuranceamt     => params[:ec][:insuranceamt],
                :shippingamt      => params[:ec][:shippingamt],
                :shipdiscamt      => params[:ec][:shipdiscamt],
                :taxamt           => params[:ec][:taxamt],
                :itemamt          => params[:ec][:itemamt],
                :l_number0        => params[:ec][:l_number0],
                :l_name0          => params[:ec][:l_name0],
                :l_desc0          => params[:ec][:l_desc0],
                :l_taxamt0        => params[:ec][:l_taxamt0],
                :l_amt0           => params[:ec][:l_amt0],
                :l_qty0           => params[:ec][:l_qty0],
                :l_number1        => params[:ec][:l_number1],
                :l_name1          => params[:ec][:l_name1],
                :l_desc1          => params[:ec][:l_desc1],
                :l_taxamt1        => params[:ec][:l_taxamt1],
                :l_amt1           => params[:ec][:l_amt1],
                :l_qty1           => params[:ec][:l_qty1]
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
        ship_options = {
            :reqconfirmshipping => "1",
            :name               => "#{params[:ec][:name]}",
            :shiptostreet       => "#{params[:ec][:shiptostreet]}",
            :shiptostreet2      => "#{params[:ec][:shiptostreet2]}",
            :shiptocity         => "#{params[:ec][:shiptocity]}",
            :shiptostate        => "#{params[:ec][:shiptostate]}",
            :shiptozip          => "#{params[:ec][:shiptozip]}",
            :shiptocountrycode  => "#{params[:ec][:shiptocountrycode]}"
        }
        options.merge!( ship_options )
      when "AddressOverride" then
        ship_options = {
            :addressoverride    => "1",
            :name               => "#{params[:ec][:name]}",
            :shiptostreet       => "#{params[:ec][:shiptostreet]}",
            :shiptostreet2      => "#{params[:ec][:shiptostreet2]}",
            :shiptocity         => "#{params[:ec][:shiptocity]}",
            :shiptostate        => "#{params[:ec][:shiptostate]}",
            :shiptozip          => "#{params[:ec][:shiptozip]}",
            :shiptocountrycode  => "#{params[:ec][:shiptocountrycode]}"
        }
        options.merge!( ship_options )
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
      flash[:notice] = "SetExpressCheckout Failed: " +
           session[:pp_errors]["L_SHORTMESSAGE0"].to_s + " - " +
           session[:pp_errors]["L_LONGMESSAGE0"].to_s
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
      flash[:notice] = "GetExpressCheckoutDetails Failed: " +
           session[:pp_errors]["L_SHORTMESSAGE0"].to_s + " - " +
           session[:pp_errors]["L_LONGMESSAGE0"].to_s
      redirect_to :controller => 'checkout', :action => 'index'
    end

  rescue Errno::ENOENT => exception
    flash[:notice] = "GetExpressCheckoutDetails Exception: " + exception
    redirect_to :controller => 'checkout', :action => 'index'
  end

  def review_response
#    @token         = session[:ec_response]["TOKEN"]
#    @payerid       = session[:ec_response]["PAYERID"]
#    @currencycode  = session[:ec_response]["CURRENCYCODE"]
#    @amt           = session[:ec_response]["AMT"]

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

end
