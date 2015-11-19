class Vehicle < ActiveRecord::Base
	self.table_name = "vehicle"
	belongs_to :supplier
end