class RemoveImageFromPages < ActiveRecord::Migration
  def change
    remove_attachment :pages, :image
  end
end
