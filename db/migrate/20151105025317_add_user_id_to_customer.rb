class AddUserIdToCustomer < ActiveRecord::Migration
  def change
    add_column :customer, :u_id, :integer
  end
end
