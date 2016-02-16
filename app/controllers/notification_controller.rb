class NotificationController < ApplicationController
  before_action :authenticate_user!

  def index   
  end

  def show
    @current_message = Notification.find_by_notification_id params[:id]
  end
end