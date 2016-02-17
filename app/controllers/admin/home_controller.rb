require "DAL"
class Admin::HomeController < Admin::BaseController
  def index
    #TEST
    @results = DAL.pgrDijkstraFromAtoB(105.8469019, 21.0243218, 105.849755, 21.021964)
  end

  def checkaction    
    redirect_to admin_home_path
  end
end
