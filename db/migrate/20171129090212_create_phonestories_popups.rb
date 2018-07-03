class CreatePhonestoriesPopups < ActiveRecord::Migration
  def change
    create_table :phonestories_popups do |t|
    	t.integer :user_id
    	t.boolean :popup_opened, default: false

      t.timestamps
    end
  end
end
