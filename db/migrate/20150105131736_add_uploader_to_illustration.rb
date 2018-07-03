class AddUploaderToIllustration < ActiveRecord::Migration
  def change
    change_table :illustrations do |t|
      t.belongs_to :uploader
    end
  end
end
