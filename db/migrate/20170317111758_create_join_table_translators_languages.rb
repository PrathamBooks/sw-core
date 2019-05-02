class CreateJoinTableTranslatorsLanguages < ActiveRecord::Migration
  def change
    create_join_table :users, :languages, table_name: :translators_languages do |t|
      t.index [:user_id, :language_id], name: 'translators_languages_index'    end
  end
end
