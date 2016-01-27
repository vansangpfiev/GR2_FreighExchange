require "GoogleAPI"

class Customer::RequestsController < Customer::BaseController
  before_action :authenticate_user!
  before_action :validate_customer

  def index
    @requests = current_user.get_detailed_info.requests
  end

  def show
    @request = current_user.get_detailed_info.requests.find(params[:id])
    render "share/request/show"
  end

  def new
    @request = Request.new    
  end

  def edit
    @request = Request.find params[:id]
  end

  def create
    @request = current_user.get_detailed_info.requests.build submit_params
    
    @request.time = DateTime.strptime(submit_params[:time], '%m/%d/%Y %H:%M %p')
    @request.start_point_lat = submit_params[:start_point_lat].to_f
    @request.start_point_long = submit_params[:start_point_long].to_f
    @request.end_point_lat = submit_params[:end_point_lat].to_f
    @request.end_point_long = submit_params[:end_point_long].to_f
    @request.status = "none"

    distance = GoogleAPI.new().distanceEstimate(@request.start_point_lat,
      @request.start_point_long,
      @request.end_point_lat,
      @request.end_point_long)

    if !distance.nil?
      @request.distance_estimate = distance.to_i
    end

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
    @request = Request.find params[:id]
    # review code
    @request.update_attribute("time", DateTime.strptime(submit_params[:time], '%m/%d/%Y %H:%M %p'))
    @request.save
    respond_to do |format|
      if @request.update(submit_params)
        format.html { flash[:success] = 'Your request successfully updated.'
          redirect_to customer_requests_path }
        format.json { render :show, status: :ok, location: @user_goal }
      else
        format.html { render :edit }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to customer_requests_path,
        flash[:danger] = 'Your request successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def submit_params
    params.require(:request).permit :weight, :goods_type, :height, :length, :capacity, :time, 
      :start_point_lat, :start_point_long, :end_point_lat, :end_point_long, 
        :category_id, :goods_type, :other_description
  end

  def validate_customer
    unless current_user.role == "customer"
      flash[:danger] = "Only user can access this page"
      redirect_to "root_path"
    end
  end

  
end
