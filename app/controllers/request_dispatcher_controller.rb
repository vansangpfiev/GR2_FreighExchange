class RequestDispatcherController < ApplicationController
  before_action :authenticate_user!

  def main
    case current_user.role
    when "admin"
      redirect_to controller: "admin/home", action: "index"
    when "customer"
      redirect_to root_path
    when "supplier"
      redirect_to root_path
    when nil      
      @error_code = "502"
      @message = "Your account is not accessable, contact to admin!"
      render "error_pages/error"
    else
      @error_code = "405"
      @message = "Method not allowed"
      render "error_pages/error"  
    end
  end
end
