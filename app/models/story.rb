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
#  origin_url                :string(255)
#  uuid                      :string(255)
#  partner_reads             :json
#  partner_downloads         :json
#
# Indexes
#
#  index_stories_on_ancestry                         (ancestry)
#  index_stories_on_cached_votes_total               (cached_votes_total)
#  index_stories_on_language_id_and_organization_id  (language_id,organization_id)
#

class Story < ActiveRecord::Base
  acts_as_votable
  make_flaggable
  acts_as_taggable
  include Shared
  searchkick callbacks: :async,
             batch_size: 100,
             searchable: [:title, :english_title, :original_story_title, :organization, :illustrators, :authors, :language, :other_credits, :synopsis, :content, :tags_name, :categories, :target_language, :publisher],
             filterable: [:language, :categories, :organization, :reading_level, :derivation_type, :recommended_status, :authors, :page_illustration, :youngsters, :story_downloads, :status, :orientation, :target_language, :publisher, :tags_name],
             mappings: {
               story: {
                 properties: {
                   contest: {type: "boolean"},
                   created_at: {type: "date"},
                   editor_recommended: {type: "boolean"},
                   liked_users: {type: "long"},
                   likes: {type: "long"},
                   published_at: {type: "date"},
                   ratings: {type: "long"},
                   reads: {type: "long"},
                   recommended: {type: "boolean"},
                   recommendation: {type: "date"},
                   reviewer_comment: {type: "boolean"},
                   winner: {type: "boolean"},
                   read_rating: {type: "long"},
                   rating: {type: "long"},
                   is_flagged: {type: "boolean"}
                 }
               }
             },
             merge_mappings: true
  scope :flagged, -> { where("flaggings_count >= 1 and status != 5") }
  scope :de_activated, -> { where("flaggings_count >= 1 and status = 5") }

  STATUSES=[:draft, :published, :uploaded, :publish_pending, :edit_in_progress, :de_activated, :submitted]
  RECOMMENDED_STATUSES=[:recommended, :home, :home_recommended]
  READING_LEVELS_WITH_BIGGER_COVER_IMG = [1, 2]
  READING_LEVELS={'1' => 0, '2' => 1, '3' => 2, '4' => 3}
  CONTEST_READING_LEVELS={'1' => 0, '2' => 1}
  READING_LEVEL_INFO = {"1" => "Easy words, word repetition, less than 250 words",
    "2" => "Simple concepts, upto 600 words",
    "3" => "Longer sentences, upto 1500 words",
    "4" => "Longer, more nuanced stories, more than 1500 words"}
  MAX_NUMBER_OF_ATTRIBUTIONS_PER_PAGE = 12
  MAX_NUMBER_OF_CHILDRENS_PER_PAGE = 25

  enum reading_level: READING_LEVELS
  enum status: STATUSES
  enum recommended_status: RECOMMENDED_STATUSES

  validates :title, presence: true , length: {maximum: 255}, if: :published_or_pending_publish?
  validates :attribution_text, length: {maximum: 1000}
  validates :language, presence: true
  validates :title, presence: true , length: {maximum: 255}, format: {with:  /\A[a-zA-Z\d\'!@#$%~^&*()-{}\s]+\z/i, message: " can only have English Alphabet, numbers and punctuation characters"}, if: :validate_title?
  validates :english_title, presence: true , length: {maximum: 255}, format: {with:  /\A[a-zA-Z\d\'!@#$%~^&*()-{}\s]+\z/i, message: " can only have English Alphabet, numbers and punctuation characters"}, if: :english_title_validation?
  validates :reading_level, presence: { message: "This field cannot be empty." }
  validates :status, presence: true
  validates :authors, presence: true, length: {maximum: 4, message: "can not be more than 4"}, if: :published_or_pending_publish?
  validates :copy_right_year, presence: true, if: :published_or_pending_publish?
  validates :synopsis, presence: true, length: {maximum: 750}, if: :published_or_pending_publish?
  validates :orientation, presence: { message: "This field cannot be empty." }
  validate :derivation, if: :parent
  validates :categories, presence: true, if: :published_or_pending_publish?
  validate :check_children, if: :published_or_pending_publish?
  has_many :pulled_downs, as: :pulled_down

  belongs_to :language
  belongs_to :publisher
  belongs_to :donor
  belongs_to :contest
  belongs_to :organization
  belongs_to :editor, -> { order('first_name') },class_name: 'User'
  has_many :ratings, :as => :rateable
  belongs_to :copy_right_holder, class_name: 'User'
  has_and_belongs_to_many :categories,
    class_name: 'StoryCategory'
  has_and_belongs_to_many :authors, -> { order('first_name') },
    class_name: 'User', join_table: 'authors_stories'
  accepts_nested_attributes_for :authors, allow_destroy: true
  has_many :pages, -> {order('position ASC')},
    foreign_key: :story_id, autosave: true, dependent: :destroy
  has_and_belongs_to_many :story_downloads, join_table: 'stories_downloads'
  has_many :youngsters, dependent: :destroy
  accepts_nested_attributes_for :youngsters, allow_destroy: true
  has_one :recommendation, :as => :recommendable
  has_many :re_published_stories
  has_many :story_reads
  has_one :reviewer_comment
  has_one :reviewer, through: :reviewer_comments, source: :user
  has_one :winner
  has_one :phone_story
  has_and_belongs_to_many :favorites, class_name: 'Illustration', join_table: 'favorites'
  has_many :lists_stories
  has_many :lists, through: :lists_stories
  has_many :albums
  has_ancestry
  validate :uniqness_of_tags

  after_create :add_uuid_and_origin_url

  def add_uuid_and_origin_url
    if self.uuid == nil && self.origin_url == nil
      self.uuid = "#{Settings.org_info.prefix}-#{self.id}"
      self.origin_url = Settings.org_info.url
      self.save!
    elsif self.uuid == nil
      self.uuid = "#{Settings.org_info.prefix}-#{self.id}"
      self.save!
    elsif self.origin_url == nil
      self.origin_url = Settings.org_info.url
      self.save!
    end
  end

  def uniqness_of_tags
    if self.tag_list.present?
      all_tags = self.tag_list
      temp_tags = all_tags.map{ |f| f.downcase.strip }
      all_tags.each do |tag|
        if temp_tags.count(tag.downcase.strip) > 1
          self.errors.add(:base, "Tag name should be different.")
          break
        end
      end
    end
  end

  def check_children
    if self.youngsters.size >=1
      self.youngsters.each do |y|
        if y.name.empty? || y.name.nil?
          self.errors.add(:base, "Child name can't be blank")
          break
        end
      end
      self.youngsters.each do |y|
        if y.age.nil?
          self.errors.add(:base, "Child age can't be blank")
          break
        end
      end
    end
  end

  def derivation
    if is_translated?
      errors.add(:language, "should be different") if parent.language.name == language.try(:name)
      errors.add(:reading_level, "should be same") unless parent.reading_level == reading_level
    elsif is_relevelled?
      errors.add(:language, "should be same") unless parent.language.name == language.try(:name)
      errors.add(:reading_level, "should be different") if parent.reading_level == reading_level
    end
  end

  def category_names
    categories.collect(&:name).join(', ')
  end

  def author_names
    authors.collect(&:name).join(', ')
  end

  def flag_status current_user
    flagged_by?(current_user) || (current_user.content_manager? && flagged?)
  end

  default_scope {order("stories.created_at DESC") }

  scope :search_import, -> { includes(:language, :recommendation, :publisher, :organization, :story_downloads, :ratings, :authors, :youngsters, :categories, :tags, :votes_for, pages:[ {illustration_crop:  [ {illustration: [:illustrators]}]}, :page_template]) }

  def search_data()
    {
      id: id,
      title: title,
      english_title: english_title,
      reading_level: reading_level,
      status: status,
      language: language.name,
      script: language.script,
      authors: authors.map(&:name),
      author_slugs: authors.map{|a| a.slug},
      categories: categories.map(&:name),
      synopsis: synopsis,
      orientation: orientation,
      publisher: (publisher.name rescue ''),
      recommended: recommended,
      image_url: (pages.first.illustration_crop.url(:size1) rescue "/assets/original/missing.png"),
      url_slug: to_param,
      publisher_slug: (organization.slug rescue ''),
      organization: (organization.organization_name rescue ''),
      organization_slug: (organization.slug rescue ''),
      organization_logo: ApplicationController.helpers.organization_logo(self),
      content: pages.map {|page| page.sanitised_content},
      illustrators: illustrators.collect(&:name),
      illustrator_slugs: illustrators.map{|i| i.user ? i.user.slug : ''},
      reads: reads,
      likes: likes,
      liked_users: self.get_likes.map{|like| like.voter.id} || [],
      created_at: created_at,
      other_credits: other_credits,
      cover_page_id: cover_page.try(:id),
      original_story_title: (root.title rescue ''),
      published_at: published_at,
      derivation_type: derivation_type,
      recommended_status: recommended_status,
      recommendation: (recommendation.created_at rescue "2015-01-01".to_date),
      tags_name: tags.map(&:name),
      youngsters: youngsters.map(&:name),
      page_illustration: pages.map{|page| page.illustration_crop.illustration_id if page.illustration_crop},
      editor_name: (editor.name rescue ''),
      editor_recommended: editor_recommended,
      winner: winner.present?,
      contest: contest.present?,
      contest_name: (contest.name rescue ''),
      contest_slug: (contest.to_param rescue ''),
      reviewer_comment: reviewer_comment.present?,
      story_downloads: story_downloads.map(&:user_id),
      rating: rating_for_search,
      uploading: uploading,
      cover_image_crop_coords: get_cover_image_crop_coords,
      image_sizes: get_image_sizes,
      authors_details: get_author_details,
      source_language_id: language.id,
      target_language: get_target_languages,
      availableForOfflineMode: illustrations_available_for_offline?,
      is_flagged: flagged?,
      read_rating: read_rating
    }
  end

  def rating_for_search
    if organization && organization.publisher?
      return 6 #higher rating than all other books to come up in the search results
    else
      reviewer_comment.rating rescue 3
    end
  end

  def illustrations_available_for_offline?
    self.illustrations.each do |il|
      return false if il.storage_location.nil?
    end
    return true
  end

  def get_language_ids
    language_ids = Language.all.collect(&:id)
    l = children.where(:status => Story.statuses[:published], :derivation_type=>"translated", :language_id => language_ids, :is_autoTranslate => true).collect(&:language_id)
    l << children.where(:status => Story.statuses[:published], :derivation_type=>"translated", :language_id => language_ids).where.not(:organization => nil).collect(&:language_id)
    children.where(:status => Story.statuses[:published], :derivation_type=>"translated", :language_id => language_ids, :organization => nil).map{|c| l << c.language_id if c.ratings.size > 0 && c.ratings[0].user_rating == 5}
    l.flatten.uniq
  end

  def get_author_details
    authors.map{|a| {:slug => "#{a.id}-#{a.name.parameterize}", :name => a.name}}
  end

  def get_image_sizes
    if pages.first
      illu_crop = pages.first.illustration_crop
      if illu_crop && illu_crop.image.present?
        [:size1, :size2, :size3, :size4, :size5, :size6, :size7].map{ |size|
          {:height=> get_img_height(illu_crop, size),
           :width => get_img_width(illu_crop, size) ,
           :url=> illu_crop.url(size)}
        }
      end
    end
  end

  def get_img_height(illu_crop, size)
    begin
      illu_crop.image_geometry(size).height
    rescue Exception
      0
    end
  end
   
  def get_img_width(illu_crop, size)
    begin
      illu_crop.image_geometry(size).width
    rescue Exception
      0
    end
  end

  def get_cover_image_crop_coords
    if pages.first
        illu_crop = pages.first.illustration_crop
      if illu_crop
        illu_crop.parsed_smart_crop_details
      else
        {"x"=>0, "y" => 0}
      end
    end
  end

  def get_target_languages
    l = [root.language.name]
    l += root.descendants.where(:status => [Story.statuses[:published], Story.statuses[:uploaded]], :derivation_type=>"translated").where.not(:organization => nil).map{|s| s.language.name}
    non_organization_translations = root.descendants.where(:status => Story.statuses[:published], :derivation_type=>"translated", :organization => nil)
    languages_with_non_rated_stories = {}
    non_organization_translations.each do |c|
      if c.ratings.size > 0 && c.ratings[0].user_rating == 5
        l << c.language.name
      else
        languages_with_non_rated_stories[c.language.name] ||= 0
        languages_with_non_rated_stories[c.language.name] += 1
      end
    end
    languages_with_non_rated_stories.each do |language, count|
      l << language if count >= 2
    end
    l.flatten.uniq
  end

  def new_derivation(story_params,authors, current_user,derivation_type=nil)
    new_story = create_new_derivation_without_pages(story_params,authors, current_user,derivation_type)
    duplicate_pages_into(new_story)
    new_story
  end

  def is_translated?
    derivation_type == "translated"
  end

  def is_relevelled?
    derivation_type == "relevelled"
  end

  def should_recommend?
    if organization.try(:has_recommended_right?)
      if recommended_status == "home"
        Story.recommended_statuses[:home_recommended]
      else
        Story.recommended_statuses[:recommended]
      end
    end
  end

  def get_trishold
    story_rating = ReviewerComment.story_ratings[self.reviewer_comment.story_rating]
    language_rating = ReviewerComment.language_ratings[self.reviewer_comment.language_rating]
    star_rating = self.reviewer_comment.rating
    if(((story_rating < 3 && language_rating < 3) && star_rating > 3) || ((story_rating > 3 && language_rating > 3) && star_rating < 3))
      return true;
    end
  end

  def self.to_csv(options = {})
    headers = ["Draft Stories","","","","Submitted Stories"]
    attributes = ["Title","Language","Email","","Title","Language","Email"]   
    CSV.generate(headers: true) do |csv|
      csv << headers
      csv << attributes
      row = []
      i=j=0
      all.each_with_index do|story, index|
        if story.status == "draft"
          title = story.title
          language= story.language.name
          email = story.authors.collect(&:email).join(', ')
          status = story.status
          if row[i].nil?
            row[i] = [title, language, email, ""]
          else
            row[i] =  [title, language, email, ""] + row[i].reject(&:empty?)
          end
          i += 1
        else
          title = story.title
          language= story.language.name
          email = story.authors.collect(&:email).join(', ')
          if row[j].nil?
            row[j] = ["", "", "", "", title, language, email]
          else
            row[j] += [title, language, email]
          end
          j += 1
        end
      end
      row.map{|r| csv << r}

    end
  end


  def update_and_publish(params, author_attributes, current_user, restrict_publish = false)
    unless self.contest_id == nil
      contest = Contest.find_by_id(self.contest_id)
      params[:tag_list] = params[:tag_list] + "," + contest.tag_name unless contest.tag_name.nil?
    end
    previous_status = self.status
    previous_published_at = self.re_published_stories.last.published_at if self.re_published_stories.present?
    params.merge!(published_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")) if (self.status == "uploaded" || self.status == "draft")
    params.merge!(status: Story.statuses[:publish_pending]) unless restrict_publish
    params.merge!(user_title: params[:title].strip != '' ? true : false)
    self.copy_right_year = Time.now.year unless current_user.organization? || current_user.content_manager?
    if(current_user.organization? || current_user.content_manager?)
      self.authors = []
      author_attributes.each do |key,value|
        if value[:_destroy].nil? || value[:_destroy] == 'false'
          author_first_name = value[:first_name]
          author_last_name = value[:last_name]
          author_email = value[:email]
          author = User.find_by_email(author_email) || User.new(
            first_name: author_first_name,
            last_name: author_last_name,
            email: author_email,
            password: User.generate_random_password)
          if(author.new_record?)
            self.authors.build(author.attributes.merge!(password: author.password))
          else
            self.authors << author unless self.authors.include?(author)
          end
        else
          self.authors.destroy(User.find_by_email(value[:email]))
        end
      end
      authors_valid = self.authors.select { |i| !i.valid? }.size == 0
      story_valid = self.update(params)
      publishable = authors_valid && story_valid
    else
      publishable = self.update(params)
    end
    if publishable && !restrict_publish
      self.re_published(previous_status, current_user)
      contest = Contest.find_by_id(self.contest_id) if self.contest_id != nil
      if(self.contest_id != nil && contest.is_running? && contest.is_campaign == false)
        Delayed::Job.enqueue Jobs::SubmittedStoryJob.new(id)
        managers = User.where("site_roles = ? OR site_roles = ?", "content_manager", "promotion_manager").collect(&:email)
        UserMailer.delay(:queue => "mailer").submitted_story_mail_to_managers(managers, self,contest)
        UserMailer.delay(:queue => "mailer").submitted_story_mail_to_user(current_user, self,contest)
      else
        Delayed::Job.enqueue Jobs::PublishStoryJob.new(id)
        if current_user.organization? && self.organization_id != nil
          illustrators = self.illustrators.collect(&:email)
          authors = self.authors.collect(&:email)
          UserMailer.delay(:queue => "mailer").publisher_story_mail_to_authors(authors, self)
          UserMailer.delay(:queue => "mailer").publisher_story_mail_to_illustrators(illustrators, self)
        end
        content_managers=User.content_manager.collect(&:email).join(",")
        UserMailer.delay(:queue => "mailer").published_story(content_managers, self) unless previous_status == "de_activated" || previous_status == "edit_in_progress"
        UserMailer.delay(:queue => "mailer").re_publish_story(content_managers, self,current_user.first_name) if previous_status == "edit_in_progress"
        send_mail_to_original_authors(self) if self.is_derivation? && previous_status == "draft"
        if self.flaggings.any? && previous_status == "de_activated"
          self.flaggings.destroy_all 
          self.flaggings_count = nil
          self.save
        end
      end
      if previous_status == "de_activated"
        UserMailer.delay(:queue => "mailer").re_published_story_email(content_managers, self, current_user.first_name)
        flaggers = self.re_published_stories.where(:published_at => previous_published_at..self.re_published_stories.last.published_at, :previous_status => Story.statuses[previous_status])
        flaggers.each do |flagging|
          UserMailer.delay(:queue=>"mailer").story_re_publish_email_to_flagger(flagging.user,self)
        end
      end
      self.status = previous_status
    end
    insert_dedication_page
    publishable
  end

  def process_publish
    insert_dedication_page
    self.published_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")   if (self.status == "uploaded" || self.status == "draft")
    self.status = Story.statuses[:publish_pending]
    return false unless self.save
    Delayed::Job.enqueue Jobs::PublishStoryJob.new(id)
    content_managers=User.content_manager.collect(&:email).join(",")
    UserMailer.delay(:queue => "mailer").published_story(content_managers, self)
    StoriesController.new.delay.make_story_static_files(self)
    return true # added to ensure that the method always returns a boolean value
  end

   def send_mail_to_original_authors(story)
    if story.depth == 1
      emails = story.root.authors.collect(&:email)
      emails.push(story.root.illustrators.collect(&:email).join(","))
      emails.push(story.root.organization.email) if story.organization != story.root.organization
      UserMailer.delay(:queue => "mailer").root_story_derivation(emails, story, story.root)
    elsif story.depth > 1
      emails = story.root.authors.collect(&:email)
      emails.push(story.root.illustrators.collect(&:email))
      emails.push(story.parent.authors.collect(&:email))
      emails.push(story.root.organization.email) if story.organization != story.root.organization
      UserMailer.delay(:queue => "mailer").derivation_of_child_story(emails, story, story.root)
    end
   end


  def re_published(status, current_user)
    re_published_stories = RePublishedStory.new
    re_published_stories.story = self
    re_published_stories.previous_status = Story.statuses[status]
    re_published_stories.published_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    re_published_stories.user = current_user
    re_published_stories.save
  end

  def publish
    self.status = Story.statuses[:published]
    insert_or_update_dedication_pages
    insert_or_update_back_inner_cover_pages
    self.recommended_status = should_recommend?
    self.uploading = true
    self.save!
    self.make_images_public
    StoriesController.new.delay(attempts: 1).make_story_static_files(self)
    self.delay.reindex_translations if self.is_translated?
  end

  def reindex_translations
    self.root.descendants.where(:status => [Story.statuses[:published], Story.statuses[:uploaded]], :derivation_type=>"translated").map{|s| s.reindex}
  end

  def make_images_public
    self.illustrations.uniq.each do|illustration|
      if illustration.present? && illustration.image_mode == true
        illustration.image_mode = false
        illustration.save
      end
    end
  end

  def submitted
    self.status = Story.statuses[:submitted]
    self.categories << self.contest.story_category if self.contest.story_category.present?
    insert_or_update_dedication_pages
    insert_or_update_back_inner_cover_pages
    self.recommended_status = should_recommend?
    self.save!
    StoriesController.new.delay(attempts: 1).make_story_static_files(self)
  end

  def get_story_rating_comments(data)
    if self.reviewer_comment.present?
      return data == "rating" ? self.reviewer_comment.rating : self.reviewer_comment.comments
    elsif self.flaggings_count != nil
      return data == "rating" ? "Flagged story" : self.flaggings.first.reason
    else
      return "Not yet rated"
    end
  end

  def story_rating(current_user)
    self.ratings.where(:user_id => current_user).first.user_rating
  end

  def story_comment(current_user)
    self.ratings.where(:user_id => current_user).first.user_comment
  end

  def total_ratings
    ratings.where(:rateable_id => self).collect(&:user_rating).sum/ratings.where(:rateable_id => self).collect(&:user_rating).size
  end

  def reviewed_by_user(current_user)
    ratings.where(:user => current_user).any?
  end

  def get_children_count
    children.where(:status => 1).count
  end

  def is_child_created
    youngsters.any?
  end

  def editable_pages
    pages.select{|page| (page.is_a?FrontCoverPage) || (page.is_a?StoryPage)}
  end

  def build_book(front_cover_page_template=nil,add_story_page=false, story_page_illustration=false)
    story_orientation = !orientation.blank? ? orientation : (front_cover_page_template.try(:orientation) || 'landscape')
    self.update_attributes(:orientation => story_orientation) if orientation.blank?
    if(!has_front_cover_page?)
      front_cover_page = FrontCoverPage.new
      front_cover_page.page_template = front_cover_page_template || FrontCoverPageTemplate.of_orientation(story_orientation).default.try(:first)
      pages << front_cover_page
    end
    if(add_story_page && !has_story_page?)
      story_page = StoryPage.new
      story_page.page_template = StoryPageTemplate.get_default_template(self,story_orientation)
      if story_page_illustration
        illustration_crop = story_page_illustration.process_crop!(story_page)
        story_page.illustration_crop = illustration_crop
      end
      pages << story_page
    end
    if(!has_back_inner_cover_page?)
      back_inner_cover_page = BackInnerCoverPage.new
      back_inner_cover_page.page_template = BackInnerCoverPageTemplate.of_orientation(story_orientation).default.try(:first)
      pages << back_inner_cover_page
    end
    if(!has_back_cover_page?)
      back_cover_page = BackCoverPage.new
      back_cover_page.page_template = BackCoverPageTemplate.of_orientation(story_orientation).default.try(:first)
      pages << back_cover_page
    end
  end

######################contest purpose #####################################

  def contest_build_book(story_page_illustration, front_cover_page_illustration)
    story_orientation = 'landscape'
    self.update_attributes(:orientation => story_orientation)

    front_cover_page = FrontCoverPage.new
    Rails.logger.info("In Front Cover thread")
    front_cover_page.page_template = FrontCoverPageTemplate.find_by_name("fc_h_iT66_cB33")
    illustration_crop = front_cover_page_illustration.process_crop!(front_cover_page)
    front_cover_page.illustration_crop = illustration_crop
    Rails.logger.info("After Front Cover thread")

    story_page = StoryPage.new
    Rails.logger.info("In Page1 thread")
    story_page.page_template = StoryPageTemplate.find_by_name("sp_h_iT66_cB33")
    illustration_crop = front_cover_page_illustration.process_crop!(story_page)
    story_page.illustration_crop = illustration_crop
    Rails.logger.info("After Page1 thread")

    story_page1 = StoryPage.new
    Rails.logger.info("In Page2 thread")
    story_page1.page_template = StoryPageTemplate.find_by_name("sp_h_iT66_cB33")
    illustration_crop = story_page_illustration.process_crop!(story_page1)
    story_page1.illustration_crop = illustration_crop
    Rails.logger.info("After Page2 thread")

    pages << front_cover_page
    pages << story_page
    pages << story_page1

    back_inner_cover_page = BackInnerCoverPage.new
    back_inner_cover_page.page_template = BackInnerCoverPageTemplate.of_orientation(story_orientation).default.try(:first)
    pages << back_inner_cover_page

    back_cover_page = BackCoverPage.new
    back_cover_page.page_template = BackCoverPageTemplate.of_orientation(story_orientation).default.try(:first)
    pages << back_cover_page

  end
###################### contest purpose end #####################################



  def page_orientation
    orientation || cover_page.page_template.orientation
  end

  def insert_page(page,selected_page=false)
    back_inner_cover_page = pages[-2]
    back_cover_page = pages[-1]

     if selected_page
        pages << page
        selected_page.type == BackCoverPage.name ?
        page.insert_at(back_inner_cover_page.position) :
        page.insert_at(selected_page.position+1)
        pages.reload
        true
     else
        _val = pages << page
        return _val if _val==false
        if has_back_inner_cover_page? && has_back_cover_page?
          2.times do
            page.move_higher
            back_cover_page.move_lower
          end
          back_inner_cover_page.move_lower
          pages.reload
        end
        true
      end
  end

  def original_authors
    root.authors
  end

  def translators
    if is_translation?
      authors
    else
      []
    end
  end

  def illustrators
    editable_pages.map{|page|page.illustration_crop.try(:illustration).try(:illustrators)}.flatten.compact.uniq.sort{|a,b| a.name <=> b.name }
  end

  def photographers
    illustrations_photographers = editable_pages.map do |page|
      page.try(:illustration).try(:photographers)
    end
    illustrations_photographers.flatten.compact.uniq.sort{|a,b| a.name <=> b.name }
  end

  def has_illustrators?
    !illustrators.empty?
  end

  def has_photographers?
    !photographers.empty?
  end

  def is_derivation?
    is_translation? || is_relevel?
  end

  def is_translation?
    root? ? false : parent.language.name != language.name
  end

  def is_relevel?
    root? ? false : parent.reading_level != reading_level
  end

  def other_languages_available_in
    if is_root?
      descendants.where(status: Story.statuses[:published]).collect(&:language).uniq
    else
      root.descendants.where(status: Story.statuses[:published]).where.not(:id=>self.id).collect(&:language).uniq
    end
  end

  def other_versions
    if is_root?
      #Story.unscoped.descendants_of(self).where(status: Story.statuses[:published]).select("language_id, reading_level, count(language_id)").group("language_id, reading_level").order("language_id")
      Story.unscoped.descendants_of(self).where(status: Story.statuses[:published]).order(:language_id, :reading_level)
    else
      #Story.unscoped.descendants_of(self.root).where(status: Story.statuses[:published]).where.not(:id=>self.id).select("language_id, reading_level, count(language_id)").group("language_id, reading_level").order("language_id")
      Story.unscoped.descendants_of(self.root).where(status: Story.statuses[:published]).where.not(:id=>self.id).order(:language_id, :reading_level)
    end
  end

  def other_versions_api
    versions = []
    if is_root?
      Story.unscoped.descendants_of(self).where(status: Story.statuses[:published]).order(:language_id, :reading_level)
    else
      versions << self.root
      versions << Story.unscoped.descendants_of(self.root).where(status: Story.statuses[:published]).where.not(:id=>self.id).order(:language_id, :reading_level)
      versions.flatten
    end
  end

  def other_versions_derivatives
    Story.unscoped.children_of(self).where(status: Story.statuses[:published]).select("language_id, reading_level, count(language_id)").group("language_id, reading_level").order("language_id")
  end

  def version_label
    version_text = count > 1 ? "versions" : "version"
    "#{language.name} - Level #{reading_level} (#{count} #{version_text})"
  end

  def show_version_label
    "#{language.name} - Level #{reading_level} (#{count})"
  end

  def version_id
    "#{language_id} #{reading_level}"
  end

  def versions(language_id, reading_level)
    if is_root?
    descendants.where(language_id: language_id, reading_level: READING_LEVELS[reading_level], status: Story.statuses[:published])
  else
    root.descendants.where(language_id: language_id, reading_level: READING_LEVELS[reading_level], status: Story.statuses[:published]).where.not(:id=>self.id)
  end
  end

  def version_derivation_type
    derivation_type == "translated" ? "Translation" : derivation_type == "relevelled"  ? "Re-level" : ''
  end

  def cover_page
    pages.first
  end

  def get_english_version(current_user)
    @language = Language.find_by_name("English")
    if self.is_root?
       organization_english_story =  Story.unscoped.descendants_of(self).where(status: Story.statuses[:published])
                                  .where.not(:id=>self.id, :organization_id => nil).where(:language_id => @language.id)

       english_story_reviewed = Story.unscoped.descendants_of(self).joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                                .where(status: Story.statuses[:published], :organization_id => nil, :flaggings_count => nil).where.not(:id=>self.id)
                                .where(:language_id => @language.id)
                                .reorder("reviewer_comments.rating DESC")

       english_story_un_reviewed = Story.unscoped.descendants_of(self).joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                                   .where("reviewer_comments.story_id IS ?", nil)
                                   .where(status: Story.statuses[:published],:organization_id => nil, :flaggings_count => nil).where.not(:id=>self.id)
                                   .where(:language_id => @language.id)

       return @english_version = organization_english_story.count >= 1 ? organization_english_story.first : (english_story_reviewed.count >= 1 ?  english_story_reviewed.first :  english_story_un_reviewed.first)
     else
        organization_english_story =  Story.unscoped.descendants_of(self.root).where(status: Story.statuses[:published])
                                  .where.not(:id=>self.id, :organization_id => nil).where(:language_id => @language.id)

        english_story_reviewed = Story.unscoped.descendants_of(self.root).joins("INNER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")   
                                .where(status: Story.statuses[:published], :organization_id => nil, :flaggings_count => nil).where.not(:id=>self.id)
                                .where(:language_id => @language.id)
                                .reorder("reviewer_comments.rating DESC")

        english_story_un_reviewed = Story.unscoped.descendants_of(self.root).joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                                   .where("reviewer_comments.story_id IS ?", nil)
                                   .where(status: Story.statuses[:published],:organization_id => nil, :flaggings_count => nil).where.not(:id=>self.id)
                                   .where(:language_id => @language.id)

      return @english_version = organization_english_story.count >= 1 ? organization_english_story.first : (english_story_reviewed.count >= 1 ?  english_story_reviewed.first :  english_story_un_reviewed.first)
     end
  end

  def get_reviewer_stories(current_user)
     if self.derivation_type == nil 
       return true
     else 
       if current_user.is_language_reviewer(self.root.language.name)
         return true 
       else
         return self.language.name != "English" ? (self.get_english_version(current_user) != nil ? true : false) : false
       end
     end
  end

  def cover_page_illustration_crop
    if pages.first.illustration_crop
      ill_crop = pages.first.illustration_crop
      if ill_crop.image != nil && ill_crop.image.exists?
        if ill_crop.image.try(:url) == "/assets/original/missing.png" || ill_crop.image.processing?
          "/assets/uploading_illustration.png"
        else
          pages.first.illustration_crop.image.url(:size1)
        end
      else
        "/images/original/missing.png"
      end
    else
      "/images/original/missing.png"
    end
  end

  def inner_back_cover_pages
    pages.select{|page| page.type == BackInnerCoverPage.name}
  end

  def dedication_pages
    pages.select{|page| page.type == DedicationPage.name}
  end

  def attributions(current_page)
    attributions = all_attributions
    current_page_position = inner_back_cover_pages.find_index(current_page) + 1
    current_page_attributions = []
    attributions.each_with_index do |a, index|
      current_page_attributions << a if (index >= (current_page_position - 1) * attributions_per_page && index < current_page_position * attributions_per_page)
    end
    current_page_attributions
  end

  def youngsters_of(current_page)
    current_page_position = dedication_pages.find_index(current_page) + 1
    current_page_youngsters = []
    youngsters.each_with_index do |y, index|
      current_page_youngsters << y if (index >= (current_page_position - 1) * MAX_NUMBER_OF_CHILDRENS_PER_PAGE && index < current_page_position * MAX_NUMBER_OF_CHILDRENS_PER_PAGE)
    end
    current_page_youngsters
  end

  def last_dedication_page(current_page)
    pages.select{|page| page.type == DedicationPage.name}.last == current_page
  end

  def attributions_per_page
    MAX_NUMBER_OF_ATTRIBUTIONS_PER_PAGE
  end

  def illustration_license_types
    pages_with_illustrations.map { |page| page.illustration.license_type }.uniq.sort
  end

  def all_attributions
    attributions = Attributions.new
    attributions.add_self(self, self == root)
    if(parent != nil && root != parent)
      attributions.add_parent_story_attribution(parent)
    end
    if(is_derivation?)
      attributions.add_original_story_attribution(root)
    end
    pages_with_illustrations.each do |page|
      if(page.illustration_crop != nil)
        attributions.add_illustration_attribution(page.position, page.illustration_crop.try(:illustration), self)
      end
    end

    attributions
  end

  def other_credits
    attribution_text
  end

  def story_pages
    pages.select { |p| p.class.to_s == 'StoryPage' }
  end

  def number_of_story_pages
    story_pages.count
  end

  def update_downloads_count(type, current_user, ip_address, flag)
    if type == "epub"
      self.update_attribute(:epub_downloads, self.epub_downloads+1)
      story_download(type, self, current_user, ip_address, flag)
    elsif type == "low"
      self.update_attribute(:downloads, self.downloads+1)
      story_download(type, self, current_user, ip_address, flag)
    elsif type == "high"
      self.update_attribute(:high_resolution_downloads, self.high_resolution_downloads+1)
      story_download(type, self, current_user, ip_address, flag)
    elsif type == "images_only"
      self.update_attribute(:images_only, self.images_only+1)
      story_download(type, self, current_user, ip_address, flag)
    elsif type == "text_only"
      self.update_attribute(:text_only, self.text_only+1)
      story_download(type, self, current_user, ip_address, flag)
    end
  end

  def story_download(type, story, current_user, ip_address,flag)
    download = StoryDownload.new
    download.user = current_user
    download.download_type = type
    download.story_id = 0
    download.ip_address = ip_address
    download.organization_user = flag ? (current_user.organization.present? ? true : false) : false
    download.save!
    download.stories << story
  end

  def to_param
    url_slug(id, language == english_language ? title: english_title)
  end

  def pending_illustration_uploads?
    illustrations_to_be_uploaded = pages.select do |page|
      !page.illustration_crop.nil? &&
        page.illustration_crop.image.processing?
    end
    illustrations_to_be_uploaded.count > 0
  end

  def has_front_cover_page?
    pages.any?{|page|page.type=="FrontCoverPage"}
  end

  def has_back_inner_cover_page?
    pages.any?{|page|page.type=="BackInnerCoverPage"}
  end

  def has_back_cover_page?
    pages.any?{|page|page.type=="BackCoverPage"}
  end

  def has_story_page?
    pages.any?{|page| page.type == "StoryPage"}
  end

  def change_orientation(orientation)
    self.update_attributes(:orientation => orientation)
    if READING_LEVELS_WITH_BIGGER_COVER_IMG.include? reading_level.to_i
      front_cover_page.update_attributes(:page_template => FrontCoverPageTemplate.of_orientation(orientation).default.first)
    else
      front_cover_page.update_attributes(:page_template => FrontCoverPageTemplate.find_by_orientation("#{orientation}"))     
    end
    back_cover_page.update_attributes(:page_template => BackCoverPageTemplate.find_by_orientation("#{orientation}"))
    back_inner_cover_pages.each do |page|
      page.update_attributes(:page_template => BackInnerCoverPageTemplate.find_by_orientation("#{orientation}"))
    end
  end

  def is_orientation_changed(new_orientation)
    page_orientation != new_orientation
  end

  def front_cover_page
    pages.first
  end

  def back_cover_page
    pages.last
  end

  def back_inner_cover_pages
    pages.select{|p| p.page_template.type=="BackInnerCoverPageTemplate"}
  end

  def self.increment!(ids, attr_name)
    Shared.increment_read!(ids, self.table_name, attr_name, self.connection)
    Story.where(id: ids).each{|story| story.reindex}
  end

  def parent_story_page(for_page)
    if for_page.illustration_crop
      #Select page if illustration crop matches
      self.parent.story_pages.select{|page| page.illustration_crop == for_page.illustration_crop}.first rescue []
    elsif for_page.illustration
      #Select page if illustration matches
      self.parent.story_pages.select{|page| page.illustration == for_page.illustration}.first rescue []
    else
      #select page if position matches.
      self.parent.story_pages.select{|page| page.position == for_page.position}.first rescue []
    end
  end

  def insert_or_update_back_inner_cover_pages
    orientation = cover_page.page_template.orientation rescue 'landscape'
    inner_back_cover_pages.each {|page| page.destroy}
    number_of_back_inner_cover_pages.times do
      back_inner_cover_page = BackInnerCoverPage.new
      back_inner_cover_page.page_template = BackInnerCoverPageTemplate.of_orientation(orientation).default.try(:first)
      pages << back_inner_cover_page
      pages.last.move_higher
    end
  end

  def insert_or_update_dedication_pages
    orientation = cover_page.page_template.orientation rescue 'landscape'
    dedication_pages.each {|page| page.destroy}
    number_of_dedication_pages.times do
      dedication_page = DedicationPage.new
      dedication_page.page_template = DedicationPageTemplate.of_orientation(orientation).default.try(:first)
      pages << dedication_page
      pages.last.move_higher
    end
  end

  def illustrations
    pages.reject{ |page| page.type == BackInnerCoverPage.name || page.type == BackCoverPage.name || page.illustration_crop.nil? }
    .collect{|page|page.illustration}
  end

  def illustration_attributions
    illustrations
    .group_by(&:illustrator)
    .map{|illustrator, illustration| illustration.group_by(&:attribution_text).map{|attribution_text, result| {attribution_text => result.length}} }
    .flatten
  end

  def number_of_back_inner_cover_pages
    number_of_attributions = all_attributions.length
    number_of_attributions % attributions_per_page == 0 ?
      number_of_attributions/attributions_per_page :
      (number_of_attributions/attributions_per_page) + 1
  end

  def number_of_dedication_pages
    number_of_youngsters = youngsters.size
    number_of_youngsters % MAX_NUMBER_OF_CHILDRENS_PER_PAGE == 0 ?
      number_of_youngsters/MAX_NUMBER_OF_CHILDRENS_PER_PAGE :
      (number_of_youngsters/MAX_NUMBER_OF_CHILDRENS_PER_PAGE) + 1
  end

  def pages_with_illustrations
    pages
    .reject{ |page| page.is_a?(BackInnerCoverPage) || page.is_a?(BackCoverPage) || page.illustration_crop.nil? }
    .sort{|a,b| a.position <=> b.position}
  end

  def validate_title?
    (published_or_pending_publish?) && language == english_language
  end

  def english_title_validation?
    (published_or_pending_publish?) && language != english_language
  end

  def published_or_pending_publish?
    publish_pending? || published?
  end

  def english_language
    Language.find_by_name('English')
  end

  def change_author(user)
    authors = [user]
    self.save
  end

  def auto_translate(lang_id)
    at_user = User.find_by first_name:"Working Draft"
    at_language_name = Language.find(lang_id).name
    params = {"language_id"=>"#{lang_id}"}
    at_story = self.new_derivation(params,authors = [at_user], current_user = at_user,derivation_type = "translated")
    pages.each do |page|
      if page.content
        at_story.pages[page.position-1].content = ApplicationController.helpers.translateText(page.content,at_language_name)
      end
    end
    at_story.title = ApplicationController.helpers.translateText(title, at_language_name)
    if at_story.title == title
      at_story.title = ApplicationController.helpers.translateText(title, at_language_name, try_lower_case=true)
    end
    at_story.english_title = nil
    at_story.status = Story.statuses[:draft]
    at_story.recommended_status = nil
    at_story.reads = 0
    at_story.cached_votes_total = 0
    at_story.downloads = 0
    at_story.epub_downloads = 0
    at_story.high_resolution_downloads = 0
    at_story.attribution_text = ''
    at_story.synopsis = ApplicationController.helpers.translateText(synopsis, at_language_name)
    at_story.topic_id = nil
    at_story.donor_id = nil
    at_story.credit_line = nil
    at_story.contest_id = nil
    at_story.tags = self.tags
    at_story.editor_recommended = false
    at_story.user_title = false
    at_story.flaggings_count = nil
    at_story.revision = nil
    at_story.is_autoTranslate = true
    at_story.is_display_inline = false
    if at_story.save
      pages.each do |page|
        if page.content
          transalted_content = GoogleTranslatedVersion.new
          transalted_content.page  = at_story.pages[page.position-1]
          transalted_content.google_translated_content = at_story.pages[page.position-1].content
          transalted_content.save!
        end
      end
    end
    at_story
  end

  def translate(params, authors, current_user)
    tr_story = self.new_derivation(
      params,
      current_user,
      current_user,
      "translated")
    tr_story.english_title = nil
    tr_story.status = current_user.organization? ? Story.statuses[:uploaded] : Story.statuses[:draft]
    tr_story.recommended_status = nil
    tr_story.reads = 0
    tr_story.cached_votes_total = 0
    tr_story.downloads = 0
    tr_story.epub_downloads = 0
    tr_story.high_resolution_downloads = 0
    tr_story.attribution_text = ''
    tr_story.synopsis = ''
    tr_story.topic_id = nil
    tr_story.donor_id = nil
    tr_story.credit_line = nil
    tr_story.contest_id = nil
    tr_story.tags = self.tags
    tr_story.editor_recommended = false
    tr_story.user_title = false
    tr_story.flaggings_count = nil
    tr_story.revision = nil
    tr_story.is_display_inline = false
    if tr_story.save
      PiwikEvent.create(category:'Story',action:'Translate', name:self.title)
    end
    tr_story
  end

  def relevel(params, authors, current_user)
    rl_story = self.new_derivation(
      params,
      current_user,
      current_user,
      "relevelled")
    rl_story.status = current_user.organization? ? Story.statuses[:uploaded] : Story.statuses[:draft]
    rl_story.recommended_status = nil
    rl_story.reads = 0
    rl_story.cached_votes_total = 0
    rl_story.downloads = 0
    rl_story.epub_downloads = 0
    rl_story.high_resolution_downloads = 0
    rl_story.attribution_text = ''
    rl_story.synopsis = ''
    rl_story.topic_id = nil
    rl_story.donor_id = nil
    rl_story.credit_line = nil
    rl_story.contest_id = nil
    rl_story.tags = self.tags
    rl_story.editor_recommended = false
    rl_story.user_title = false
    rl_story.flaggings_count = nil
    rl_story.revision = nil
    rl_story.is_display_inline = false
    if rl_story.save
      PiwikEvent.create(category:'Story',action:'Relevel',name:self.title)
    end
    rl_story
  end

  def create_new_derivation_without_pages(story_params,authors, current_user,derivation_type)
    authors = [authors] unless authors.is_a?Array
    new_story_attributes = self.dup.attributes.slice!('ancestry', 'organization_id', 'title', 'reads', 'cached_votes_total', 'uuid', 'origin_url', 'downloads', 'high_resolution_downloads', 'epub_downloads', 'is_display_inline', 'publisher_id', 'dummy_draft').merge!(story_params)
    if current_user.organization?
      new_story_attributes[:organization_id] = current_user.organization_id
    end
    new_story = self.children.new(new_story_attributes)
    new_story.derivation_type = derivation_type
    new_story.authors = authors
    new_story.copy_right_year = Time.now.year if new_story.copy_right_year.nil?
    new_story.title = Story.generate_title_for new_story if new_story.title.blank?
    new_story.categories << self.categories.dup
    new_story.is_autoTranslate = false
    new_story
  end

  def likes
    self.cached_votes_total
  end

  def is_active?(user)
    if user
      if draft? || edit_in_progress? 
        user.content_manager? || authors.include?(user) || (user.organization? && user.organization == self.organization) 
      elsif uploaded?
        user.reviewer? || user.content_manager? || authors.include?(user) || (user.organization? && user.organization == self.organization) 
      elsif published?
        true
      else
        false
      end
    else
      true 
    end
  end

  def send_pulled_down_notification(reason)
    flaggings = self.flaggings.where(:sent_mails => false)
    self.authors.each do |author|
      UserMailer.delay(:queue=>"mailer").pulled_down_story_mail(author,self,reason.split(","))
    end
    flaggings.each do |flagging|
      UserMailer.delay(:queue=>"mailer").story_flagger_email(flagging.flagger,self)
      flagging.update_attribute(:sent_mails, true)
    end
  end

  def recommendation_update(recommend)
    if recommend == "true"
      if self.recommendation
        self.recommendation.destroy
        self.delay.reindex
      end
      self.update_column(:editor_recommended, false)
    else
      unless self.recommendation
        recommendation = Recommendation.new
        recommendation.recommendable = self
        recommendation.save!
        self.update_column(:editor_recommended, true)
        self.delay.reindex
      end
    end
  end

  def insert_dedication_page
    if !self.pages.find_by_type("DedicationPage").present? && self.check_childrens_present?
      dedication_page = DedicationPage.new
      dedication_page.page_template = DedicationPageTemplate.of_orientation(self.orientation).default.try(:first)
      dedication_page.story = self
      last_story_page = self.pages.where(:type=>"StoryPage").last
      self.pages << dedication_page
      dedication_page.insert_at(last_story_page.position+1)
      pages.reload
    end
  end

  def check_childrens_present?
    if self.youngsters.size >=1
      self.youngsters.each do |y|
        if y.name.empty? || y.name.nil?
          return false
          break
        end
      end
      self.youngsters.each do |y|
        if y.age.nil?
          return false
          break
        end
      end
      true
    else
      false
    end
  end

  def user_rating
    rating_comment = ""
    ratings.all.each do |r|
      rating_comment += "<strong>#{r.user.name}</storng>-#{r.user_rating}<br/><p>#{r.user_comment}</p><hr/>".html_safe
    end
    rating_comment 
  end

  def title_for_draft_stories
    other_untitled_story_titles_by_author = authors.first
    .stories.unscoped
    .select(:title)
    .where("title like 'Untitled%'")
    .collect(&:title) rescue ['Untitled 0']

    current_highest_untitled_story_number = other_untitled_story_titles_by_author
    .map{|title| title.split(' ').last.to_i}
    .sort
    .last

    "Untitled #{current_highest_untitled_story_number}" rescue 'Untitled 1'
  end

  def update_revision
    self.revision = self.revision.nil? ? 1 : (self.revision + 1)
    self.uploading = false
    self.save!
  end

  def get_grace_time
    start_date = Date.parse "#{self.started_translation_at+3.weeks}"
    end_date = Date.today
    return (start_date - end_date).to_i
  end

  def self.translator_emails
     stories = Story.where(:is_autoTranslate => true, :status => Story.statuses[:draft])
                    .where.not(:started_translation_at => nil)
     stories.each do|story|
       if (story.started_translation_at+1.week).beginning_of_day == (Date.today).beginning_of_day
         story.authors.each do |f|
           UserMailer.translators_one_week_mail(f.email, story, f.first_name).deliver
         end
       elsif (story.started_translation_at+3.weeks-2.days).beginning_of_day == (Date.today).beginning_of_day
         story.authors.each do |f|
           UserMailer.translators_three_weeks_mail(f.email, story, f.first_name).deliver
         end
       elsif (story.started_translation_at+3.weeks).beginning_of_day == (Date.today).beginning_of_day
        language = story.language
        story.destroy
        story.auto_translate(language.id)
       end
     end
  end

  def self.generate_auto_translate_drafts
    language = Language.find_by_name("English")
    stories = Story.where(:status => Story.statuses[:published], :language => language)
                   .where.not(:organization_id => nil)
                   .reorder("created_at ASC")
    stories.each do|story|
      languages_list = ["French","Spanish"]
      languages_list.each do|language|
        lang = Language.find_by_name(language)
        rating_story = story.children.where(:language => lang.id,:organization_id => nil)
                            .joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                            .where("reviewer_comments.rating =?", 5)
        if !story.children.where(:language => lang.id).where.not(:organization_id => nil).any? || rating_story.count == 0
          story.auto_translate(lang.id) unless story.children.where(:language => lang.id, :is_autoTranslate => true).any?
        end
      end
    end 
  end

  def delete_auto_translate_drafts
      rating_story = self.root.children.where(:language => self.language.id, :organization_id => nil)
                              .joins("LEFT OUTER JOIN reviewer_comments ON stories.id = reviewer_comments.story_id")
                              .where("reviewer_comments.rating =?", 5)
      if self.root.children.where(:language => self.language.id).where.not(:organization_id => nil).any? || rating_story.count > 0
        self.destroy
        return false
      else
        return true
      end
  end

  def read_rating
    highest_read_count = Story.maximum("reads")
    (1..5).each do |i|
      return (5-i)+1 if ((2**i)*self.reads)/(highest_read_count+1) >= 1 # +1 to avoid divide-by-0 error
    end
    return 1 #If the reads are lesser than the highest_read_count/32
  end

  private
  def duplicate_pages_into(new_story)
    self.pages.each do |page|
      dup_page = page.dup
      dup_page.content = nil
      new_story.pages << dup_page
    end
  end

  def self.generate_title_for(story)
    other_untitled_story_titles_by_author = story.authors.first
    .stories.unscoped
    .select(:title)
    .where("title like 'Untitled%'")
    .collect(&:title) rescue ['Untitled 0']

    current_highest_untitled_story_number = other_untitled_story_titles_by_author
    .map{|title| title.split(' ').last.to_i}
    .sort
    .last

    "Untitled #{current_highest_untitled_story_number + 1}" rescue 'Untitled 1'
  end
end
