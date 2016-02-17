class DAL
  def self.callProc
    record_array = ActiveRecord::Base.connection.execute("select contain_routing(105.8469019, 21.0243218, 105.8440137, 21.0285599);")
    return record_array
  end

  def self.containRouting start_lat, start_lon, end_lat, end_lon
    record_array = ActiveRecord::Base.connection.execute("select contain_routing(#{start_lat}, #{start_lon}, #{end_lat}, #{end_lon});")
    return record_array
  end

  def self.pgrDijkstraFromAtoB start_lat, start_lon, end_lat, end_lon
    record_array = ActiveRecord::Base.connection.execute("select row_to_json(pgr_dijkstra_fromAtoB(#{start_lat}, #{start_lon}, #{end_lat}, #{end_lon}));")
    results = ""
    record_array.values.each do |item|
      hash_arr = JSON.parse(item[0])
      results << hash_arr["name"]
      results << ">>>"
    end
    return results
  end
end