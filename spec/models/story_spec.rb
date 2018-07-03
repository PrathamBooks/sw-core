# encoding: utf-8
# == Schema Information
#
# Table name: stories
#
#  id                        :integer          not null, primary key
#  title                     :string(255)      not null
#  english_title             :string(255)
#  language_id               :integer          not null
#  reading_level             :integer          not null
#  status                    :integer          default(0), not null
#  synopsis                  :string(750)
#  publisher_id              :integer
#  created_at                :datetime
#  updated_at                :datetime
#  ancestry                  :string(255)
#  derivation_type           :string(255)
#  attribution_text          :text
#  recommended               :boolean          default(FALSE)
#  reads                     :integer          default(0)
#  flaggings_count           :integer
#  orientation               :string(255)
#  copy_right_year           :integer
#  cached_votes_total        :integer          default(0)
#  topic_id                  :integer
#  license_type              :string(255)      default("CC BY 4.0")
#  published_at              :datetime
#  downloads                 :integer          default(0)
#  high_resolution_downloads :integer          default(0)
#  epub_downloads            :integer          default(0)
#  chaild_created            :boolean          default(FALSE)
#  dedication                :string(255)
#  recommended_status        :integer
#  more_info                 :string(255)
#  donor_id                  :integer
#  copy_right_holder_id      :integer
#  credit_line               :string(255)
#  contest_id                :integer
#  editor_id                 :integer
#  editor_status             :boolean          default(FALSE)
#  user_title                :boolean          default(FALSE)
#  editor_recommended        :boolean          default(FALSE)
#  revision                  :integer
#  uploading                 :boolean          default(FALSE)
#  images_only               :integer          default(0)
#  text_only                 :integer          default(0)
#  started_translation_at    :datetime
#  is_autoTranslate          :boolean
#  publish_message           :text
#  download_message          :text
#  is_display_inline         :boolean          default(TRUE)
#  organization_id           :integer
#  recommendations           :string(255)
#  dummy_draft               :boolean          default(TRUE)
#
# Indexes
#
#  index_stories_on_ancestry                         (ancestry)
#  index_stories_on_cached_votes_total               (cached_votes_total)
#  index_stories_on_language_id_and_organization_id  (language_id,organization_id)
#

require 'rails_helper'

describe Story, :type => :model do

  it{ should validate_presence_of(:language)}
  it{ should belong_to(:language)}

  it{ should validate_presence_of(:reading_level).with_message(/This field cannot be empty./)}
  it{ should define_enum_for(:reading_level).with(['1', '2', '3', '4']) }

  it{ should have_and_belong_to_many(:categories).class_name('StoryCategory')}

  it{ should have_and_belong_to_many(:authors).class_name('User')}

  it{ should have_many(:pages).class_name('Page')}

  it{ should define_enum_for(:status).with([:draft,:published,:uploaded, :publish_pending, :edit_in_progress, :de_activated, :submitted]) }
  it{ should validate_presence_of(:status)}

  it{ should belong_to(:publisher)}

  it{ should ensure_length_of(:attribution_text).is_at_most(1000)}
 
  it{ should validate_presence_of(:orientation).with_message(/This field cannot be empty./)}
 

  let(:front_cover_page_template) {FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')}
  let(:back_inner_cover_page_template) {FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'landscape')}
  let(:back_cover_page_template) {FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'landscape')}

  context "should validate presence of title when story is published or publish_pending" do
    subject { FactoryGirl.build_stubbed(:story, title: nil ) }
    it { should validate_presence_of(:title) }
    it{ should ensure_length_of(:title).is_at_most(255)}

    subject { FactoryGirl.build_stubbed(:story, title: nil, status: Story.statuses[:publish_pending] ) }
    it { should validate_presence_of(:title) }
    it{ should ensure_length_of(:title).is_at_most(255)}

  end

  context "should not validate presence of title when story is not published" do
    subject { FactoryGirl.build_stubbed(:story, title: nil, status: :draft) }

    it { should_not validate_presence_of(:title) }
  end

  context "should validate presence of synopsis when story is published" do
    subject { FactoryGirl.build_stubbed(:story, synopsis: nil) }

    it { should validate_presence_of(:synopsis) }
    it { should ensure_length_of(:synopsis).is_at_most(750)}
  end
 
  context "should validate presence of copy right year when story is published" do
    subject { FactoryGirl.build_stubbed(:story, copy_right_year: nil ) }

    it { should validate_presence_of(:copy_right_year) }
  end

  context "should not validate presence of categories when story is not published" do
    subject { FactoryGirl.build_stubbed(:story, categories: [], status: :draft) }

    it { should_not validate_presence_of(:categories) }
  end

  context "should not validate presence of synopsis when story is not published" do
    subject { FactoryGirl.build_stubbed(:story, synopsis: nil, status: :draft) }

    it { should_not validate_presence_of(:synopsis) }
    it { should_not ensure_length_of(:synopsis).is_at_most(255)}
  end

  context "should validate presence of english when story is published" do
    subject { FactoryGirl.build_stubbed(:story, english_title: nil) }

    it { should validate_presence_of(:english_title) }
    it { should allow_value("english").for(:english_title) }
    it { should_not allow_value("हिन्दी").for(:english_title) }
    it { should ensure_length_of(:english_title).is_at_most(255)}
  end

  context "should not validate presence of english_title when story is not published" do
    subject { FactoryGirl.build_stubbed(:story, english_title: nil, status: :draft) }

    it { should_not validate_presence_of(:english_title) }
    it { should allow_value("english").for(:english_title) }
    it { should allow_value("हिन्दी").for(:english_title) }
    it { should_not ensure_length_of(:english_title).is_at_most(255)}
  end

  context "should not validate presence of english_title when story's language is english" do
    subject { FactoryGirl.build_stubbed(:story, english_title: nil, language: FactoryGirl.create(:english)) }

    it { should_not validate_presence_of(:english_title) }
    it { should allow_value("english").for(:english_title) }
    it { should allow_value("हिन्दी").for(:english_title) }
    it { should_not ensure_length_of(:english_title).is_at_most(255)}
  end

  context "should not validate presence of authors when story is not published" do
    subject { FactoryGirl.build_stubbed(:story, authors: [], status: :draft) }

    it { should_not validate_presence_of(:authors) }
  end

  context "should validate presence of authors when story is published" do
    subject { FactoryGirl.build_stubbed(:story, authors: []) }

    it { should validate_presence_of(:authors) }
  end

  context "should validate presence of authors when story is publish_pending" do
    subject { FactoryGirl.build_stubbed(:story, status: :publish_pending, authors: []) }

    it { should validate_presence_of(:authors) }
  end

  let(:story) {FactoryGirl.create(:story)}

  it "should concatenate category names" do
    non_fiction = FactoryGirl.build_stubbed(:story_category, name: 'Non-fiction' )
    family_and_friends = FactoryGirl.build_stubbed(:story_category, name: 'Family & Friends' )
    story = FactoryGirl.build_stubbed(:story, categories: [non_fiction, family_and_friends])

    expect(story.category_names).to eql('Non-fiction, Family & Friends')
  end

  it "should concatenate author names" do
    author = FactoryGirl.build_stubbed(:user, first_name: 'Author',last_name: '')
    another_author = FactoryGirl.build_stubbed(:user, first_name: 'Another Author', last_name: '')
    story = FactoryGirl.build_stubbed(:story, authors: [author, another_author])

    expect(story.author_names).to eql('Author, Another Author')
  end

  it "should tell me if there are any illustrators" do
    expect(subject.has_illustrators?).to be false

    story_page = FactoryGirl.build(:story_page)
    generate_illustration_crop(story_page)
    subject.insert_page(story_page)
    expect(subject.has_illustrators?).to be true
  end

  context "scopes" do
    it "should return only uploaded status stories" do
      story_uploaded = FactoryGirl.create(:story, status: Story.statuses[:uploaded])
      story_draft = FactoryGirl.create(:story)
      expect(Story.uploaded).to eq([story_uploaded])
    end
  end

  describe "build" do
    it "should assemble cover pages if required" do
      expect(subject.pages).to be_empty
      subject.build_book
      expect(subject.pages.length).to eql(3)
      expect(subject.pages.any?{|page|page.type=="FrontCoverPage"}).to be_truthy
      expect(subject.pages.any?{|page|page.type=="BackInnerCoverPage"}).to be_truthy
      expect(subject.pages.any?{|page|page.type=="BackCoverPage"}).to be_truthy
    end
    it "should reassemble cover pages if present" do
      expect(subject.pages).to be_empty
      subject.build_book
      expect(subject.pages.length).to eql(3)
      subject.build_book
      expect(subject.pages.length).to eql(3)
    end
    it "should insert the cover pages in the right order" do
      expect(subject.pages).to be_empty
      subject.build_book
      expect(subject.pages[0].type).to eql("FrontCoverPage")
      expect(subject.pages[1].type).to eql("BackInnerCoverPage")
      expect(subject.pages[2].type).to eql("BackCoverPage")
    end
    describe "with templates" do
      it "should apply a default template to cover page" do
        front_cover_page_template
        back_inner_cover_page_template
        back_cover_page_template
        subject.build_book
        expect(subject.pages[0].page_template).to eql(front_cover_page_template)
        expect(subject.pages[-2].page_template).to eql(back_inner_cover_page_template)
        expect(subject.pages[-1].page_template).to eql(back_cover_page_template)
      end
      it "should apply orientation of the front cover" do
        front_cover_page_template
        back_inner_cover_page_template
        back_cover_page_template
        FactoryGirl.create(:front_cover_page_template,default: false,orientation: 'portrait')
        FactoryGirl.create(:back_inner_cover_page_template,default: false,orientation: 'portrait')
        FactoryGirl.create(:back_cover_page_template,default: false,orientation: 'portrait')
        front_cover_page_template_2 = FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'portrait')
        back_inner_cover_page_template_2 = FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'portrait')
        back_cover_page_template_2 = FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'portrait')
        subject.build_book(front_cover_page_template_2)
        expect(subject.pages[0].page_template).to eql(front_cover_page_template_2)
        expect(subject.pages[-2].page_template).to eql(back_inner_cover_page_template_2)
        expect(subject.pages[-1].page_template).to eql(back_cover_page_template_2)
      end
    end
  end

  describe "insert story page" do
    it "should insert between cover pages" do
      front_cover_page_template
      back_inner_cover_page_template
      back_cover_page_template
      story = FactoryGirl.create(:story)
      story.build_book
      expect(story.save).to eq(true)
      story_page = FactoryGirl.build(:story_page)
      story.insert_page(story_page)
      expect(story.save).to eq(true)
      story.reload
      expect(story.pages.length).to eq(4)
      expect(story.pages[1]).to eq(story_page)
    end
    it "should correctly insert multiple pages" do
      front_cover_page_template
      back_inner_cover_page_template
      back_cover_page_template
      story = FactoryGirl.build(:story)
      story.build_book
      expect(story.save).to eq(true)
      story_page_1 = FactoryGirl.build(:story_page)
      story.insert_page(story_page_1)
      story_page_2 = FactoryGirl.build(:story_page)
      story.insert_page(story_page_2)
      expect(story.pages.length).to eq(5)
      expect(story.pages[1]).to eq(story_page_1)
      expect(story.pages[2]).to eq(story_page_2)
    end
  end

  describe "front cover attribution" do
    let(:original_level) { '1' }
    let(:new_level) { '2' }
    let(:story_page_1) { FactoryGirl.build(:story_page) }
    let(:story_page_2) { FactoryGirl.build(:story_page) }
    let(:story_page_3) { FactoryGirl.build(:story_page) }
    let(:original_story) { FactoryGirl.create(:story,reading_level: original_level) }
    let(:new_language) { FactoryGirl.create(:language) }
    let(:new_author) { FactoryGirl.create(:user) }
    let(:translated_story_attributes) do
      FactoryGirl.attributes_for(:story)
      .merge(language_id: new_language.id)
      .merge(reading_level: original_level)
    end
    let(:relevelled_story_attributes) do
      FactoryGirl.attributes_for(:story)
      .merge(language_id: original_story.language.id)
      .merge(reading_level: new_level)
    end
    let(:translated_story) do
      original_story.new_derivation(translated_story_attributes,new_author,new_author)
    end
    let(:relevelled_story) do
      original_story.new_derivation(relevelled_story_attributes,new_author,new_author)
    end
    describe "for authors" do
      it "in case of translations should be authors for original story" do
        expect(translated_story.save).to be true
        expect(translated_story.original_authors).to eq(original_story.authors)
      end
      it "in case of re-levelling should be authors for original story" do
        expect(relevelled_story.save).to be true
        expect(relevelled_story.original_authors).to eq(original_story.authors)
      end
    end
    describe "for illustrators" do
      it "should be identified as per pages illustrated" do
        original_story.insert_page(story_page_1)
        generate_illustration_crop(story_page_1)
        original_story.insert_page(story_page_2)
        generate_illustration_crop(story_page_2)
        expect(original_story.save).to be true
        original_illustrators = [story_page_1.illustration_crop.illustration.illustrators,story_page_2.illustration_crop.illustration.illustrators].flatten
        expect(original_story.illustrators).to eq(original_illustrators)
      end
      it "should avoid duplication" do
        original_story.insert_page(story_page_1)
        generate_illustration_crop(story_page_1)
        original_story.insert_page(story_page_2)
        generate_illustration_crop(story_page_2)
        expect(original_story.save).to be true
        story_page_2.illustration_crop.illustration.illustrators = story_page_1.illustration_crop.illustration.illustrators
        expect(original_story.illustrators).to eq(story_page_1.illustration_crop.illustration.illustrators)
      end
      it "should order alphabetically" do
        original_story.insert_page(story_page_1)
        generate_illustration_crop(story_page_1)
        story_page_1.illustration_crop.illustration.illustrators.first.first_name = "A"
        story_page_1.illustration_crop.illustration.illustrators.first.last_name = "A"
        original_story.insert_page(story_page_2)
        generate_illustration_crop(story_page_2)
        story_page_2.illustration_crop.illustration.illustrators.first.first_name = "Z"
        story_page_2.illustration_crop.illustration.illustrators.first.last_name = "Z"
        original_story.insert_page(story_page_3)
        generate_illustration_crop(story_page_3)
        story_page_3.illustration_crop.illustration.illustrators.first.first_name = "B"
        story_page_3.illustration_crop.illustration.illustrators.first.last_name = "B"
        expect(original_story.save).to be true
        original_illustrators = [
          story_page_1.illustration_crop.illustration.illustrators,
          story_page_3.illustration_crop.illustration.illustrators,
          story_page_2.illustration_crop.illustration.illustrators
        ].flatten
        expect(original_story.illustrators).to eq(original_illustrators)
      end
    end
    describe "for translators" do
      it "should be blank if original story" do
        expect(original_story.is_translation?).to be false
        expect(original_story.translators).to be_empty
      end
      it "should be blank if derivate is only a re-level" do
        expect(relevelled_story.save).to be true
        expect(relevelled_story.reading_level).to_not eq(original_story.reading_level)
        expect(relevelled_story.translators).to be_empty
        expect(relevelled_story.is_translation?).to be false
      end
      it "should be attributed if language has changed" do
        expect(translated_story.save).to be true
        expect(translated_story.language).to_not eq(original_story.language)
        expect(translated_story.translators).to eq([new_author])
        expect(translated_story.is_translation?).to be true
      end
    end
  end

  it "should not return back cover or attribution as editable pages" do
    front_cover_page_template
    back_inner_cover_page_template
    back_cover_page_template
    story = FactoryGirl.create(:story)
    story.build_book
    story_page1 = FactoryGirl.build(:story_page)
    story_page2 = FactoryGirl.build(:story_page)
    story.insert_page(story_page1)
    story.insert_page(story_page2)
    story.reload
    expect(story.editable_pages).to eq([story.cover_page,story_page1,story_page2])
  end

  describe "attributions" do
    before :each do
      Story::MAX_NUMBER_OF_ATTRIBUTIONS_PER_PAGE = 3
      @front_cover_page_template = FactoryGirl.create(:front_cover_page_template, default: true,orientation: 'landscape')
      @back_cover_page_template = FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
      @back_inner_cover_page_template = FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
      @original_story = FactoryGirl.create(:story, status: Story.statuses[:draft])
      @front_cover_page = FactoryGirl.create(:front_cover_page, story: @original_story, page_template: @front_cover_page_template)
      generate_illustration_crop(@front_cover_page)
      @page1 = FactoryGirl.create(:story_page, story: @original_story)
      generate_illustration_crop(@page1)
      @page2 = FactoryGirl.create(:story_page, story: @original_story)
      generate_illustration_crop(@page2)
      @page3 = FactoryGirl.create(:story_page, story: @original_story)
      generate_illustration_crop(@page3)
      @page4 = FactoryGirl.create(:story_page, story: @original_story)
      generate_illustration_crop(@page4)
      @back_inner_cover_page = FactoryGirl.create(:back_inner_cover_page, story: @original_story, page_template: @back_inner_cover_page_template)
      @back_cover_page = FactoryGirl.create(:back_cover_page, story: @original_story, page_template: @back_cover_page_template)
    end

    it "should insert appropriate number of back inner cover pages based on the illustration attributes" do
      @original_story.publish

      @original_story.reload
      expect(@original_story.pages.select{|page| page.type == BackInnerCoverPage.name}.length).to be 2
      expect(@original_story.pages[-3].type).to eql(BackInnerCoverPage.name)
      expect(@original_story.pages[-2].type).to eql(BackInnerCoverPage.name)
      expect(@original_story.pages[-1].type).to eql(BackCoverPage.name)
    end

    it "should consider original story attributions when inserting back inner cover pages" do
      parent_relevelled_story_attributes = FactoryGirl.attributes_for(:story)
      .merge(language_id: @original_story.language.id)
      .merge(reading_level: '2')
      @parent_relevelled_story = @original_story.new_derivation(parent_relevelled_story_attributes, @original_story.authors.first, @original_story.authors.first)
      @parent_relevelled_story.save!

      @parent_relevelled_story.publish

      @parent_relevelled_story.reload
      expect(@parent_relevelled_story.pages.select{|page| page.type == BackInnerCoverPage.name}.length).to be 3
      expect(@parent_relevelled_story.pages[-4].type).to eql(BackInnerCoverPage.name)
      expect(@parent_relevelled_story.pages[-3].type).to eql(BackInnerCoverPage.name)
      expect(@parent_relevelled_story.pages[-2].type).to eql(BackInnerCoverPage.name)
      expect(@parent_relevelled_story.pages[-1].type).to eql(BackCoverPage.name)
    end

    it "should consider original and parent story attributions when inserting back inner cover pages" do
      parent_relevelled_story_attributes = FactoryGirl.attributes_for(:story)
      .merge(language_id: @original_story.language.id)
      .merge(reading_level: '2')
      @parent_relevelled_story = @original_story.new_derivation(parent_relevelled_story_attributes, @original_story.authors.first, @original_story.authors.first)
      @parent_relevelled_story.save!

      child_relevelled_story_attributes = FactoryGirl.attributes_for(:story)
      .merge(language_id: @original_story.language.id)
      .merge(reading_level: '3')
      @child_relevelled_story = @parent_relevelled_story.new_derivation(child_relevelled_story_attributes, @original_story.authors.first, @original_story.authors.first)
      @child_relevelled_story.save!

      @child_relevelled_story.publish

      @child_relevelled_story.reload
      expect(@child_relevelled_story.pages.select{|page| page.type == BackInnerCoverPage.name}.length).to be 3
      expect(@child_relevelled_story.pages[-4].type).to eql(BackInnerCoverPage.name)
      expect(@child_relevelled_story.pages[-3].type).to eql(BackInnerCoverPage.name)
      expect(@child_relevelled_story.pages[-2].type).to eql(BackInnerCoverPage.name)
      expect(@child_relevelled_story.pages[-1].type).to eql(BackCoverPage.name)
    end

    # TODO Ask Kiran why counts are mismatching
    xit "should group the illustraton attribution by illustrator and attribution text" do
      person1 = FactoryGirl.create(:person)
      person2= FactoryGirl.create(:person)
      illustration1 = FactoryGirl.create(:illustration, illustrators: [person1], attribution_text: 'Attr 1')
      illustration2 = FactoryGirl.create(:illustration, illustrators: [person1], attribution_text: 'Attr 1')
      illustration3 = FactoryGirl.create(:illustration, illustrators: [person2], attribution_text: 'Attr 3')
      story = FactoryGirl.create(:story, status: Story.statuses[:draft])
      generate_illustration_crop(FactoryGirl.create(:front_cover_page, story: story, page_template: @front_cover_page_template), illustration1)
      generate_illustration_crop(FactoryGirl.create(:story_page, story: story), illustration2)
      generate_illustration_crop(FactoryGirl.create(:story_page, story: story), illustration3)
      FactoryGirl.create(:back_inner_cover_page, story: story, page_template: @back_inner_cover_page_template)
      FactoryGirl.create(:back_cover_page, story: story, page_template: @back_cover_page_template)

      story.publish

      story.reload
      expect(story.pages.select{|page| page.type == BackInnerCoverPage.name}.length).to be 1
      expect(story.pages[-2].type).to eql(BackInnerCoverPage.name)
      expect(story.pages[-1].type).to eql(BackCoverPage.name)
    end
  end

  describe "License" do
    before :each do
      Story::MAX_NUMBER_OF_ATTRIBUTIONS_PER_PAGE = 3
      @front_cover_page_template = FactoryGirl.create(:front_cover_page_template, default: true,orientation: 'landscape')
      @back_cover_page_template = FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
      @back_inner_cover_page_template = FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
      @story = FactoryGirl.create(:story, status: Story.statuses[:draft])
      @front_cover_page = FactoryGirl.create(:front_cover_page, story: @story, page_template: @front_cover_page_template)
      generate_illustration_crop(@front_cover_page, FactoryGirl.create(:illustration, license_type: 'CC BY 0'))
      @page1 = FactoryGirl.create(:story_page, story: @story)
      generate_illustration_crop(@page1, FactoryGirl.create(:illustration, license_type: 'CC BY 3.0'))
      @page2 = FactoryGirl.create(:story_page, story: @story)
      generate_illustration_crop(@page2, FactoryGirl.create(:illustration, license_type: 'CC BY 4.0'))
      @page3 = FactoryGirl.create(:story_page, story: @story)
      generate_illustration_crop(@page3, FactoryGirl.create(:illustration, license_type: 'Public Domain'))
      @back_inner_cover_page = FactoryGirl.create(:back_inner_cover_page, story: @story, page_template: @back_inner_cover_page_template)
      @back_cover_page = FactoryGirl.create(:back_cover_page, story: @story, page_template: @back_cover_page_template)
    end

    it "should get unique list of all illustration license types" do
      license_types = @story.illustration_license_types

      expect(license_types).to match_array(['CC BY 0', 'CC BY 3.0', 'CC BY 4.0', 'Public Domain'])
    end
  end

  describe "URL slug" do
    it "should include id and english title in URL" do
      story = FactoryGirl.build(:story, id: 34, title: 'moon and the cap', english_title: 'moon and the cap')
      expect(story.to_param).to eql('34-moon-and-the-cap')

      story = FactoryGirl.build(:story, id: 34,
                                title: 'ಆಲ್ಫಾಲ್ಫ ಲೆಗ್ಯೊಮಿನೋಸಿ ಕುಟುಂಬದ ಪಾಪಿಲಿಯೊನೇಸಿ ವಿಭಾಗಕ್ಕೆ ಸೇರಿದ ಗಿಡ. ಲೊಸರ್ನ ಎಂದೂ ಕರೆಯಲಾಗುವ ಈ ಗಿಡಕ್ಕೆ ಕನ್ನಡದಲ್ಲಿ ಕುದುರೆ ಮಸಾಲೆಸೊಪ್ಪು ಎಂದು ಹೆಸರಿದೆ. ಇದನ್ನು ದನಗಳ ಮತ್ತು ಕುದುರೆಗಳ ಮೇವಿಗಾಗಿ ಹುಲ್ಲುಗಾವಲುಗಳಲ್ಲಿ ಬೆಳೆಸುತ್ತಾರೆ. ಮಣ್ಣಿನ ಸಾರವನ್ನು ಹೆಚ್ಚಿಸುವುದಕ್ಕಾಗಿಯೂ ಬೆಳೆಸುವುದಿ',
                               english_title: 'english title')
      expect(story.to_param).to eql('34-english-title')
    end

    it "should normalize special characters when constructing URL" do
      story = FactoryGirl.build(:story, id: 34, title: 'ऐका आवाज शरीराचे!!!', english_title: '!english_title$')

      expect(story.to_param).to eql('34-english-title')
    end

    it "should include title in url when the story is in english" do
      story = FactoryGirl.build(:story, id: 34, title: 'moon and the cap', english_title: nil, language: FactoryGirl.create(:english))

      expect(story.to_param).to eql('34-moon-and-the-cap')
    end
  end

  describe "publish" do
    before :each do
      FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
      @story_uploaded = FactoryGirl.create(:story,status: Story.statuses[:uploaded])
      @story_review = FactoryGirl.create(:story,status: Story.statuses[:draft])
    end

    it "publish an uploaded story" do
      @story_uploaded.publish

      @story_uploaded.reload
      expect(@story_uploaded.published?).to be true
    end

    it "fail publish when the story status is not as uploaded" do
      @story_review.publish

      @story_uploaded.reload
      expect(@story_uploaded.published?).to be false
    end

    describe "Recommended Stories" do
      it "should recommend publisher stories when publisher has recommended flag" do
        @organization = FactoryGirl.create(:organization)
        @story = FactoryGirl.create(:story_with_publisher,status: Story.statuses[:uploaded])
        @story.organization = @organization
        @story.save!
        @story.publish

        @story.reload
        expect(@story.published?).to be true
        expect(@story.recommended?).to be true
      end
    end
  end

  describe "re-publish" do
    before :each do
      FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
      @republish_de_avtivated_story= FactoryGirl.create(:story,status: Story.statuses[:de_activated])
      @republish_uploaded = FactoryGirl.create(:story,status: Story.statuses[:uploaded])
      @republish_draft = FactoryGirl.create(:story,status: Story.statuses[:draft])
      @republish_edit_in_progress = FactoryGirl.create(:story,status: Story.statuses[:edit_in_progress])
      @user= FactoryGirl.create(:user)
    end

    it "re-publishing a story if status is de-activated" do

      @republish_de_avtivated_story.re_published(@republish_de_avtivated_story.status,@user)

      @republish_de_avtivated_story.reload
      expect(@republish_de_avtivated_story.status).to eql('de_activated')
    end

    it "re-publishing a story if is uploaded" do
      @republish_uploaded.re_published(@republish_uploaded.status,@user)

      @republish_uploaded.reload
      expect(@republish_uploaded.status).to eql('uploaded')
    end

    it "re-publishing a story if status is draft" do
      @republish_draft.re_published(@republish_draft.status,@user)

      @republish_draft.reload
      expect(@republish_draft.status).to eql('draft')
    end

    it "re-publishing a story if status is edit_in_progress" do
      @republish_edit_in_progress.re_published(@republish_edit_in_progress.status,@user)

      @republish_edit_in_progress.reload
      expect(@republish_edit_in_progress.status).to eql('edit_in_progress')
    end
  end

  describe "search_data" do
    it "should handle p and br tags in content when sanitising" do
      story = FactoryGirl.create(:story)
      FactoryGirl.create(:story_page, story: story, content: '<p>My school</p><p>is the good</p>')

      expect(story.search_data[:content]).to match_array(['My school  is the good'])
    end
  end

  describe "Default template selction based on reading level" do
    it "should create level 1 landscape story and should assign a default template for story page" do
      story = FactoryGirl.create(:level_1_story)
      page_template = FactoryGirl.create(:story_page_template, :orientation => 'landscape', :name => "sp_h_iT75_cB25")
      story.build_book(nil,true)
      expect(story.pages.second.page_template).to eql(page_template)
    end

    it "should create level 1 portrait story and should assign a default template for story page" do
      story = FactoryGirl.create(:level_1_story , :orientation => "portrait")
      page_template = FactoryGirl.create(:story_page_template , :orientation => 'portrait' , :name => "sp_v_iT50_cB50")
      story.build_book(nil,true)
      expect(story.pages.second.page_template).to eql(page_template)
    end

    it "should create level 2 landscape story and should assign a default template for story page" do
      story = FactoryGirl.create(:level_2_story)
      page_template = FactoryGirl.create(:story_page_template , :orientation => 'landscape' , :name => "sp_h_iT66_cB33")
      story.build_book(nil,true)
      expect(story.pages.second.page_template).to eql(page_template)
    end

    it "should create level 2 portrait story and should assign a default template for story page" do
      story = FactoryGirl.create(:level_2_story,:orientation => "portrait")
      page_template = FactoryGirl.create(:story_page_template , :orientation => 'portrait' , :name => "sp_v_iT66_cB33")
      story.build_book(nil,true)
      expect(story.pages.second.page_template).to eql(page_template)
    end
  end

  it "should return parent story page based on illustration" do
    root_story,parent_story,current_story = create_a_translation

    parent_story_page = current_story.parent_story_page(current_story.pages[1])

    expect(parent_story_page).to eql(parent_story.pages[1])
  end

  describe "Translation" do
    before :each do
      @user= FactoryGirl.create(:user)
      language = FactoryGirl.create(:english)
      attributes = FactoryGirl.attributes_for(:story)
      attributes.merge!({
        language_id: language.id
      })
      @story = FactoryGirl.create(:story, attributes)
      @page = FactoryGirl.create(:story_page, story: @story)
    end

    it "should return translated story on successful translate" do
      language = FactoryGirl.create(:kannada)

      tr_story_attributes = @story.dup.attributes.slice!('ancestry').merge!({
        language_id: language.id
      })

      tr_story = @story.translate(tr_story_attributes, @user, @user)

      expect(tr_story.language).to eql(language)
      expect(tr_story.parent).to eql(@story)
      expect(tr_story.status).to eql('draft')
      expect(tr_story.english_title).to be_nil
    end

    it "should copy parent story pages to translated story" do
      language = FactoryGirl.create(:kannada)
      tr_story_attributes = @story.dup.attributes.slice!('ancestry').merge!({
        language_id: language.id
      })

      tr_story = @story.translate(tr_story_attributes, @user, @user)

      expect(tr_story.pages.length).to be == 1
      expect(@story.pages.length).to be == 1
    end

  end

  describe "Re-level" do
    before :each do
      @user= FactoryGirl.create(:user)
      attributes = FactoryGirl.attributes_for(:story)
      attributes.merge!({
        reading_level: '1'
      })

      @story = FactoryGirl.create(:story, attributes)
      @page = FactoryGirl.create(:story_page, story: @story)
    end

    it "should return re-levelled story on success" do
      reading_level = '3'
      rl_story_attributes = @story.dup.attributes.slice!('ancestry').merge!({
        reading_level: reading_level
      })

      rl_story = @story.relevel(rl_story_attributes, @user, @user)

      expect(rl_story.reading_level).to eql('3')
      expect(rl_story.parent).to eql(@story)
      expect(rl_story.status).to eql('draft')
    end

    it "should copy parent story pages to relevelled story" do
      reading_level = '3'
      rl_story_attributes = @story.dup.attributes.slice!('ancestry').merge!({
        reading_level: reading_level
      })

      rl_story = @story.relevel(rl_story_attributes, @user, @user)

      expect(rl_story.pages.length).to be == 1
      expect(@story.pages.length).to be == 1
    end

  end

  def create_a_translation
    english = FactoryGirl.create(:english)
    kannada = FactoryGirl.create(:kannada)
    hindi = FactoryGirl.create(:language, name: 'Hindi')

    cover_page_template= FactoryGirl.create(:front_cover_page_template_2)
    FactoryGirl.create(:front_cover_page_template, orientation: "landscape")
    FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
    FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
    original_story = FactoryGirl.create(:story, language_id: english.id)
    original_story.build_book  cover_page_template
    original_story_page1 = FactoryGirl.create(:story_page)
    generate_illustration_crop(original_story_page1)
    original_story.insert_page(original_story_page1)
    original_story_page2 = FactoryGirl.create(:story_page)
    generate_illustration_crop(original_story_page2)
    original_story.insert_page(original_story_page2)
    original_story.save

    kannada_story = original_story.new_derivation(
      FactoryGirl.attributes_for(:story, language_id: kannada.id).slice!(:id),
      original_story.authors.first,
      original_story.authors.first,
      "translated")
    kannada_story.pages[1].content = 'ನನ್ನ ಶಾಲೆ'
    kannada_story.save!
    hindi_story = kannada_story.new_derivation(
      FactoryGirl.attributes_for(:story, language_id: hindi.id).slice!(:id),
      original_story.authors.first,
      original_story.authors.first,
      "translated")
    hindi_story.save!
    [original_story, kannada_story, hindi_story]
  end
end

