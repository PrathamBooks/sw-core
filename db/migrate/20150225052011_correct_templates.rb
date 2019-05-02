class CorrectTemplates < ActiveRecord::Migration
  def up
    ['sp_h_i100','sp_v_i100'].each do |template|
      spt = StoryPageTemplate.find_by_name(template)
      if(spt)
        spt.image_position='fill'
        spt.content_position='nil'
        spt.save!
      end
    end
  end
  def down
  end
end
