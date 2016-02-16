class Request < ActiveRecord::Base
  self.table_name = "request"

  after_create :create_notification

  scope :opened, -> {where status: "none"}
  scope :get_all, -> {where.not status: "deleted"}

  belongs_to :customer
  has_many :invoices
  has_many :notifications, as: :targetable

  def create_notification
    user_customer_id = Customer.find_by_customer_id(self.customer_id).user_id
    byebug
    self.notifications.create! user_id: user_customer_id, 
      message: "Your request has been recorded!", 
      level: "user",
      is_read: false
  end
end
