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

  def app_dispatcher
    app_name = params[:app_name];
    if app_name == "delivery"
      if current_user.role == "customer"
        redirect_to customer_requests_path
      elsif current_user.role == "supplier"
        redirect_to supplier_profile_path
      else
        @error_code = "401"
        @message = "Unauthorized request."
        render "error_pages/error"
      end
    else
      @error_code = "###"
      @message = "Application currently developing."
      render "error_pages/error"
    end
  end
end
