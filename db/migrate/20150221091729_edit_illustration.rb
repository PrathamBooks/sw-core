class EditIllustration < ActiveRecord::Migration
  def change
    remove_column :illustrations,:illustrator_id
  end
end
