# == Schema Information
#
# Table name: textboxes
#
#  id                    :integer          not null, primary key
#  content               :text
#  textbox_position_left :decimal(5, 2)
#  textbox_position_top  :decimal(5, 2)
#  textbox_width         :decimal(5, 2)
#  textbox_height        :decimal(5, 2)
#  page_id               :integer
#  page_type             :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  root_textbox_id       :integer
#  textbox_type          :integer          default(0)
#  background_color      :integer          default(100)
#  boundary              :boolean          default(FALSE)
#
# Indexes
#
#  index_textboxes_on_page_id_and_page_type  (page_id,page_type)
#  index_textboxes_on_root_textbox_id        (root_textbox_id)
#

class Textbox < ActiveRecord::Base
  belongs_to :page, polymorphic: true
  belongs_to :root_textbox, class_name: "Textbox"

  def width
    return 20 unless textbox_width
    textbox_width < 100 ? textbox_width : 100
  end

  def height
    return 20 unless textbox_height
    textbox_height < 100 ? textbox_height : 100
  end

  def position_left
    if !(textbox_position_left && textbox_position_left > 0)
      return 0
    end
    textbox_position_left + width > 100 ? 100 - width : textbox_position_left
  end

  def position_top
    if !(textbox_position_top && textbox_position_top > 0)
      return 0
    end
    textbox_position_top + height > 100 ? 100 - height : textbox_position_top
  end

  def textbox_duplicate
    textbox = self.dup
    textbox.root_textbox = self
    textbox.content = nil
    return textbox
  end

  def sanitised_content
    Sanitize.clean(content).strip
  end

  def background_color_format
    "rgba(255, 255, 255, #{ background_color.to_f * 0.01 })"
  end

  def textbox_content_present
    content = Nokogiri::HTML(self.content).content.to_s.strip
    content.present?
  end
end
