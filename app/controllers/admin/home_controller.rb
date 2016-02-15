require "DAL"
class Admin::HomeController < Admin::BaseController
  def index
    @results = DAL.callProc()
  end

  def checkaction
    
    redirect_to admin_home_path
  end
end
