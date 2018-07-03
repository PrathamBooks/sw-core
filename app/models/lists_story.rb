# == Schema Information
#
# Table name: lists_stories
#
#  list_id    :integer          not null
#  story_id   :integer          not null
#  id         :integer          not null, primary key
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#  how_to_use :string(750)
#
# Indexes
#
#  index_lists_stories_on_list_id_and_story_id  (list_id,story_id)
#  lists_stories_index                          (list_id,story_id)
#

class ListsStory < ActiveRecord::Base
  belongs_to :story
  belongs_to :list
  validates :story_id, :uniqueness => { :scope => :list_id }
  acts_as_list scope: :list
end
