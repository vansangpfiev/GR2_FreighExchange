class Customer < ActiveRecord::Base
  self.table_name = "customer"
  has_many :requests
  belongs_to :user
end
