# == Schema Information
#
# Table name: list_likes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  list_id    :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_list_likes_on_list_id_and_user_id  (list_id,user_id)
#

class ListLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :list
end
