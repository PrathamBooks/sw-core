class ChangeColumnHomeRecommended < ActiveRecord::Migration
  def change
    'ALTER TABLE stories ALTER COLUMN home_recommended TYPE integer USING (home_recommended::integer)'
    rename_column :stories, :home_recommended, :recommended_status
  end
end
