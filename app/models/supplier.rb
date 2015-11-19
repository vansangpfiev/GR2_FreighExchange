class Supplier < ActiveRecord::Base
	self.table_name = "supplier"
	has_many :vehicles
end