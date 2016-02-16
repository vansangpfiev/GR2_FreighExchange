class ApplicationController < ActionController::Base
# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception
layout :layout_by_resource
before_action :get_message

protected
def layout_by_resource
  if devise_controller?
    "devise_layout"
  else
    "application"
  end
end

def after_sign_in_path_for resource
  dispatcher_path
end

def get_message
  @messages = current_user.notifications.is_not_read
end
end
