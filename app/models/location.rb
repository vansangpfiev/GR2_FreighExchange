class Location < ActiveRecord::Base
  self.table_name = "location"

  #Return nearest location, if no return nil
  def self.find_nearest_point lat, lon    
    return_tuple = ActiveRecord::Base.connection.execute("select nearest_point(#{lat}, #{lon});");
    if return_tuple.values[0][0].nil?
        return nil
    else
        location_id = return_tuple.values[0][0].to_i
        return self.find_by_location_id location_id
    end
  end
end