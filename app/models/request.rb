class Request < ActiveRecord::Base
  self.table_name = "request"

  scope :opened, -> {where status: "none"}
  scope :get_all, -> {where.not status: "deleted"}

  belongs_to :customer
  has_many :invoices
end
