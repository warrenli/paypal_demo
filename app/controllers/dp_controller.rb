class DpController < ApplicationController
  def pay
    clear_session_data
    dump_params("DoDirectPayment")

    options = {
                :method             => 'DoDirectPayment',
                :ipaddress          => params["ipaddress"],
                :paymentaction      => params["paymentaction"],
                :returnmfdetails    => params["returnmfdetails"],
                :invnum             => params["invnum"],
                :custom             => params["custom"],
                :desc               => params["desc"],
                :creditcardtype     => params["creditcardtype"],
                :acct               => params["acct"],
                :expdate            => params["date"]["month"] + params["date"]["year"],
                :cvv2               => params["cvv2"],
                :email              => params["email"],
                :firstname          => params["firstname"],
                :lastname           => params["lastname"],
                :street             => params["street"],
                :street2            => params["street2"],
                :city               => params["city"],
                :state              => params["state"],
                :zip                => params["zip"],
                :countrycode        => params["countrycode"],
                :l_number0          => params["l_number0"],
                :l_name0            => params["l_name0"],
                :l_taxamt0          => params["l_taxamt0"],
                :l_amt0             => params["l_amt0"],
                :l_qty0             => params["l_qty0"],
                :l_number1          => params["l_number1"],
                :l_name1            => params["l_name1"],
                :l_taxamt1          => params["l_taxamt1"],
                :l_amt1             => params["l_amt1"],
                :l_qty1             => params["l_qty1"],
                :currencycode       => params["currencycode"],
                :amt                => params["amt"],
                :handlingamt        => params["handlingamt"],
                :insuranceamt       => params["insuranceamt"],
                :shippingamt        => params["shippingamt"],
                :taxamt             => params["taxamt"],
                :itemamt            => params["itemamt"],
                :shiptoname         => params["shiptoname"],
                :shiptostreet       => params["shiptostreet"],
                :shiptostreet2      => params["shiptostreet2"],
                :shiptocity         => params["shiptocity"],
                :shiptostate        => params["shiptostate"],
                :shiptozip          => params["shiptozip"],
                :shiptocountrycode  => params["shiptocountrycode"],
                :notifyurl          => params["notifyurl"]


              }

    dump_options(options)

    @caller = PPCallers::Caller.new(false)
    @transaction = @caller.call( options  )

    dump_response(@transaction.response, "DoDirectPayment")

    if @transaction.success?
      session[:pp_errors] = nil
      session[:dp_response] = @transaction.response
      redirect_to :action => 'show_results'
    else
      session[:pp_errors] = @transaction.response
      flash[:notice] = "DoDirectPayment Failed: " +
           session[:pp_errors]["L_SHORTMESSAGE0"].to_s + " - " +
           session[:pp_errors]["L_LONGMESSAGE0"].to_s
      redirect_to :controller => 'checkout', :action => 'index2'
    end

  rescue Errno::ENOENT => exception
    flash[:notice] = "DoDirectPayment Exception: " + exception
    redirect_to :controller => 'checkout', :action => 'index2'
  end

  def show_results
    puts "***** "
    puts "*** Invoking dp_controller#show_results method"
    puts "***   POST method "  if request.post?
    puts "***   GET method "   if request.get?
    puts "***** "
  end
end
