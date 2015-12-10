class Supplier::HomeController < Supplier::BaseController
  before_action :authenticate_user!
  
  def index
    @breadcrumb = ["Supplier","Home"]
    @requests = Request.all.opened
  end
end
