class Customer::InvoicesController < Customer::BaseController
  before_action :authenticate_user!
  

  def index
  	@invoices = Invoice.where(:request_id => (Request.select(:request_id).where(:customer_id => Customer.select(:customer_id).find_by_user_id(current_user.id))))
  end

  def accept
    @invoice = Invoice.find_by_invoice_id(params[:invoice_id])
    @request = Request.find_by_request_id(:request_id => @invoice.request_id)
    if @invoice.nil?
      flash[:danger] = "No request found"
      redirect_to invoices_path
    else
      @invoice.status = 'accepted'
      @invoice.save
      @request.status = 'pending'
      @request.save
      flash[:notice] = "Successful accept response"
      redirect_to controller: "invoices", action: "index"
    end
  end
end