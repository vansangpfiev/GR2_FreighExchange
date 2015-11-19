class Supplier::BaseController < ApplicationController
	def index   
   	@suppliers = Supplier.all
  end

  def show
  	@suppliers = Supplier.find(params[:id])
  end

  def new
  	@supplier = Supplier.new
  	@vehicle = Vehicle.new
  end

  def edit
  	
  end
end

