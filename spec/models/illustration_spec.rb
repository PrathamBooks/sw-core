# == Schema Information
#
# Table name: illustrations
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  created_at               :datetime
#  updated_at               :datetime
#  image_file_name          :string(255)
#  image_content_type       :string(255)
#  image_file_size          :integer
#  image_updated_at         :datetime
#  uploader_id              :integer
#  attribution_text         :text
#  license_type             :integer
#  image_processing         :boolean
#  flaggings_count          :integer
#  copy_right_year          :integer
#  image_meta               :text
#  cached_votes_total       :integer          default(0)
#  reads                    :integer          default(0)
#  is_pulled_down           :boolean          default(FALSE)
#  publisher_id             :integer
#  copy_right_holder_id     :integer
#  image_mode               :boolean          default(FALSE)
#  storage_location         :string(255)
#  is_bulk_upload           :boolean          default(FALSE)
#  smart_crop_details       :text
#  organization_id          :integer
#  org_copy_right_holder_id :integer
#  album_id                 :integer
#
# Indexes
#
#  index_illustrations_on_album_id            (album_id)
#  index_illustrations_on_cached_votes_total  (cached_votes_total)
#

require 'rails_helper'

describe Illustration, :type => :model do
  it{ should validate_presence_of(:name)}
  it{ should ensure_length_of(:name).is_at_most(255)}

  it{ should validate_presence_of(:illustrators)}

  it{ should belong_to(:uploader).class_name('User') }
  
  #TODO uncomment after incorporating changes in upload
  # it{ should validate_presence_of(:uploader)}

  it {should have_and_belong_to_many(:categories).class_name('IllustrationCategory')}
  it {should have_and_belong_to_many(:styles).class_name('IllustrationStyle')}

  it {should have_attached_file(:image)}
  it {should validate_attachment_presence(:image)}
  it {should validate_attachment_content_type(:image).allowing('image/png').allowing('image/jpeg').rejecting('text/plain')}

  it {should ensure_length_of(:attribution_text).is_at_most(500)}


  it{ should validate_presence_of(:license_type)}
  it{ should define_enum_for(:license_type).with(['CC BY 0', 'CC BY 3.0', 'CC BY 4.0', 'Public Domain']) }

  xit "should give valid image geometry" do
   illustration = FactoryGirl.create(:illustration)
    expect(illustration.image_geometry().to_s).to eq("624x415") # using spec/photos/forest.jpg which has this resolution
  end

  it "should validate uniqueness of name for illustrator" do
    p1 = FactoryGirl.create(:person)
    i1 = FactoryGirl.create(:illustration,illustrators: [p1])
    i2 = FactoryGirl.build(:illustration,illustrators: [p1])
    i2.name=i1.name
    expect(i2).not_to be_valid
  end

  describe "crop generation" do
    let(:illustration) { FactoryGirl.create(:illustration) }
    let(:page) { FactoryGirl.create(:story_page) }
    it "should generate a crop" do
      crop = illustration.process_crop!(page)
      expect(crop.class).to eql(IllustrationCrop)
    end
    it "should crop it 100% if no crop parameters are provided" do
      crop = illustration.process_crop!(page)
      crop_geometry         = Paperclip::Geometry.from_file(crop.image.path).to_s
      illustration_geometry = Paperclip::Geometry.from_file(illustration.image.path).to_s
      expect(crop_geometry).to eql(illustration_geometry)
    end
    xit "should crop as per requirement" do
      crop = illustration.process_crop!(page,10,10,100,200)
      expect(crop.image_geometry(:original_for_web).to_s).to eql('100x200')
    end
    it "should have all the required styles" do
      crop = illustration.process_crop!(page)
      expect(crop.image.styles.keys).to eql([:page_landscape, :page_portrait, :size1, :size2, :size3, :size4, :size5, :size6, :size7, :large])
    end
  end

  it "should respond to category names" do
   illustration = FactoryGirl.create(:illustration)
   expect(illustration).to respond_to(:category_names)
  end

  it "should respond to style names" do
   illustration = FactoryGirl.create(:illustration)
   expect(illustration).to respond_to(:style_names)
  end

  it "should be able to create tags" do
   illustration = FactoryGirl.create(:illustration)
   expect(illustration).to respond_to(:tag_list)
  end
  it "should be able to inform right responsive size given dimension" do
    expect(Illustration.get_style(300)).to eql(:size1)
    expect(Illustration.get_style(359)).to eql(:size2)
    expect(Illustration.get_style(479)).to eql(:size3)
    expect(Illustration.get_style(490)).to eql(:size4)
    expect(Illustration.get_style(767)).to eql(:size5)
    expect(Illustration.get_style(900)).to eql(:size6)
    expect(Illustration.get_style(1365)).to eql(:size7)
  end

  describe "illustrator cases" do
    let (:illustration) { FactoryGirl.build(:illustration) }
    let (:person_with_account) { FactoryGirl.create(:person_with_account) }
    let (:person_with_no_account) { FactoryGirl.create(:person) }
    it "should link to a user with an account" do
      expect(person_with_account.has_account?).to be true
      illustration.illustrators << person_with_account
      expect(illustration.save).to be true
    end
    it "should also be able link to a user with no account" do
      expect(person_with_no_account.has_account?).to be false
      illustration.illustrators << person_with_no_account
      expect(illustration.save).to be true
      expect(illustration.reload.illustrators.first.name).to eql(person_with_no_account.name)
    end
  end
end
