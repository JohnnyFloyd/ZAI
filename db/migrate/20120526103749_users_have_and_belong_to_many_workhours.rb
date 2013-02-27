class UsersHaveAndBelongToManyWorkhours < ActiveRecord::Migration
  /def self.up
    create_table :users_workhours, :id => false do |t|
      t.integer :user_id
      t.integer :workhour_id
      t.references :user, :workhour
    end
  end

  def self.down
    drop_table :users_workhours
  end/
  
  def change
    create_table :users_workhours, :id => false do |t|
      t.integer :user_id
      t.integer :workhour_id
    end
  end
end
