class Customer::SchedulesController < Customer::BaseController
  def index
    @request = Request.find_by_request_id params[:request_id]
    @schedules = @request.schedules
  end  
end