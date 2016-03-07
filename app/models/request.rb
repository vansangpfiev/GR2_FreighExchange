require "DAL"
class Request < ActiveRecord::Base
  self.table_name = "request"

  after_create :create_notification
  after_create :auto_find_best_ways

  scope :opened, -> {where status: "none"}
  scope :get_all, -> {where.not status: "deleted"}

  belongs_to :customer
  has_many :invoices
  has_many :notifications, as: :targetable
  has_many :schedules

  def create_notification
    user_customer_id = Customer.find_by_customer_id(self.customer_id).user_id    
    self.notifications.create! user_id: user_customer_id, 
    message: "Your request has been recorded!", 
    level: "user",
    is_read: false
  end

  #FIXME: Background job, catch exception
  def auto_find_best_ways
    result_1 = DAL.containRouting(self.start_point_long, self.start_point_lat, self.end_point_long, self.end_point_lat)
    if !result_1.nil?
      result_2 = DAL.pgrDijkstraFromAtoB(self.start_point_long, self.start_point_lat, self.end_point_long, self.end_point_lat)
      user_customer_id = Customer.find_by_customer_id(self.customer_id).user_id
      #Create and save schedule to db, level SYSTEM, status none
      #FIXME add more infomation for schedule
      self.schedules.create! level: "system",
        status: "none"
      #Create notification
      self.notifications.create! user_id: user_customer_id, 
        message: "Found #{result_1} nodes in best ways #{result_2}", 
        level: "system",
        is_read: false
    end
  end
end
