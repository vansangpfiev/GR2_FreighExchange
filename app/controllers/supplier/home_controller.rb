class Supplier::HomeController < Supplier::BaseController    
  def index
    @breadcrumb = ["Supplier","Home"]
    @requests = Request.all.opened
  end
end
