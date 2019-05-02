class IllustrationHasIllustrators < ActiveRecord::Migration
  def change
    create_join_table :people, :illustrations, table_name: :illustrators_illustrations do |t|
      t.index [:person_id, :illustration_id], name: 'illustrator_illustration_index'
    end
  end
end
