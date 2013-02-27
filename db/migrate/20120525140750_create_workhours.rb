class CreateWorkhours < ActiveRecord::Migration
  def change
    create_table :workhours do |t|
      t.integer :day
      t.integer :hour

      t.timestamps
    end
  end
end
