class DAL
  def self.callProc
    record_array = ActiveRecord::Base.connection.execute("select contain_routing(105.8469019, 21.0243218, 105.8440137, 21.0285599);")
    return record_array
  end
end