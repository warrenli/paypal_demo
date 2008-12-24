class PdtController < ApplicationController

  def update
    @PayPalLog ||= PPUtils::Audit.getLogger
    @PayPalLog.info "PDT_notify: #{CGI.unescape(params.inspect)}"

    @post_back_data = { :cmd => '_notify-synch',
                        :tx  => params[:tx],
                        :at  => MY_BUSINESS_IDENTITY_TOKEN
                      }

    pdt = PPCallers::Pdt.new(@post_back_data)
    @verify_success = false
    if pdt.success?
      @verify_success = true
      @verify_data = pdt.get_params
    else
      flash[:notice] = "Post Back Verification Failed"
    end
  rescue Errno::ENOENT => exception
    flash[:notice] = "Payment Data Transfer Exception: " + exception
    # redirect_to :controller => 'home', :action => 'index'
  end

end

