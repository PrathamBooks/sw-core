class CreateFooterImages < ActiveRecord::Migration
  def change
    create_table :footer_images do |t|
      t.belongs_to :illustration
      t.timestamps
    end
  end
end
