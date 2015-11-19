class Supplier::VehiclesController < Supplier::BaseController
  def index   
   	@vehicles = Vehicle.all
  end

  def show
  	@vehicle = Vehicle.find(params[:id])
  end

  def new
  	@vehicle = Vehicle.new
  end

  def edit
  	
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)

    @request.time = DateTime.strptime(submit_params[:time], '%m/%d/%Y %H:%M %p')
    respond_to do |format|
      if @request.save
        format.html { flash[:success] = 'Your request successfully created.'
          redirect_to customer_requests_path }
        format.json { render :show, status: :created, location: @request }
      else
        format.html { render :new }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  def destroy
  	
  end

  def vehicle_params
      params.require(:vehicle).permit(:vehicle_number, :available, :s_id, :category_id, :cost_per_km)
    end
end
