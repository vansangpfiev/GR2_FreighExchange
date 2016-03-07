class Customer::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_customer

  private
  def validate_customer
    unless current_user.role == "customer"
      flash[:danger] = "Only user can access this page"
      redirect_to "root_path"
    end
  end
end
