# == Schema Information
#
# Table name: page_templates
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  orientation       :string(255)
#  image_position    :string(255)
#  content_position  :string(255)
#  image_dimension   :float
#  content_dimension :float
#  created_at        :datetime
#  updated_at        :datetime
#  type              :string(255)
#  default           :boolean          default(FALSE)
#
# Indexes
#
#  index_page_templates_on_orientation  (orientation)
#

class StoryPageTemplate < PageTemplate
	validates :name, presence: true, uniqueness: true
	validates :orientation, presence: true
	validates :image_position, presence: true
	validates :image_dimension, presence: true
	validates :content_position, presence: true
	validates :content_dimension, presence: true

	def self.get_default_template(story,orientation)
		case story.reading_level
		when "1"
			orientation == 'landscape' ? 
			self.find_by_name("sp_h_iT75_cB25") : 
			self.find_by_name("sp_v_iT50_cB50")
		when "2"
			orientation == 'landscape' ? 
			self.find_by_name("sp_h_iT66_cB33") : 
			self.find_by_name("sp_v_iT66_cB33")
		when "3"
			orientation == 'landscape' ? 
			self.find_by_name("sp_h_iL66_cR33") : 
			self.find_by_name("sp_v_iT50_cB50")
		when "4"
			orientation == 'landscape' ? 
			self.find_by_name("sp_h_iL50_cR50") : 
			self.find_by_name("sp_v_iT50_cB50")
		end
	end
	
end
