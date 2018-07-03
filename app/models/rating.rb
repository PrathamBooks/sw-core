# == Schema Information
#
# Table name: ratings
#
#  id            :integer          not null, primary key
#  rateable_id   :integer
#  rateable_type :string(255)
#  user_id       :integer
#  user_comment  :string(255)
#  user_rating   :float
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_ratings_on_rateable_id_and_rateable_type  (rateable_id,rateable_type)
#

class Rating < ActiveRecord::Base
	
	validates :user_rating, presence: true

	belongs_to :rateable, polymorphic: true
	belongs_to :user

	def user_and_comment
      "<strong>#{user.name}</storng>-#{user_rating}<br/><p>#{user_comment}</p><hr/>".html_safe
	end
end
