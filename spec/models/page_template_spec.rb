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

require 'rails_helper'

describe PageTemplate, :type => :model do
  it "should be able to pick a default" do
    page_template_1 = FactoryGirl.create(:page_template)
    page_template_2 = FactoryGirl.create(:page_template,default: true)
    expect(PageTemplate.default.length).to eql(1)
    expect(PageTemplate.default.first).to eql(page_template_2)
  end

  describe "illustration scale" do
    it "should return scaled size" do
      template = FactoryGirl.create(:page_template, image_position: "left", image_dimension: 60)
      expect(template.scaled_dimension_for_size(800)).to eql(480.0)

      template = FactoryGirl.create(:page_template, image_position: "right", image_dimension: 60)
      expect(template.scaled_dimension_for_size(800)).to eql(480.0)
    end

    it "should return unscaled size when image position is top, bottom or background" do
      template = FactoryGirl.create(:page_template, image_position: "top", image_dimension: 60)
      expect(template.scaled_dimension_for_size(800)).to eql(800)

      template = FactoryGirl.create(:page_template, image_position: "bottom", image_dimension: 60)
      expect(template.scaled_dimension_for_size(800)).to eql(800)

      template = FactoryGirl.create(:page_template, image_position: "background", image_dimension: 60)
      expect(template.scaled_dimension_for_size(800)).to eql(800)
    end

    it "should return scaled size for portrait orientation templates" do
      template = FactoryGirl.create(:page_template, image_position: "left", image_dimension: 60, orientation: "portrait")
      expect(template.scaled_dimension_for_size(800)).to eql(480.0)

      template = FactoryGirl.create(:page_template, image_position: "right", image_dimension: 60, orientation: "portrait")
      expect(template.scaled_dimension_for_size(800)).to eql(480.0)
    end
  end
end
