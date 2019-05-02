class AddFlashMessageToContest < ActiveRecord::Migration
  def change
    add_column :contests, :custom_flash_notice, :string
  end
end
