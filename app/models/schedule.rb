class Schedule < ActiveRecord::Base
  self.table_name = "schedule"
  belongs_to :request
end