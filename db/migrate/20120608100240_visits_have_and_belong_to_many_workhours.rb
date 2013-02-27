class VisitsHaveAndBelongToManyWorkhours < ActiveRecord::Migration
  def self.up
    create_table :visits_workhours, :id => false do |t|
      t.references :visit, :workhour
    end
  end

  def self.down
    drop_table :visits_workhours
  end
end
