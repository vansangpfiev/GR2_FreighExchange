class Request < ActiveRecord::Base
  self.table_name = "request"

  scope :opened, -> {where status: "none"}

  belongs_to :customer
  has_many :invoice
end
