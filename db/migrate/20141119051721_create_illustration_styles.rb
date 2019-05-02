class CreateIllustrationStyles < ActiveRecord::Migration
  def change
    create_table :illustration_styles do |t|
      t.string :name , null: false, limit: 32
            
      t.timestamps
    end
  end
end
