# == Schema Information
#
# Table name: list_categories
#
#  id         :integer          not null, primary key
#  name       :string(32)       not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_list_categories_on_name  (name)
#

class ListCategory < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 32 }

  has_and_belongs_to_many :lists
  translates :name, :translated_name
end
