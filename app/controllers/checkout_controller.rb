class CheckoutController < ApplicationController
  def index
    @host=request.host.to_s
    @port=request.port.to_s
    @cancelURL="http://#{@host}:#{@port}/checkout/index"
    @returnURL="http://#{@host}:#{@port}/ec/get_ec_details"
  end
end
