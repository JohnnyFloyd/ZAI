class AddRegisterTimeToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :register_time, :datetime
  end
end
