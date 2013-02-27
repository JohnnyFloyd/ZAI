class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.date :visit_date
      t.integer :client
      t.integer :hairdresser
      t.timestamps
    end
  end
end
