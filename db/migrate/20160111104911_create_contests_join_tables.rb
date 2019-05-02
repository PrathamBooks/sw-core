class CreateContestsJoinTables < ActiveRecord::Migration
  def change
  	create_table :contests_illustrations do |t|
      t.integer :illustration_id
      t.integer :contest_id
    end

    create_table :contests_languages do |t|
      t.integer :language_id
      t.integer :contest_id
    end
    
    add_column :stories, :contest_id, :integer
  end
end
