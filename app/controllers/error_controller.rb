class ErrorController < ApplicationController
  def index
    @error_code = params[:error_code]
    @message = params[:message]
    render "error_pages/error"
  end
end

