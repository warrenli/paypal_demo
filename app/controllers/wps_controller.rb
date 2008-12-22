class WpsController < ApplicationController
  before_filter  :get_server_path

  def index
    @return = @serverURL + "/wps/return"
    @cancel_return = @serverURL + "/wps/cancel"
    @notify_url = @serverURL + "/wps/notify"
  end

end
