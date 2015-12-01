class Supplier::RequestsController < Supplier::BaseController
  before_action :authenticate_user!

  def show
    @request = Request.find params[:id]
    @breadcrumb = [current_user.role,"detailed request"]
    render "share/request/show"
  end
end
