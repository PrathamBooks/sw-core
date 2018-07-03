class IllustrationHasPhotographers < ActiveRecord::Migration
  def change
    create_join_table :users, :illustrations, table_name: :illustrations_photographers do |t|
      t.index [:user_id, :illustration_id], name: 'photographer_illustration_index'
    end
  end
end
