class HomeController < ApplicationController
  before_filter :clear_session_data

  def index
  end
  private

  def clear_session_data
    session[:ec_response] = nil
    session[:ec_final] = nil
    session[:pp_errors] = nil
  end
end
