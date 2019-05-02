class AddTypeToStoryReads < ActiveRecord::Migration
  def change
    add_column :story_reads, :read_type, :integer
  end
end
