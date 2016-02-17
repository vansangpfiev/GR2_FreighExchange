class NotificationController < ApplicationController
  before_action :authenticate_user!

  def index   
  end

  def show    
    @current_message = current_user.notifications.find_by_notification_id params[:id]
    @current_message.is_read = true
    @current_message.save
  end
end