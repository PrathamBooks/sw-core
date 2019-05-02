class AddColumCreditLineToStories < ActiveRecord::Migration
  def change
    remove_column :donors, :credit_line
    add_column :stories, :credit_line, :string
  end
end
