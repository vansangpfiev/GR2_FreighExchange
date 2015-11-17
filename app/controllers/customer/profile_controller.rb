class Customer::ProfileController < Customer::BaseController
  def show
    @user = current_user
    @breadcrumb = ["Customer","Profile"]
    render "devise/profile/show"
  end
end
