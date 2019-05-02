# == Schema Information
#
# Table name: albums
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  title      :string(255)
#  story_id   :integer
#

class Album < ActiveRecord::Base
	belongs_to :story
	has_many :illustrations
	has_and_belongs_to_many :users, class_name: 'User', join_table: 'albums_users'
end
