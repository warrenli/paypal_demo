class CheckoutController < ApplicationController
  before_filter  :get_server_path

  def index
    @cancelURL="#{@serverURL}/checkout/index"
    @returnURL="#{@serverURL}/ec/get_ec_details"
  end

  def index2
    @notifyurl ="#{@serverURL}/ipn/update"
  end
end
