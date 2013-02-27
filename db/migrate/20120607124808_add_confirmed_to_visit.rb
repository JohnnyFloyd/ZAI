class AddConfirmedToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :confirmed, :boolean
  end
end
