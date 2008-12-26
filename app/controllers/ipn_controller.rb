class IpnController < ApplicationController
  protect_from_forgery :except => :update

  def update
    txn_id =    params[:txn_id]
    @PayPalLog ||= PPUtils::Audit.getLogger
    @PayPalLog.info "IPN_notify: #{CGI.unescape(params.inspect)}"

    if txn_id.nil?
      @PayPalLog.info "IPN_notify_error: missing txn_id"
      raise_error
    else
      ipn = PPCallers::Ipn.new(request.raw_post)
      if ["VERIFIED", "INVALID"].include?(ipn.result)
        @params = ipn.params
        if @params["test_ipn"] == "1"
          # This is a test in sandbox
        end
        if ["Completed","Denied","Failed","Pending"].include?(@params["payment_status"])
           #add your business logic here
           # For a complete list of valid payment_status, refer to PayPal API Reference
        else
           #Reason to be suspicious
        end
        render :text => '', :status => 204        # 204 for no content
      else
        @PayPalLog.info "IPN_unknown_result: #{ipn.result}"
        raise_error
      end
    end

  rescue Errno::ENOENT => exception
    @PayPalLog.info "IPN_exception: " + exception
    raise_error
  end

  private

  def raise_error
    render :file => "#{RAILS_ROOT}/public/500.html", :status => 500
  end

end
