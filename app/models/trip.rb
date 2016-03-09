class Trip < ActiveRecord::Base
  self.table_name = "trip"
  
  belongs_to :schedule
end