class WpsController < ApplicationController
  before_filter  :get_server_path
  protect_from_forgery :except => :ewp_return

  def index
    # @return = @serverURL + "/wps/return"   this is used when PDT is disabled
    @cancel_return = @serverURL + "/wps/cancel"
    @return = @serverURL + "/pdt/update"
    @notify_url = ""
  end

  def ewp_init
  end

  def ewp_buy
    dump_params("ewp_buy")

=begin         Single Item
    @item_name     = params[:item_name]
    @item_number   = params[:item_number]
    @currency_code = params[:currency_code]
    @amount        = params[:amount]
    @invoce        = params[:invoice]
    @custom        = params[:custom]
    cart  = {
              :item_name     => @item_name,
              :item_number   => @item_number,
              :currency_code => @currency_code,
              :amount        => @amount,
              :invoce        => @invoce,
              :custom        => @custom,
            }
    @cmd           = '_xclick'
=end

    @cmd      = "_cart"
    @upload   = "1"

    @charset  = "UTF-8"
    @business               = MY_BUSINESS_EMAIL_ADDRESS
    @cert_id                = MY_BUSINESS_EWP_CERT_ID
    # @return = @serverURL + "/wps/ewp_return"   this is used when PDT is disabled
    @cancel_return = @serverURL + "/wps/cancel"
    @return = @serverURL + "/pdt/update"
    @notify_url = ""
    data = {
             :cmd            => @cmd,
             :upload         => @upload,

             :charset        => @charset,
             :business       => @business,
             :cert_id        => @cert_id,
             :return         => @return,
             :cancel_return  => @cancel_return,
             :notify_url     => @notify_url
            }

    data.merge!(params)
#   Single Item
#   @data.merge!(cart)

    dump_options(data)

    @paypal_cert            ||= File::read(PAYPAL_CERT_PATH)
    @my_business_ewp_cert   ||= File::read(MY_BUSINESS_EWP_CERT_PATH)
    @my_business_ewp_key    ||= File::read(MY_BUSINESS_EWP_KEY_PATH)
    password                  = MY_BUSINESS_PRIVATE_KEY_PWD

    @button = PP_WPS::EWPServices.encrypt_button(@paypal_cert, @my_business_ewp_cert, @my_business_ewp_key, password, data)

  end


  def ewp_return
    puts "***** "
    puts "*** Invoking ewp_return method"
    puts "***   POST method "  if request.post?
    puts "***   GET method "   if request.get?
    puts "***** "
  end

  def return
    puts "***** "
    puts "*** Invoking return method"
    puts "***   POST method "  if request.post?
    puts "***   GET method "   if request.get?
    puts "***** "
  end
end
