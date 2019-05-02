class AddIsPulledDownToIllustration < ActiveRecord::Migration
  def change
    add_column :illustrations, :is_pulled_down, :boolean,  default: false
  end
end
