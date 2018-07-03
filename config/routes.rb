Rails.application.routes.draw do
  root 'react#index'
  #Added v0 prefix to all rails routes
  #Rails routes blocking offline saving if no prefix
  scope :v0 do

    get "/blog" => "blog_posts#index", as: :v0_blog_posts
    post "/blog" => "blog_posts#create", as: :v0_create_blog_post
    get '/blog/search', to: 'blog_posts#search', as: :v0_blog_search
    get '/blog/dashboard', to: 'blog_posts#dashboard', as: :v0_blog_dashboard
    get '/blog/drafts', to: 'blog_posts#drafts', as: :v0_blog_drafts
    get '/blog/scheduled_posts', to: 'blog_posts#scheduled_posts', as: :v0_blog_scheduled_posts
    get '/blog/de_activated', to: 'blog_posts#de_activated', as: :v0_blog_de_activated
    get '/blog/new_comments', to: 'blog_posts#new_comments', as: :v0_new_comments
    resources :blog_posts,  except: [:create, :index] do
      get :autocomplete_tag_name, :on => :collection
      resources :comments, only: [:create, :destroy]
    end

    # devise_for :users
    #devise_for :users, :skip=>[:omniauth_callbacks, :sessions], :controllers => { :registrations => 'registrations'}
    get '/lists/:id/download', to: "api/v1/lists#download", as: :list_download

    resources 'illustrations' do
      get :autocomplete_user_email, :on => :collection
      get :autocomplete_tag_name, :on => :collection
    end

    #Organization_routes
    get '/organizations/organization_sign_up_model', to: 'organizations#organization_sign_up_model', as: :organization_sign_up_model
    post '/organizations/organization_sign_up', to: 'organizations#organization_sign_up', as: :organization_sign_up
    get '/organizations/new_users', to: 'organizations#new_users', as: :new_users
    get '/organizations/organizations_list', to: 'organizations#organizations_list', as: :organizations_list
    get 'organizations/assign_org_role', to: 'organizations#assign_org_role', as: :assign_org_role
    get '/organizations/check_org_publisher', to: 'organizations#check_org_publisher', as: :check_org_publisher
    post '/organizations/add_org_logo', to: 'organizations#add_org_logo', as: :add_org_logo
    #get '/organizations/remove_site_role', to: 'organizations#remove_site_role', as: :remove_site_role
    get '/organizations/validate_org_name_country', to: 'organizations#validate_org_name_country', as: :validate_org_name_country
    get '/organizations/autocomplete', to: 'organizations#autocomplete', as: :organizations_autocomplete
    get 'organizations/remove_org_role_dialog', to: 'organizations#remove_org_role_dialog', as: :remove_org_role_dialog
    get 'organizations/remove_org_role', to: 'organizations#remove_org_role', as: :remove_org_role

    get '/illustrations/:id/new_flag_illustration', to: 'illustrations#new_flag_illustration' , as: :new_flag_illustration
    post '/illustrations/flag_illustration/:id', to: 'illustrations#flag_illustration' , as: :flag_illustration

    get '/illustrations/download/:id', to: 'illustrations#download', as: :download_illustrations
    get '/illustration-view/:id', to: 'illustrations#illustration_view', as: :view_illustration
    post '/illustrations/update_favorites', to: 'illustrations#update_favorites', as: :update_favorites
    post '/illustrations/reset_illustration_download_count', to: 'illustrations#reset_illustration_download_count', as: :reset_illustration_download_count

    resources 'stories',  except: [:show, :index] do
      resources 'pages' do
        get 'epub'
      end
      resources 'translations'
      resources 'relevels'
      member do
        patch 'publish'
      end
      get :autocomplete_tag_name, :on => :collection
    end
    get 'profile/change_translator' => 'profile#change_translator', as: :profile_change_translator

    get "/stories/new_story_from_illustration/:id", to: "stories#new_story_from_illustration", as: :new_story_from_illustration
    get "/stories/create_story_from_illustration", to: "stories#create_story_from_illustration", as: :create_story_from_illustration
    get '/stories/:id/editable', to: 'stories#editable' , as: :story_editor_editable
    post '/stories/reviewer_rating_comment', to: 'stories#reviewer_rating_comment', as: :reviewer_rating_comment
    get '/stories/edit_story_editor/:id', to: 'stories#edit_story_editor', as: :edit_story_editor
    patch '/stories/:id/assign_change_editor', to: 'stories#assign_change_editor', as: :assign_change_editor
    get '/stories/close_assign_dailog/:id', to: 'stories#close_assign_dailog', as: :close_assign_dailog
    post "/stories/recommend_story_on_home", to: "stories#recommend_story_on_home", as: :recommend_story_on_home
    get '/stories/download-story/:id', to: 'stories#download_story', as: :download_story
    post '/stories/reset_story_download_count', to: 'stories#reset_story_download_count', as: :reset_story_download_count

    get 'stories/show-in-iframe/:id', to: 'stories#show_in_iframe', as: :v0_show_story_in_iframe
    get 'stories/:id/story-review', to: 'stories#story_review', as: :story_review
    post 'stories/:id/reviewer-comments', to: "stories#reviewer_comments", as: :reviewer_comments
    get 'stories/review_next_story/:id', to: "stories#review_next_story", as: :review_next_story
    resources 'illustration_crops'

    # editor routes
    patch '/editor/:id/update_dummy_draft', to: "story_editor#update_dummy_draft", as: :update_dummy_draft
    get '/editor/story/user_email', to: 'story_editor#get_email', as: :story_editor_get_email
    get '/editor/story/:id', to: 'story_editor#story' , as: :story_editor
    get '/editor/illustration/:id', to: 'story_editor#illustration_for_crop' , as: :illustration_for_crop, :defaults => { :format => :json }
    post '/editor/:page_id/crop/:id', to: 'story_editor#crop_illustration' , as: :crop_illustration
    get '/editor/page/:id', to: 'story_editor#page_edit' , as: :page_edit
    put '/editor/page/:page_id/change_template/:id', to: 'story_editor#change_page_template' , as: :change_template
    put '/editor/story/:story_id/insert/:id', to: 'story_editor#insert_page' , as: :insert_page
    put '/editor/story/:story_id/duplicate/:id', to: 'story_editor#duplicate_page' , as: :duplicate_page
    delete '/editor/story/:story_id/delete/:id', to: 'story_editor#delete_page' , as: :delete_page
    post '/editor/page/:id/illustration', to: 'story_editor#update_page_illustration', as: :update_page_illustration
    get '/editor/page/:id/illustration', to: 'story_editor#remove_page_illustration', as: :remove_page_illustration
    post '/editor/page/:id/content', to: 'story_editor#update_page_content', as: :update_page_content
    post '/editor/page/:id/auto_save_content', to: 'story_editor#auto_save_content', as: :auto_save_content
    post '/editor/page/:id/save_content_on_blur', to: 'story_editor#save_content_on_blur', as: :save_content_on_blur
    post '/editor/story/:id/rearrange', to: 'story_editor#rearrange_page', as: :rearrange_page
    get '/editor/search/illustration', to: 'story_editor#search_illustration', as: :search_illustration
    get '/editor/new_illustration', to: 'story_editor#new_illustration', as: :editor_new_illustration
    post '/editor/create_illustration', to: 'story_editor#create_illustration', as: :editor_create_illustration
    get '/editor/story/:id/validate_pages', to: 'story_editor#validate_story_pages', as: :editor_validate_story_pages
    get '/editor/story/:id/publish', to: 'story_editor#publish_form', as: :editor_publish_story_form
    get '/editor/story/:id/edit_book_info', to: 'story_editor#edit_book_info', as: :editor_edit_book_info
    patch '/editor/story/:id/publish', to: 'story_editor#publish', as: :editor_publish_story
    patch '/editor/story/:id/update', to: 'story_editor#update', as: :editor_update_story
    patch '/editor/story/:id/update_book_info', to: 'story_editor#update_book_info', as: :editor_update_book_info
    get '/editor/autocomplete_user_email', to: 'story_editor#autocomplete_user_email', as: :autocomplete_user_email_path
    get '/editor/save_to_draft', to: 'story_editor#save_to_draft', as: :save_to_draft
    get '/editor/get-all-illustrations', to: 'story_editor#get_all_illustrations', as: :get_all_illustrations
    get '/editor/get-favourite-illustrations', to: 'story_editor#get_favourite_illustrations', as: :get_favourite_illustrations
    get '/editor/upload-illustration', to: 'story_editor#upload_illustration', as: :upload_illustration
    get '/editor/language_script', to: "story_editor#language_script", as: :story_language_script
    get "/editor/create", to: "stories#create_story", as: :create_story
    get "/editor/:story_id/translate", to: "translations#translate_story", as: :translate_story
    get "/editor/:story_id/relevel", to: "relevels#relevel_story", as: :relevel_story

    # illustration tags
    get '/illustration/edit-tags/:id', to: 'illustrations#edit_tags', as: :edit_illustration_tags
    patch '/illustration/:id/update-tags', to: 'illustrations#update_tags', as: :update_illustration_tags
    get 'illustration/:id/used_stories', to: 'illustrations#illustration_used_in_stories', as: :illustration_used_in_stories
    #contest routes
    get 'contests/:id/contest_winners_details', to: 'contests#contest_winners_details', as: :contest_winners_details
    resources :contests
    get '/contests/:id/details', to: 'contests#contest_details', as: :contest_details
    #contest_illustrations
    post '/illustrations/contest_image', to: 'illustrations#contest_image', as: :contest_image
    get '/contests/:id/submitted_stories', to: 'contests#submitted_stories', as: :contest_submitted_stories
    post '/contests/story_rating_comments', to: 'contests#story_rating_comments', as: :story_rating_comments
    post '/contests/user_update_rating_comments', to: 'contests#user_update_rating_comments', as: :user_update_rating_comments
    post '/contests/user_update_rating_without_comments', to: 'contests#user_update_rating_without_comments', as: :user_update_rating_without_comments
    get 'contests/:id/contest_draft_stories', to: 'contests#contest_draft_stories', as: :contest_draft_stories
    get 'contests/:id/illustration_contest_form', to: 'contests#illustration_form', as: :illustration_contest_form
    post 'contests/:id/create_illustration', to: 'contests#create_illustration', as: :create_illustration
    post '/contests/validate_illustration_name', to: 'contests#validate_illustration_name', as: :validate_illustration_name

    # dashboard routes
    get '/dashboard', to: 'dashboard#index'
    post '/dashboard/upload', to: 'dashboard#upload' , as: :upload
    get '/dashboard/images_upload_new', to: 'dashboard#images_upload_new' , as: :images_upload_new
    post '/dashboard/images_upload', to: 'dashboard#images_upload' , as: :images_upload
    get '/dashboard/roles', to: 'dashboard#roles', as: :roles
    get '/dashboard/remove_site_role_dialog', to: 'dashboard#remove_site_role_dialog', as: :remove_site_role_dialog
    get '/dashboard/remove_site_role', to: 'dashboard#remove_site_role', as: :remove_site_role
    post '/dashboard/set_role', to: 'dashboard#set_role', as: :set_role
    get '/dashboard/autocomplete', to: 'dashboard#autocomplete', as: :users_autocomplete
    get '/dashboard/autocomplete_user_email', to: 'dashboard#autocomplete_user_email', as: :autocomplete_user_email_dashboard

    # story categories
    get '/dashboard/story_categories', to: 'dashboard#story_categories', as: :story_categories
    post '/dashboard/story_category/edit/:id', to: 'dashboard#edit_story_category', as: :edit_story_category
    post '/dashboard/story_category/create', to: 'dashboard#create_story_category', as: :create_story_category

    # illustration categories
    get '/dashboard/illustration_categories', to: 'dashboard#illustration_categories', as: :illustration_categories
    post '/dashboard/illustration_category/edit/:id', to: 'dashboard#edit_illustration_category', as: :edit_illustration_category
    post '/dashboard/illustration_category/create', to: 'dashboard#create_illustration_category', as: :create_illustration_category

    # languages
    get '/dashboard/languages', to: 'dashboard#languages', as: :languages
    post '/dashboard/languages/create', to: 'dashboard#create_language', as: :create_language

    # styles
    get '/dashboard/styles', to: 'dashboard#styles', as: :styles
    post '/dashboard/styles/edit/:id', to: 'dashboard#edit_style', as: :edit_style
    post '/dashboard/styles/create', to: 'dashboard#create_style', as: :create_style

    #assign reviewer to uploaded stories
    post  '/dashboard/assign_editor_to_uploaded_story', to: 'dashboard#assign_editor_to_uploaded_story', as: :assign_editor_to_uploaded_story
    get 'dashboard/assign_editor_modal', to: 'dashboard#assign_editor_modal', as: :assign_editor_modal
    get 'dashboard/delete_editor_modal', to: 'dashboard#delete_editor_modal', as: :delete_editor_modal
    delete 'dashboard/delete_story_reviewer', to: 'dashboard#delete_story_reviewer', as: :delete_story_reviewer
    # flagged stories
    get '/dashboard/flagged_stories', to: 'dashboard#flagged_stories', as: :flagged_stories
    get '/dashboard/analytics', to: 'dashboard#analytics', as: :analytics
    get '/dashboard/most-read-stories', to: 'dashboard#most_read_stories', as: :most_read_stories
    get '/dashboard/most-viewed-illustrations', to: 'dashboard#most_viewed_illustrations', as: :most_viewed_illustrations
    get '/dashboard/most-used-illustrations', to: 'dashboard#most_used_illustrations', as: :most_used_illustrations
    get '/dashboard/most-downloaded-stories', to: 'dashboard#most_downloaded_stories', as: :most_downloaded_stories
    get '/dashboard/most-downloaded-illustrations', to: 'dashboard#most_downloaded_illustrations', as: :most_downloaded_illustrations
    get '/dashboard/flagged_illustrations', to: 'dashboard#flagged_illustrations', as: :flagged_illustrations
    get 'dashboard/all_stories', to: 'dashboard#all_stories', as: :all_stories
    get 'dashboard/lists', to: 'dashboard#lists', as: :lists
    get 'dashboard/update_lists', to: 'dashboard#update_lists', as: :update_lists
    get 'dashboard/all_illustrations', to: 'dashboard#all_illustrations', as: :all_illustrations
    get 'dashboard/organization_downloads', to: 'dashboard#organization_downloads', as: :organization_downloads
    get 'dashboard/organization_user/:id', to: 'dashboard#organization_user', as: :organization_user
    get 'dashboard/organization_users', to: 'dashboard#organization_users', as: :organization_users
    get '/dashboard/pull_down_story/:id', to: 'dashboard#pull_down_story', as: :pull_down_story
    get '/dashboard/clear_story_flag/:id', to: 'dashboard#clear_story_flag', as: :clear_story_flag
    get 'dashboard/stories_downloaded_list', to: 'dashboard#stories_downloaded_list', as: :stories_downloaded_list
    get 'dashboard/story_downloads_date_sort', to: 'dashboard#story_downloads_date_sort', as: :story_downloads_date_sort
    get 'dashboard/story_bulk_downloads', to: 'dashboard#story_bulk_downloads', as: :story_bulk_downloads
    get '/dashboard/languagewise_read_stories', to: 'dashboard#languagewise_read_stories', as: :languagewise_read_stories
    get '/dashboard/languages_added', to: 'dashboard#languages_added', as: :languages_added
    #pulled down stories
    get '/dashboard/pulled_down_stories', to: 'dashboard#pulled_down_stories', as: :pulled_down_stories
    get '/dashboard/pulled_down_illustrations', to: 'dashboard#pulled_down_illustrations', as: :pulled_down_illustrations

    # activate story
    get '/dashboard/activate_story/:id', to: 'dashboard#activate_story', as: :activate_story
    get '/dashboard/activate_illustration/:id', to: 'dashboard#activate_illustration', as: :activate_illustration

    # illustration
    get '/dashboard/pull_down_illustration/:id', to: 'dashboard#pull_down_illustration', as: :pull_down_illustration
    get '/dashboard/clear_illustration_flag/:id', to: 'dashboard#clear_illustration_flag', as: :clear_illustration_flag

    # recently published stories
    get 'dashboard/recently-published-stories', to: 'dashboard#recently_published', as: :recently_published_stories

    #donors
    get '/dashboard/donors', to: 'dashboard#donors', as: :donors
    post '/dashboard/donors/create', to: 'dashboard#create_donor', as: :create_donor
    delete '/dashboard/delete_donor/:id', to: 'dashboard#delete_donor' , as: :delete_donor
    get '/dashboard/private_images', to: 'dashboard#private_images', as: :dashboard_private_images

    get     '/category/:id', to: "dashboard#update_category" , as: :story_category
    get     '/pages/story_page_template/:id', to: 'pages#story_page_template' , as: :story_page_template
    get     '/stories/:story_id/navigate_to/:id', to: 'pages#navigate_to' , as: :page_navigate
    get     '/stories/:id/versions/language/:language/level/:reading_level', to: 'stories#versions', as: :story_versions
    resource :statistics

    #User Profile routes
    get     '/profile',                   to: 'profile#index',                    as: :profile
    get     '/profile/stories',           to: 'profile#stories',                  as: :profile_stories
    post    '/profile/edit',              to: 'profile#edit',                     as: :edit_profile
    get     '/profile/illustrations',     to: 'profile#illustrations',            as: :profile_illustrations
    get     '/profile/drafts',            to: 'profile#drafts',                   as: :profile_drafts
    get     '/profile/edit-in-progress',  to: 'profile#edit_in_progress',         as: :profile_edit_in_progress_stories
    delete  '/profile/delete_draft/:id',  to: 'profile#delete_draft',             as: :delete_draft_story
    get     '/profile/de_activated',      to: 'profile#deactivated_stories',      as: :profile_de_activated_stories
    get     '/profile/submitted',         to: 'profile#submitted_stories',        as: :profile_submitted_stories
    post    '/profile/flag_story',        to: 'profile#flag_story',               as: :profile_flag_story
    post    '/profile/flag_illustration', to: 'profile#flag_illustration',        as: :profile_flag_illustration
    get     '/profile/password/edit',     to: 'profile#edit_password',            as: :edit_password
    post    '/profile/password/update',   to: 'profile#update_password',          as: :update_password
    get     '/profile/un_edited_stories', to: 'profile#un_edited_stories',        as: :profile_un_edited_stories
    get     '/profile/edited_stories',    to: 'profile#edited_stories',           as: :profile_edited_stories
    get     '/profile/edit_story_flag',   to: 'profile#edit_story_flag',          as: :profile_edit_story_flag
    get     '/profile/review_guidelines', to: 'profile#review_guidelines',        as: :review_guidelines
    get     '/profile/translate_guidelines', to: 'profile#translate_guidelines',  as: :translate_guidelines

    get 'translator/un_translated_stories', to: 'profile#un_translated_stories', as: :translator_un_translated_stories
    get 'translator/translator_language_stories', to: 'profile#get_translator_language_stories', as: :get_translator_language_stories

    get 'reviewer/un_reviewed_stories', to: 'profile#un_reviewed_stories', as: :reviewer_un_reviewed_stories
    get 'reviewer/reviewed_stories', to: 'profile#reviewed_stories', as: :reviewer_reviewed_stories
    get 'reviewer/reviewer_language_stories', to: 'profile#get_reviewer_language_stories', as: :get_reviewer_language_stories

    #private images
    get 'profile/private_images', to: 'profile#private_images', as: :private_images
    get 'profile/make_image_public/:id', to: 'profile#make_image_public',  as: :make_image_public

    #organization user details
    get 'profile/user_organization_downloads', to: 'profile#user_organization_downloads', as: :user_organization_downloads
    get 'profile/user_org_details', to: 'profile#user_org_details', as: :user_org_details
    patch 'profile/edit_org', to: 'profile#edit_org', as: :edit_org
    post 'profile/org_logo', to: 'profile#org_logo', as: :org_logo
    post 'profile/profile_image', to: 'profile#profile_image', as: :profile_image

    #Getting pub logo link
    get 'profile/pub_logo', to: 'profile#get_pub_logo_path', as: :pub_logo
    #Getting level band path
    get 'story/level_band', to: 'stories#level_band', as: :level_band

    #Dynamic error page routs
    get '/404', to: "errors#error_404"
    get '/500', to: "errors#error_500"
    get '/422', to: "errors#error_422"

    #Static Page routes
    get '/about', to: 'contents#about' , as: :v0_about
    get '/story_weaver_and_you', to: 'contents#story_weaver_and_you' , as: :v0_story_weaver_and_you
    get '/campaign', to: 'contents#campaign' , as: :v0_campaign
    get '/our_supporters', to: 'contents#our_supporters' , as: :v0_our_supporters
    get '/volunteer', to: 'contents#volunteer' , as: :v0_volunteers
    get '/prathambooks', to: 'contents#prathambooks' , as: :v0_prathambooks
    get '/open_content', to: 'contents#open_content' , as: :v0_open_content
    get '/tutorials', to: 'contents#tutorials' , as: :v0_tutorials
    get '/uploading_an_illustration', to: 'contents#uploading_an_illustration' , as: :v0_uploading_an_illustration
    get '/writing_a_story', to: 'contents#writing_a_story' , as: :v0_writing_a_story
    get '/translation_tools_and_tips', to: 'contents#translation_tools_and_tips' , as: :v0_translation_tools_and_tips
    get '/dos_and_donts', to: 'contents#dos_and_donts' , as: :v0_dos_and_donts
    get '/reading_levels', to: 'contents#reading_levels' , as: :v0_reading_levels
    get '/terms_and_conditions', to: 'contents#terms_and_conditions' , as: :v0_terms_and_conditions
    get '/privacy_policy', to: 'contents#privacy_policy' , as: :v0_privacy_policy
    get '/disclaimer', to: 'contents#disclaimer' , as: :v0_disclaimer
    get '/press', to: 'contents#press' , as: :v0_press
    get '/picture_gallery', to: 'contents#picture_gallery' , as: :v0_picture_gallery
    get '/contact', to: 'contents#contact' , as: :v0_contact
    get '/careers', to: 'contents#careers' , as: :v0_careers
    get '/feedback_and_comments', to: 'contents#feedback_and_comments' , as: :v0_feedback_and_comments
    get '/faqs', to: 'contents#faqs' , as: :v0_faqs
    get '/past_campaigns', to: 'contents#past_campaigns' , as: :v0_past_campaigns
    get '/weave_a_story_campaign', to: 'contents#weave_a_story_campaign', as: :v0_weave_a_story_campaign
    get '/wonder_why_week', to: 'contents#wonder_why_week', as: :v0_wonder_why_week
    get '/phonestories' => "contests#phonestories", as: :v0_phonestories
    get '/phonestories/watchout' => "contests#watchout", as: :v0_watchout
    get '/phonestories/did_you_hear' => "contests#did_you_hear", as: :v0_did_you_hear
    get '/phonestories/wild_cat' => "contests#wild_cat", as: :v0_wild_cat
    get '/phonestories2' => "contests#phonestories2", as: :v0_phonestories2
    get '/phonestories2/miss_laya_fantastic_motorbike' => "contests#miss_laya_fantastic_motorbike", as: :v0_miss_laya_fantastic_motorbike
    get '/phonestories2/miss_laya_fantastic_motorbike_hungry' => "contests#miss_laya_fantastic_motorbike_hungry", as: :v0_miss_laya_fantastic_motorbike_hungry
    get '/phonestories2/miss_laya_fantastic_motorbike_big_box' => "contests#miss_laya_fantastic_motorbike_big_box", as: :v0_miss_laya_fantastic_motorbike_big_box
  end

  #static pages without v0 prefix
  get '/about', to: 'contents#about' , as: :about
  get '/story_weaver_and_you', to: 'contents#story_weaver_and_you' , as: :story_weaver_and_you
  get '/campaign', to: 'contents#campaign' , as: :campaign
  get '/our_supporters', to: 'contents#our_supporters' , as: :our_supporters
  get '/volunteer', to: 'contents#volunteer' , as: :volunteers
  get '/prathambooks', to: 'contents#prathambooks' , as: :prathambooks
  get '/open_content', to: 'contents#open_content' , as: :open_content
  get '/tutorials', to: 'contents#tutorials' , as: :tutorials
  get '/uploading_an_illustration', to: 'contents#uploading_an_illustration' , as: :uploading_an_illustration
  get '/writing_a_story', to: 'contents#writing_a_story' , as: :writing_a_story
  get '/translation_tools_and_tips', to: 'contents#translation_tools_and_tips' , as: :translation_tools_and_tips
  get '/dos_and_donts', to: 'contents#dos_and_donts' , as: :dos_and_donts
  get '/reading_levels', to: 'contents#reading_levels' , as: :reading_levels
  get '/terms_and_conditions', to: 'contents#terms_and_conditions' , as: :terms_and_conditions
  get '/privacy_policy', to: 'contents#privacy_policy' , as: :privacy_policy
  get '/disclaimer', to: 'contents#disclaimer' , as: :disclaimer
  get '/press', to: 'contents#press' , as: :press
  get '/in_the_news', to: 'contents#in_the_news' , as: :in_the_news
  get '/archive', to: 'contents#archive' , as: :archive
  get '/news_arch_2016', to: 'contents#news_arch_2016' , as: :news_arch_2016
  get '/news_arch_2015', to: 'contents#news_arch_2015' , as: :news_arch_2015
  get '/picture_gallery', to: 'contents#picture_gallery' , as: :picture_gallery
  get '/contact', to: 'contents#contact' , as: :contact
  get '/careers', to: 'contents#careers' , as: :careers
  get '/feedback_and_comments', to: 'contents#feedback_and_comments' , as: :feedback_and_comments
  get '/faqs', to: 'contents#faqs' , as: :faqs
  get '/past_campaigns', to: 'contents#past_campaigns' , as: :past_campaigns
  get '/weave_a_story_campaign', to: 'contents#weave_a_story_campaign', as: :weave_a_story_campaign
  get '/wonder_why_week', to: 'contents#wonder_why_week', as: :wonder_why_week
  get "/blog" => "blog_posts#index", as: :blog_posts
  get '/phonestories' => "contests#phonestories", as: :phonestories
  get '/phonestories/watchout' => "contests#watchout", as: :watchout
  get '/phonestories/did_you_hear' => "contests#did_you_hear", as: :did_you_hear
  get '/phonestories/wild_cat' => "contests#wild_cat", as: :wild_cat
  get '/phonestories2' => "contests#phonestories2", as: :phonestories2
  get '/phonestories2/miss_laya_fantastic_motorbike' => "contests#miss_laya_fantastic_motorbike", as: :miss_laya_fantastic_motorbike
  get '/phonestories2/miss_laya_fantastic_motorbike_hungry' => "contests#miss_laya_fantastic_motorbike_hungry", as: :miss_laya_fantastic_motorbike_hungry
  get '/phonestories2/miss_laya_fantastic_motorbike_big_box' => "contests#miss_laya_fantastic_motorbike_big_box", as: :miss_laya_fantastic_motorbike_big_box
  devise_for :users, controllers: { :sessions => 'sessions', omniauth_callbacks: 'users/omniauth_callbacks', :registrations => 'registrations'}
  post "/blog" => "blog_posts#create", as: :create_blog_post
  get '/blog/search', to: 'blog_posts#search', as: :blog_search
  get '/blog/dashboard', to: 'blog_posts#dashboard', as: :blog_dashboard
  get '/blog/drafts', to: 'blog_posts#drafts', as: :blog_drafts
  get '/blog/scheduled_posts', to: 'blog_posts#scheduled_posts', as: :blog_scheduled_posts
  get '/blog/de_activated', to: 'blog_posts#de_activated', as: :blog_de_activated
  get '/blog/new_comments', to: 'blog_posts#new_comments', as: :new_comments
  resources :blog_posts,  except: [:create, :index] do
    get :autocomplete_tag_name, :on => :collection
    resources :comments, only: [:create, :destroy]
  end
  mount Ckeditor::Engine => '/ckeditor'
  get 'stories/show-in-iframe/:id', to: 'stories#show_in_iframe', as: :show_story_in_iframe

  #React Pages
  get '/publishers/:id',    to: 'react#index', as: :react_publishers
  get '/organisations/:id', to: 'react#index', as: :react_organisations
  get '/users/:id',         to: 'react#index', as: :react_users
  get '/lists/:id',         to: 'react#index', as: :react_lists
  get '/stories/:id',       to: 'react#index', as: :react_stories_show
  get '/stories',           to: 'react#index', as: :react_stories
  get '/lists',             to: 'react#index', as: :react_lists_all
  get '/translate',         to: 'react#index', as: :react_stories_translate
  get '/translate/all',     to: 'react#index', as: :react_stories_translate_all
  get '/offline',           to: 'react#index', as: :react_offline
  get '/me/lists',          to: 'react#index', as: :react_me_lists
  get '/search',            to: 'react#index', as: :react_search
  get '/illustrations',     to: 'react#index', as: :react_illustrations
  get '/illustrations/:id',   to: 'react#index', as: :react_illustrations_show
  #robot
  get '/robots.txt' => 'home#robots'

  namespace :api, defaults: {format: 'json'} do
    namespace :v0 do
      # DATA EXCHANGE APIs
      get '/page_template/:uuid', to: 'data_exchange#fetch_page_template'      
      get '/illustration/:uuid', to: 'data_exchange#fetch_illustration'      
      get '/illustration_crop/:uuid', to: 'data_exchange#fetch_illustration_crop'
      get '/illustration_style/:uuid', to: 'data_exchange#fetch_illustration_style'
      get '/illustration_category/:uuid', to: 'data_exchange#fetch_illustration_category'
      get '/illustration_image/:uuid', to: 'data_exchange#fetch_illustration_img'      
      get '/illustrator/:uuid', to: 'data_exchange#fetch_illustrator'
      get '/language/:uuid', to: 'data_exchange#fetch_language'
      get '/story_category/:uuid', to: 'data_exchange#fetch_story_category'
      get '/user/:uuid', to: 'data_exchange#fetch_user'
      get '/story/:uuid', to: 'data_exchange#fetch_story'
      get '/story/pdf/:uuid', to: 'data_exchange#fetch_story_pdf'
      get '/story/epub/:uuid', to: 'data_exchange#fetch_story_epub'      
      get '/story_category_banner/:uuid', to: 'data_exchange#fetch_story_category_banner'
      get '/story_category_home_image/:uuid', to: 'data_exchange#fetch_story_category_home_image'
      get '/illustration_crop_image/:uuid', to: 'data_exchange#fetch_illustration_crop_img'            
      get '/language_font/:uuid', to: 'data_exchange#fetch_language_font'
      get '/story_uuid/:id', to: 'data_exchange#get_story_uuid'

      # DATA ANALYTICS APIs
      get '/analytics/story_read_count', to: 'analytics_data#get_story_read_count'
      get '/analytics/story_download_count', to: 'analytics_data#get_story_download_count'
      get '/analytics/illustration_view_count', to: 'analytics_data#get_illustration_view_count'
      get '/analytics/illustration_download_count', to: 'analytics_data#get_illustration_download_count'
      get '/analytics/illustration_reuse_count', to: 'analytics_data#get_illustration_reuse_count'
      get '/analytics/sw_translated_stories', to: 'analytics_data#get_sw_translated_stories'
      get '/analytics/sw_relevelled_stories', to: 'analytics_data#get_sw_relevelled_stories'      
      put '/analytics/track_event/:entity/:uuid', to: 'analytics_data#track_event'
    end
    namespace :v1 do
      devise_for :users, :skip => [:omniauth_callbacks]
      devise_scope :user do
        patch '/auth/:provider/callback' => 'omniauth_callbacks#create'
      end
      get '/home', to: 'home#show', as: :home
      get '/home/banners', to: 'home#banners', as: :banners
      get '/home/recommendations', to: 'home#recommendations', as: :recommendations
      get '/home/categories', to: 'home#categories', as: :categories
      get '/category-banner', to: 'search#category_banner', as: :category_banner
      get '/search', to: 'search#search', as: :search
      get '/books-search', to: 'search#books_search', as: :books_search
      get '/lists-search', to: 'search#lists_search', as: :lists_search
      get '/people-search', to: 'search#people_search', as: :people_search
      get '/org-search', to: 'search#org_search', as: :org_search
      get '/books-for-translation', to: 'search#books_for_translation', as: :books_for_translation
      get '/books/filters', to: 'stories#filters', as: :books_filters
      get 'books/translate-filters', to: 'stories#translate_filters', as: :translate_filters
      post '/illustration', to: 'illustrations#create', as: :illustration_create
      get '/illustrations/filters', to: 'illustrations#filters', as: :illustrations_filters
      get '/illustration-fields', to: 'illustrations#illustration_fields', as: :illustration_fields
      get '/illustrations-search', to: 'search#illustrations_search', as: :illustrations_search
      get '/illustrations/autocomplete_user_email', to: 'illustrations#autocomplete_user_email', as: :autocomplete_user_email_illustrations
      get '/illustrations/autocomplete_tag_name', to: 'illustrations#autocomplete_tag_name', as: :autocomplete_tag_name_illustrations
      get '/stories/:id', to: 'stories#show', as: :story
      get '/stories/:id/read', to: 'stories#story_read', as: :story_read
      post '/stories/:id/flag', to: 'stories#flag_story', as: :story_flag
      post '/stories/:id/like', to: 'stories#story_like', as: :story_like
      delete '/stories/:id/like', to: 'stories#story_unlike', as: :story_unlike
      post '/illustrations/:id/flag', to: 'illustrations#flag_illustration', as: :illustration_flag
      post '/illustrations/:id/like', to: 'illustrations#illustration_like', as: :illustration_like
      delete '/illustrations/:id/like', to: 'illustrations#illustration_unlike', as: :illustration_unlike
      get '/lists/filters', to: "lists#filters", as: :lists_filters
      get '/footer_images', to: "home#footer_images", as: :footer_images
      get '/illustrations/:id', to: 'illustrations#show', as: :illustration
      resources :lists
      resources :albums
      post '/lists/:id/like', to: "lists#list_like", as: :list_like
      delete '/lists/:id/like', to: "lists#list_unlike", as: :list_unlike
      post '/lists/:id/add_story/:story_id', to: "lists#add_story", as: :add_story_to_list
      delete '/lists/:id/remove_story/:story_id', to: "lists#remove_story", as: :remove_story_from_list
      delete '/lists/:id', to: "lists#destroy", as: :destroy_list
      post '/lists/:id/rearrange_story/:story_id', to: "lists#rearrange_story", as: :rearrange_story_in_list
      get '/me/lists', to: "lists#my_lists", as: :my_lists
      get '/get_categories', to: 'home#get_categories', as: :get_categories
      get '/users/:id', to: 'profile#user_details', as: :user_details
      get '/organisations/:id', to: 'profile#org_details', as: :org_details
      get '/publishers/:id', to: 'profile#org_details', as: :pub_details
      get '/me', to: 'home#me', as: :me
      get '/user/status', to: 'home#user_status', as: :user_status
      post '/users/:id/edit', to: 'profile#edit_user_details', as: :edit_user_details
      post '/organisations/:id/edit', to: 'profile#edit_org_details', as: :edit_org_details
      post '/subscription', to: 'home#subscription', as: :subscription
      post '/stories/:id/add_to_editor_picks', to: 'stories#add_to_editor_picks', as: :story_add_to_editor_picks
      post '/stories/:id/remove_from_editor_picks', to: 'stories#remove_from_editor_picks', as: :story_remove_from_to_editor_picks
      post '/set-locale/:locale', to: 'application#set_locale', as: :set_locale
      post '/open-popup', to: 'application#open_popup', as: :open_popup
      get '/organizations/autocomplete', to: 'organizations#autocomplete', as: :organizations_autocomplete
      put '/user/offline-book-popup-seen', to: 'profile#set_offline_book_popup_seen'
      put '/user/popup-seen', to: 'profile#set_popup_seen'
      get '/disable_notice', to: 'home#disable_notice', as: :disable_notice
    end
  end
end
