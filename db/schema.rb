# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180606050514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "albums", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.integer  "story_id"
  end

  create_table "albums_users", id: false, force: true do |t|
    t.integer "album_id", null: false
    t.integer "user_id",  null: false
  end

  add_index "albums_users", ["album_id", "user_id"], name: "index_albums_users_on_album_id_and_user_id", using: :btree
  add_index "albums_users", ["user_id", "album_id"], name: "index_albums_users_on_user_id_and_album_id", using: :btree

  create_table "authors_stories", id: false, force: true do |t|
    t.integer "user_id",  null: false
    t.integer "story_id", null: false
  end

  add_index "authors_stories", ["user_id", "story_id"], name: "author_story_index", using: :btree

  create_table "banners", force: true do |t|
    t.string   "name"
    t.boolean  "is_active",                 default: false
    t.string   "link_path"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "banner_image_file_name"
    t.string   "banner_image_content_type"
    t.integer  "banner_image_file_size"
    t.datetime "banner_image_updated_at"
  end

  create_table "blog_posts", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "status"
    t.datetime "scheduled"
    t.integer  "comments_count",               default: 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.integer  "reads",                        default: 0
    t.string   "blog_post_image_file_name"
    t.string   "blog_post_image_content_type"
    t.integer  "blog_post_image_file_size"
    t.datetime "blog_post_image_updated_at"
  end

  add_index "blog_posts", ["user_id"], name: "index_blog_posts_on_user_id", using: :btree

  create_table "child_illustrators", force: true do |t|
    t.string   "name"
    t.integer  "age"
    t.integer  "illustration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "child_illustrators", ["illustration_id"], name: "index_child_illustrators_on_illustration_id", using: :btree

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "blog_post_id"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["blog_post_id"], name: "index_comments_on_blog_post_id", using: :btree

  create_table "contests", force: true do |t|
    t.string   "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "contest_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_campaign",         default: false
    t.string   "tag_name"
    t.string   "custom_flash_notice"
  end

  create_table "contests_illustrations", force: true do |t|
    t.integer "illustration_id"
    t.integer "contest_id"
  end

  create_table "contests_languages", force: true do |t|
    t.integer "language_id"
    t.integer "contest_id"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "donors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "favorites", force: true do |t|
    t.integer  "story_id"
    t.integer  "illustration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flaggings", force: true do |t|
    t.string   "flaggable_type"
    t.integer  "flaggable_id"
    t.string   "flagger_type"
    t.integer  "flagger_id"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sent_mails",     default: false
  end

  add_index "flaggings", ["flaggable_type", "flaggable_id"], name: "index_flaggings_on_flaggable_type_and_flaggable_id", using: :btree
  add_index "flaggings", ["flagger_type", "flagger_id", "flaggable_type", "flaggable_id"], name: "access_flaggings", using: :btree

  create_table "footer_images", force: true do |t|
    t.integer  "illustration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "google_translated_versions", force: true do |t|
    t.integer  "page_id"
    t.text     "google_translated_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "illustration_categories", force: true do |t|
    t.string   "name",       limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "illustration_categories", ["name"], name: "index_illustration_categories_on_name", using: :btree

  create_table "illustration_categories_illustrations", id: false, force: true do |t|
    t.integer "illustration_category_id", null: false
    t.integer "illustration_id",          null: false
  end

  add_index "illustration_categories_illustrations", ["illustration_category_id", "illustration_id"], name: "category_illustration_index", using: :btree

  create_table "illustration_category_translations", force: true do |t|
    t.integer  "illustration_category_id", null: false
    t.string   "locale",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "translated_name"
  end

  add_index "illustration_category_translations", ["illustration_category_id"], name: "index_43c4a0cf6aaf12e5552cfcc03eab3de8e5c30d1a", using: :btree
  add_index "illustration_category_translations", ["locale"], name: "index_illustration_category_translations_on_locale", using: :btree

  create_table "illustration_crops", force: true do |t|
    t.integer  "illustration_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing"
    t.text     "crop_details"
    t.text     "image_meta"
    t.string   "storage_location"
    t.text     "smart_crop_details"
  end

  add_index "illustration_crops", ["illustration_id"], name: "index_illustration_crops_on_illustration_id", using: :btree

  create_table "illustration_downloads", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "illustration_id", null: false
    t.string   "download_type"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "illustration_downloads", ["user_id", "illustration_id"], name: "index_illustration_downloads_on_user_id_and_illustration_id", using: :btree

  create_table "illustration_style_translations", force: true do |t|
    t.integer  "illustration_style_id", null: false
    t.string   "locale",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "translated_name"
  end

  add_index "illustration_style_translations", ["illustration_style_id"], name: "index_illustration_style_translations_on_illustration_style_id", using: :btree
  add_index "illustration_style_translations", ["locale"], name: "index_illustration_style_translations_on_locale", using: :btree

  create_table "illustration_styles", force: true do |t|
    t.string   "name",       limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "illustration_styles_illustrations", id: false, force: true do |t|
    t.integer "illustration_style_id", null: false
    t.integer "illustration_id",       null: false
  end

  add_index "illustration_styles_illustrations", ["illustration_id", "illustration_style_id"], name: "illustration_style_index", using: :btree
  add_index "illustration_styles_illustrations", ["illustration_style_id", "illustration_id"], name: "style_illustration_index", using: :btree

  create_table "illustrations", force: true do |t|
    t.string   "name",                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "uploader_id"
    t.text     "attribution_text"
    t.integer  "license_type"
    t.boolean  "image_processing"
    t.integer  "flaggings_count"
    t.integer  "copy_right_year"
    t.text     "image_meta"
    t.integer  "cached_votes_total",       default: 0
    t.integer  "reads",                    default: 0
    t.boolean  "is_pulled_down",           default: false
    t.integer  "publisher_id"
    t.integer  "copy_right_holder_id"
    t.boolean  "image_mode",               default: false
    t.string   "storage_location"
    t.boolean  "is_bulk_upload",           default: false
    t.text     "smart_crop_details"
    t.integer  "organization_id"
    t.integer  "org_copy_right_holder_id"
    t.integer  "album_id"
  end

  add_index "illustrations", ["album_id"], name: "index_illustrations_on_album_id", using: :btree
  add_index "illustrations", ["cached_votes_total"], name: "index_illustrations_on_cached_votes_total", using: :btree

  create_table "illustrations_photographers", id: false, force: true do |t|
    t.integer "user_id",         null: false
    t.integer "illustration_id", null: false
  end

  add_index "illustrations_photographers", ["user_id", "illustration_id"], name: "photographer_illustration_index", using: :btree

  create_table "illustrators_illustrations", id: false, force: true do |t|
    t.integer "person_id",       null: false
    t.integer "illustration_id", null: false
  end

  add_index "illustrators_illustrations", ["person_id", "illustration_id"], name: "illustrator_illustration_index", using: :btree

  create_table "institutional_users", force: true do |t|
    t.integer  "user_id"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_of_classrooms"
    t.integer  "children_impacted"
    t.string   "organization_name"
    t.string   "city"
  end

  create_table "language_fonts", force: true do |t|
    t.string   "font"
    t.string   "script"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "language_translations", force: true do |t|
    t.integer  "language_id",     null: false
    t.string   "locale",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "translated_name"
  end

  add_index "language_translations", ["language_id"], name: "index_language_translations_on_language_id", using: :btree
  add_index "language_translations", ["locale"], name: "index_language_translations_on_locale", using: :btree

  create_table "languages", force: true do |t|
    t.string   "name",              limit: 32,                 null: false
    t.boolean  "is_right_to_left",             default: false
    t.boolean  "can_transliterate",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "script"
    t.string   "locale"
    t.boolean  "bilingual",                    default: false
    t.integer  "language_font_id"
    t.string   "level_band"
  end

  add_index "languages", ["name"], name: "index_languages_on_name", using: :btree

  create_table "list_categories", force: true do |t|
    t.string   "name",       limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "list_categories", ["name"], name: "index_list_categories_on_name", using: :btree

  create_table "list_categories_lists", id: false, force: true do |t|
    t.integer "list_category_id", null: false
    t.integer "list_id",          null: false
  end

  add_index "list_categories_lists", ["list_category_id", "list_id"], name: "category_list_index", using: :btree

  create_table "list_category_translations", force: true do |t|
    t.integer  "list_category_id", null: false
    t.string   "locale",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "translated_name"
  end

  add_index "list_category_translations", ["list_category_id"], name: "index_list_category_translations_on_list_category_id", using: :btree
  add_index "list_category_translations", ["locale"], name: "index_list_category_translations_on_locale", using: :btree

  create_table "list_downloads", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "list_id",    null: false
    t.datetime "when"
    t.string   "ip_address"
  end

  add_index "list_downloads", ["user_id", "list_id"], name: "index_list_downloads_on_user_id_and_list_id", using: :btree

  create_table "list_likes", force: true do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "list_likes", ["list_id", "user_id"], name: "index_list_likes_on_list_id_and_user_id", using: :btree

  create_table "list_views", force: true do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "list_views", ["list_id", "user_id"], name: "index_list_views_on_list_id_and_user_id", using: :btree

  create_table "lists", force: true do |t|
    t.string   "title"
    t.string   "description",     limit: 1000
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "status",                       default: 0,     null: false
    t.string   "synopsis",        limit: 750
    t.boolean  "can_delete",                   default: true
    t.boolean  "is_default_list",              default: false
  end

  create_table "lists_stories", force: true do |t|
    t.integer  "list_id",                null: false
    t.integer  "story_id",               null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "how_to_use", limit: 750
  end

  add_index "lists_stories", ["list_id", "story_id"], name: "index_lists_stories_on_list_id_and_story_id", using: :btree
  add_index "lists_stories", ["list_id", "story_id"], name: "lists_stories_index", using: :btree

  create_table "media_mentions", force: true do |t|
    t.integer  "blog_post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  add_index "media_mentions", ["blog_post_id", "user_id"], name: "index_media_mentions_on_blog_post_id_and_user_id", using: :btree

  create_table "organization_translations", force: true do |t|
    t.integer  "organization_id",   null: false
    t.string   "locale",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "organization_name"
    t.string   "translated_name"
  end

  add_index "organization_translations", ["locale"], name: "index_organization_translations_on_locale", using: :btree
  add_index "organization_translations", ["organization_id"], name: "index_organization_translations_on_organization_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "organization_name"
    t.string   "organization_type"
    t.string   "country"
    t.string   "city"
    t.integer  "number_of_classrooms"
    t.integer  "children_impacted"
    t.string   "status"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description",          limit: 1000
    t.string   "email"
    t.string   "website"
    t.string   "facebook_url"
    t.string   "rss_url"
    t.string   "twitter_url"
    t.string   "youtube_url"
  end

  add_index "organizations", ["email"], name: "index_organizations_on_email", using: :btree

  create_table "page_templates", force: true do |t|
    t.string   "name"
    t.string   "orientation"
    t.string   "image_position"
    t.string   "content_position"
    t.float    "image_dimension"
    t.float    "content_dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "default",           default: false
  end

  add_index "page_templates", ["orientation"], name: "index_page_templates_on_orientation", using: :btree

  create_table "pages", force: true do |t|
    t.integer  "page_template_id"
    t.integer  "story_id"
    t.text     "content"
    t.float    "crop_height"
    t.float    "crop_width"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "illustration_crop_id"
  end

  add_index "pages", ["position", "illustration_crop_id"], name: "index_pages_on_position_and_illustration_crop_id", using: :btree
  add_index "pages", ["story_id", "page_template_id"], name: "index_pages_on_story_id_and_page_template_id", using: :btree

  create_table "people", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_publisher_id"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "people", ["created_by_publisher_id"], name: "index_people_on_created_by_publisher_id", using: :btree

  create_table "phone_stories", force: true do |t|
    t.integer  "story_id"
    t.text     "text"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phonestories_popups", force: true do |t|
    t.integer  "user_id"
    t.boolean  "popup_opened", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "piwik_events", force: true do |t|
    t.string   "category",   null: false
    t.string   "action",     null: false
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pulled_downs", force: true do |t|
    t.string   "pulled_down_type"
    t.integer  "pulled_down_id"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pulled_downs", ["pulled_down_type", "pulled_down_id"], name: "index_pulled_downs_on_pulled_down_type_and_pulled_down_id", using: :btree

  create_table "ratings", force: true do |t|
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "user_id"
    t.string   "user_comment"
    t.float    "user_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["rateable_id", "rateable_type"], name: "index_ratings_on_rateable_id_and_rateable_type", using: :btree

  create_table "re_published_stories", force: true do |t|
    t.integer  "story_id"
    t.integer  "previous_status"
    t.datetime "published_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", force: true do |t|
    t.integer  "recommendable_id"
    t.string   "recommendable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviewer_comments", force: true do |t|
    t.integer  "story_id"
    t.integer  "user_id"
    t.integer  "story_rating"
    t.integer  "language_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
    t.integer  "language_id"
    t.text     "comments"
  end

  create_table "reviewers_languages", id: false, force: true do |t|
    t.integer  "user_id",     null: false
    t.integer  "language_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviewers_languages", ["user_id", "language_id"], name: "reviewers_languages_index", using: :btree

  create_table "stories", force: true do |t|
    t.string   "title",                                                       null: false
    t.string   "english_title"
    t.integer  "language_id",                                                 null: false
    t.integer  "reading_level",                                               null: false
    t.integer  "status",                                default: 0,           null: false
    t.string   "synopsis",                  limit: 750
    t.integer  "publisher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.string   "derivation_type"
    t.text     "attribution_text"
    t.boolean  "recommended",                           default: false
    t.integer  "reads",                                 default: 0
    t.integer  "flaggings_count"
    t.string   "orientation"
    t.integer  "copy_right_year"
    t.integer  "cached_votes_total",                    default: 0
    t.integer  "topic_id"
    t.string   "license_type",                          default: "CC BY 4.0"
    t.datetime "published_at"
    t.integer  "downloads",                             default: 0
    t.integer  "high_resolution_downloads",             default: 0
    t.integer  "epub_downloads",                        default: 0
    t.boolean  "chaild_created",                        default: false
    t.string   "dedication"
    t.integer  "recommended_status"
    t.string   "more_info"
    t.integer  "donor_id"
    t.integer  "copy_right_holder_id"
    t.string   "credit_line"
    t.integer  "contest_id"
    t.integer  "editor_id"
    t.boolean  "editor_status",                         default: false
    t.boolean  "user_title",                            default: false
    t.boolean  "editor_recommended",                    default: false
    t.integer  "revision"
    t.boolean  "uploading",                             default: false
    t.integer  "images_only",                           default: 0
    t.integer  "text_only",                             default: 0
    t.datetime "started_translation_at"
    t.boolean  "is_autoTranslate"
    t.text     "publish_message"
    t.text     "download_message"
    t.boolean  "is_display_inline",                     default: true
    t.integer  "organization_id"
    t.string   "recommendations"
    t.boolean  "dummy_draft",                           default: true
  end

  add_index "stories", ["ancestry"], name: "index_stories_on_ancestry", using: :btree
  add_index "stories", ["cached_votes_total"], name: "index_stories_on_cached_votes_total", using: :btree
  add_index "stories", ["language_id", "organization_id"], name: "index_stories_on_language_id_and_organization_id", using: :btree

  create_table "stories_downloads", id: false, force: true do |t|
    t.integer "story_download_id", null: false
    t.integer "story_id",          null: false
  end

  add_index "stories_downloads", ["story_download_id", "story_id"], name: "stories_downloads_index", using: :btree

  create_table "stories_story_categories", id: false, force: true do |t|
    t.integer "story_category_id", null: false
    t.integer "story_id",          null: false
  end

  add_index "stories_story_categories", ["story_category_id", "story_id"], name: "category_story_index", using: :btree

  create_table "story_categories", force: true do |t|
    t.string   "name",                             limit: 32,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",                                     default: false
    t.integer  "contest_id"
    t.boolean  "active_on_home",                              default: false
    t.string   "category_banner_file_name"
    t.string   "category_banner_content_type"
    t.integer  "category_banner_file_size"
    t.datetime "category_banner_updated_at"
    t.string   "category_home_image_file_name"
    t.string   "category_home_image_content_type"
    t.integer  "category_home_image_file_size"
    t.datetime "category_home_image_updated_at"
  end

  add_index "story_categories", ["name"], name: "index_story_categories_on_name", using: :btree

  create_table "story_category_translations", force: true do |t|
    t.integer  "story_category_id", null: false
    t.string   "locale",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "translated_name"
  end

  add_index "story_category_translations", ["locale"], name: "index_story_category_translations_on_locale", using: :btree
  add_index "story_category_translations", ["story_category_id"], name: "index_story_category_translations_on_story_category_id", using: :btree

  create_table "story_downloads", force: true do |t|
    t.integer  "user_id",                           null: false
    t.integer  "story_id",                          null: false
    t.string   "download_type"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "organization_user", default: false
    t.integer  "org_id"
    t.integer  "list_id"
  end

  add_index "story_downloads", ["story_id", "user_id"], name: "index_story_downloads_on_story_id_and_user_id", using: :btree

  create_table "story_reads", force: true do |t|
    t.integer  "story_id"
    t.integer  "user_id"
    t.boolean  "is_completed", default: false
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "story_reads", ["story_id", "user_id"], name: "index_story_reads_on_story_id_and_user_id", using: :btree

  create_table "subscriptions", force: true do |t|
    t.string   "email",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "templates", force: true do |t|
    t.string   "name"
    t.string   "orientation"
    t.string   "image_position"
    t.string   "content_position"
    t.integer  "image_dimension"
    t.integer  "content_dimension"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translators_languages", id: false, force: true do |t|
    t.integer  "user_id",     null: false
    t.integer  "language_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translators_languages", ["user_id", "language_id"], name: "translators_languages_index", using: :btree

  create_table "user_popups", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                                   default: "",     null: false
    t.string   "encrypted_password",                      default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "type",                                    default: "User", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role",                                                     null: false
    t.string   "attribution",                limit: 1024
    t.string   "bio",                        limit: 512
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "flaggings_count"
    t.boolean  "email_preference",                        default: true
    t.text     "logo_meta"
    t.integer  "organization_id"
    t.string   "organization_roles"
    t.string   "auth_token"
    t.string   "website"
    t.string   "city"
    t.datetime "org_registration_date"
    t.boolean  "tour_status",                             default: false
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type"
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.boolean  "editor_feedback",                         default: false
    t.string   "language_preferences"
    t.string   "reading_levels"
    t.string   "site_roles"
    t.string   "recommendations"
    t.string   "locale_preferences"
    t.boolean  "offline_book_popup_seen",                 default: false
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

  create_table "winners", force: true do |t|
    t.integer  "story_id"
    t.integer  "contest_id"
    t.string   "story_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "youngsters", force: true do |t|
    t.string   "name"
    t.integer  "age"
    t.integer  "story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "youngsters", ["story_id"], name: "index_youngsters_on_story_id", using: :btree

end
