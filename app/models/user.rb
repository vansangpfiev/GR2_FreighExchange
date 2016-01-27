class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
  
  def get_detailed_info
    if self.role == "customer"
      Customer.find_by user_id: self.id
    elsif self.role == "supplier"
      Supplier.find_by user_id: self.id
    end
  end

  def active_for_authentication?
    !self.role.nil?
  end

  def inactive_message
    "Sorry, this account is not active."
  end
end
