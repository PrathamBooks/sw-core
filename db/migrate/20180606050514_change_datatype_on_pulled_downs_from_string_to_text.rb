class ChangeDatatypeOnPulledDownsFromStringToText < ActiveRecord::Migration
  def change
    change_column :pulled_downs, :reason, :text, :limit => nil
  end
end
