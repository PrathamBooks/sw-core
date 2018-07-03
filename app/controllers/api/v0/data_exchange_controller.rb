class Api::V0::DataExchangeController < Api::V0::ApplicationController

  before_action :authenticate_story_request, only: [:fetch_story, :fetch_story_pdf, :fetch_story_epub]
  before_action :authenticate_image_request, only: [:fetch_story_category_banner, :fetch_story_category_home_image, :fetch_illustration_img, :fetch_illustration_crop_img]
  before_action :authenticate_entity_request, only: [:fetch_illustration, :fetch_illustration_crop, :fetch_page_template, :fetch_illustration_style, :fetch_illustration_category,
	  :fetch_illustrator, :fetch_illustration_illustrator, :fetch_language, :fetch_language_font, :fetch_user, :fetch_story_category, :get_story_uuid] 

  # TODOS: Add language font ID

  swagger_controller :data_exchange, 'Date Exchange'

  swagger_api :fetch_page_template do
    summary "Fetch Page Template"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_illustration do
    summary "Fetch Illustration"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_illustration_crop do
    summary "Fetch Illustration Crop"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_illustration_style do
    summary "Fetch Illustration Style"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_illustration_category do
    summary "Fetch Illustration Category"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_illustrator do
    summary "Fetch Illustrator"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_illustration_illustrator do
    summary "Fetch Illustration Illustrator"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_language do
    summary "Fetch Language"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_language_font do
    summary "Fetch Language Font"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_user do
    summary "Fetch User"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_story_category do
    summary "Fetch Story Category"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :get_story_uuid do
    summary "Get Story Uuid"
    param :path, :id, :string, :required, "ID of the story in host system"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_story do
    summary "Fetch Story"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"    
    response :unauthorized    
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_story_pdf do
    summary "Fetch Story PDF file"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"    
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_story_epub do
    summary "Fetch Story ePUB file"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"        
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_story_category_banner do
    summary "Fetch Story Category Banner Image"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_story_category_home_image do
    summary "Fetch Story Category Home Image"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_illustration_img do
    summary "Fetch Illustration Image"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  swagger_api :fetch_illustration_crop_img do
    summary "Fetch Illustration Crop Image"
    param :path, :uuid, :string, :required, "System Independent Unique Identifier"
    param :query, :token, :string, :required, "Access Token"
    response :not_acceptable
    response :not_found
  end

  def authenticate_entity_request
    if params[:token].nil? || params[:token].empty?
      render json: {error: 'No token present'}, status: :unauthorized
      return
    end

    token = Token.find_by_access_token params[:token]

    if token.nil?
      render json: {error: 'Incorrect token'}, status: :unauthorized
      return
    end

    if !(Time.now < token.expires_at)
      render json: {error: 'Invalid token'}, status: :unauthorized
      return
    end
  end

  def authenticate_image_request
    if params[:token].nil? || params[:token].empty?
      render json: {error: 'No token present'}, status: :unauthorized
      return
    end

    token = Token.find_by_access_token params[:token]

    if token.nil?
      render json: {error: 'Incorrect token'}, status: :unauthorized
      return
    end

    if !(Time.now < token.expires_at && token.illustration_count > 0)
      render json: {error: 'Invalid token'}, status: :unauthorized
      return
    end	
  end

  def authenticate_story_request
    if params[:token].nil? || params[:token].empty?
      render json: {error: 'No token present'}, status: :unauthorized
      return
    end

    token = Token.find_by_access_token params[:token]

    if token.nil?
      render json: {error: 'Incorrect token'}, status: :unauthorized
      return
    end

    if !(Time.now < token.expires_at && token.story_count > 0)
      render json: {error: 'Invalid token'}, status: :unauthorized
      return
    end 
  end

  def fetch_page_template
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    pt_obj = PageTemplate.find_by_uuid params[:uuid]

    if pt_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    pt_data = {
      :name              => pt_obj.name,
      :orientation       => pt_obj.orientation,
      :image_position    => pt_obj.image_position,
      :content_position  => pt_obj.content_position,
      :image_dimension   => pt_obj.image_dimension,
      :content_dimension => pt_obj.content_dimension,
      :type              => pt_obj.type,
      :default           => pt_obj.default,
      :origin_url        => pt_obj.origin_url,
      :uuid              => pt_obj.uuid
    }

    render json: pt_data.to_json, status: 200    
  end
  
  def fetch_illustration
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    i_obj = Illustration.find_by_uuid params[:uuid]

    if i_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    uploader_uuid = (i_obj.uploader_id == nil) ? nil : i_obj.uploader.uuid

    i_data = {
      :name                     => i_obj.name,
      :image_path               => i_obj.image.path,
      :uploader_uuid            => uploader_uuid,
      :attribution_text         => i_obj.attribution_text,
      :license_type             => i_obj.license_type,
      :image_processing         => i_obj.image_processing,
      :flaggings_count          => i_obj.flaggings_count,
      :copy_right_year          => i_obj.copy_right_year,
      :image_meta               => i_obj.image_meta,
      :is_pulled_down           => i_obj.is_pulled_down,         
      :publisher_id             => i_obj.publisher_id,
      :copy_right_holder_id     => i_obj.copy_right_holder_id,
      :image_mode               => i_obj.image_mode,         
      :storage_location         => i_obj.storage_location,
      :is_bulk_upload           => i_obj.is_bulk_upload,         
      :smart_crop_details       => i_obj.smart_crop_details,
      :organization_id          => i_obj.organization_id,
      :org_copy_right_holder_id => i_obj.org_copy_right_holder_id,
      :style_uuids              => i_obj.styles.map(&:uuid),
      :category_uuids           => i_obj.categories.map(&:uuid),
      :illustrator_uuids        => i_obj.illustrators.map(&:uuid),
      :uuid                     => i_obj.uuid      
    }

    render json: i_data.to_json, status: 200
  end

  def fetch_illustration_crop
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    icrop_obj = IllustrationCrop.find_by_uuid params[:uuid]

    if icrop_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    illustration_uuid = (icrop_obj.illustration_id == nil) ? nil : icrop_obj.illustration.uuid

    icrop_data = {
      illustration_uuid:  illustration_uuid,
      image_path:         icrop_obj.image.path,
      image_processing:   icrop_obj.image_processing,      
      crop_details:       icrop_obj.crop_details,
      image_meta:         icrop_obj.image_meta,
      storage_location:   icrop_obj.storage_location,
      smart_crop_details: icrop_obj.smart_crop_details,
      uuid:               icrop_obj.uuid  
    }

    render json: icrop_data.to_json, status: 200
  end

  def fetch_illustration_style
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    i_style_obj = IllustrationStyle.find_by_uuid params[:uuid]

    if i_style_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    i_style_data = {
      name:         i_style_obj.name,
      uuid:         i_style_obj.uuid  
    }

    render json: i_style_data.to_json, status: 200
  end

  def fetch_illustration_category
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    i_category_obj = IllustrationCategory.find_by_uuid params[:uuid]

    if i_category_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    i_category_data = {
      name:         i_category_obj.name,
      uuid:         i_category_obj.uuid  
    }

    render json: i_category_data.to_json, status: 200
  end

  def fetch_illustrator
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    i_illustrator_obj = Person.find_by_uuid params[:uuid]

    if i_illustrator_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    user_uuid = (i_illustrator_obj.user == nil) ? nil : i_illustrator_obj.user.uuid

    i_illustrator_data = {
      user_uuid:               user_uuid,
      first_name:              i_illustrator_obj.first_name, 
      last_name:               i_illustrator_obj.last_name,
      uuid:                    i_illustrator_obj.uuid  
    }

    render json: i_illustrator_data.to_json, status: 200
  end
  
  def fetch_language
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    lang_obj = Language.find_by_uuid params[:uuid]

    if lang_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end
    
    language_font_uuid = (lang_obj.language_font_id == nil) ? nil : lang_obj.language_font.uuid

    lang_data = {
      :name                => lang_obj.name,
      :translated_name     => lang_obj.translated_name,
      :is_right_to_left    => lang_obj.is_right_to_left,
      :can_transliterate   => lang_obj.can_transliterate,
      :script              => lang_obj.script,
      :locale              => lang_obj.locale,
      :bilingual           => lang_obj.bilingual,
      :language_font_uuid  => language_font_uuid,
      :level_band          => lang_obj.level_band,
      :uuid                => lang_obj.uuid
    } 
    
    render json: lang_data.to_json, status: 200
  end

  def fetch_language_font
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    lang_font_obj = LanguageFont.find_by_uuid params[:uuid]

    if lang_font_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end
    
    lang_font_data = {
      :font   => lang_font_obj.font,  
      :script => lang_font_obj.script, 
      :uuid   => lang_font_obj.uuid      
    } 
    
    render json: lang_font_data.to_json, status: 200
  end

  def fetch_user
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    user_obj = User.find_by_uuid params[:uuid]

    if user_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    user_data = {
      :name         => user_obj.name,
      :uuid         => user_obj.uuid  
    } 
    
    render json: user_data.to_json, status: 200
  end

  def fetch_story_category
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    story_category_obj = StoryCategory.find_by_uuid params[:uuid]

    if story_category_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    story_category_data = {
      :name                             => story_category_obj.name,
      :private                          => story_category_obj.private,
      :active_on_home                   => story_category_obj.active_on_home,
      :uuid                             => story_category_obj.uuid,
      :banner_path                      => story_category_obj.category_banner.path,
      :home_image_path                  => story_category_obj.category_home_image.path
    } 
    
    render json: story_category_data.to_json, status: 200
  end

  def get_story_uuid
    if params[:id].nil? || params[:id].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    s_obj = Story.find_by_id params[:id]

    if s_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    render json: {:uuid => s_obj.uuid}.to_json, status: 200  
  end

  def fetch_story
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    s_obj = Story.find_by_uuid params[:uuid]

    if s_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    decrease_story_count(params[:token])
    
    story_pages = []
    s_obj.pages.each do |curr_page|
      page_template_uuid = (curr_page.page_template_id == nil) ? nil : curr_page.page_template.uuid
      illustration_crop_uuid = (curr_page.illustration_crop_id == nil) ? nil : curr_page.illustration_crop.uuid
      story_pages << {
        content:                curr_page.content,
        position:               curr_page.position,
        type:                   curr_page.type,
        page_template_uuid:     page_template_uuid,
        illustration_crop_uuid: illustration_crop_uuid
      }
    end  

    language_uuid = (s_obj.language_id == nil) ? nil : s_obj.language.uuid

    copy_right_holder_uuid = (s_obj.copy_right_holder_id == nil) ? nil : s_obj.copy_right_holder.uuid

    story_data = {
      title:                  s_obj.title,   
      attribution_text:       s_obj.attribution_text,
      language_uuid:          language_uuid,
      english_title:          s_obj.english_title, 
      reading_level:          s_obj.reading_level,
      status:                 s_obj.status,
      copy_right_year:        s_obj.copy_right_year,
      synopsis:               s_obj.synopsis,
      story_category_uuids:   s_obj.categories.map(&:uuid),
      pages:                  story_pages,
      orientation:            s_obj.orientation,
      author_uuids:           s_obj.authors.map(&:uuid),
      more_info:              s_obj.more_info,
      copy_right_holder_uuid: copy_right_holder_uuid,
      published_at:           s_obj.published_at,
      tag_list:               s_obj.tag_list,
      ancestry:               s_obj.ancestry,
      uuid:                   s_obj.uuid
    }

    render json: story_data.to_json, status: 200
  end

  def fetch_story_pdf
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    story = Story.find_by_uuid params[:uuid]

    if story.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    decrease_story_count(params[:token])    

    story_revision = story.revision.nil? ? '' : ('_'+(story.revision).to_s)

    if Rails.env.production?
      directory = fog_directory
      file = directory.files.get("stories/#{story.id}/pdfs/low/#{story.to_param}#{story_revision}.pdf").public_url
      filename = "#{story.to_param}.pdf"
      data = open(file)
      send_data data.read, :filename=>filename, :dispostion=>'inline', :stream => true
    else
      send_file "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}/pdfs/low/#{story.to_param}#{story_revision}.pdf", :filename=>"#{story.to_param}.pdf", :dispostion=>'inline'
    end
  end

  def fetch_story_epub
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    story = Story.find_by_uuid params[:uuid]

    if story.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    decrease_story_count(params[:token])

    story_revision = story.revision.nil? ? '' : ('_'+(story.revision).to_s)

    if Rails.env.production?
      directory = fog_directory
      file = directory.files.get("stories/#{story.id}/epub/#{story.to_param}#{story_revision}.epub").public_url
      filename = "#{story.to_param}.epub"
      data = open(file)
      send_data data.read, :filename=>filename, :dispostion=>'inline', :stream => true
    else
      send_file "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}/epub/#{story.to_param}#{story_revision}.epub", :filename=>"#{story.to_param}.epub", :dispostion=>'inline'
    end
  end

  def fetch_story_category_banner
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    story_category_obj = StoryCategory.find_by_uuid params[:uuid]

    if story_category_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    if Rails.env.production?
      directory = fog_directory
      file = directory.files.get(story_category_obj.category_banner.path).public_url
      data = open(file)
      send_data data.read, :dispostion=>'inline', :stream => true
    else
      send_file "#{Rails.root}/public/#{Settings.fog.directory}/#{story_category_obj.category_banner.path}", :disposition => 'inline'
    end
  end
  
  def fetch_story_category_home_image
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    story_category_obj = StoryCategory.find_by_uuid params[:uuid]

    if story_category_obj.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    if Rails.env.production?
      directory = fog_directory
      file = directory.files.get(story_category_obj.category_home_image.path).public_url
      data = open(file)
      send_data data.read, :dispostion=>'inline', :stream => true
    else
      send_file "#{Rails.root}/public/#{Settings.fog.directory}/#{story_category_obj.category_home_image.path}", :disposition => 'inline'
    end
  end

  def fetch_illustration_img
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    illustration = Illustration.find_by_uuid params[:uuid]

    if illustration.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    style = "original"

    if Rails.env.production?
      content_type = illustration.image.content_type
      extname = File.extname(illustration.image.to_s)[1..-1].split("?").first
      url = illustration.image.url(style)
      data = open(url)
      send_data data.read, :filename => "#{illustration.name}.#{extname}", :type => content_type , :dispostion=>'inline', :status=>'200 OK', :stream=>'true'
    else
      extname = File.extname(illustration.image.to_s)[1..-1].split("?").first
      send_file "#{Rails.root.to_s}/public/#{Settings.fog.directory}/#{illustration.image.path(style)}", :filename=>"#{illustration.name}.#{extname}", :dispostion=>'inline'
    end
  end

  def fetch_illustration_crop_img
    if params[:uuid].nil? || params[:uuid].empty?
      render json: {error: 'Invalid request'}, status: 406
      return
    end

    illustration_crop = IllustrationCrop.find_by_uuid params[:uuid]

    if illustration_crop.nil?
      render json: {error: 'Record not found'}, status: 404
      return
    end

    if Rails.env.production?
      url = illustration_crop.image.url
      data = open(url)
      send_data data.read, :filename => illustration_crop.image_file_name, :dispostion=>'inline', :status=>'200 OK', :stream=>'true'
    else
      send_file "#{Rails.root.to_s}/public/#{Settings.fog.directory}/#{illustration_crop.image.path}", :filename=> illustration_crop.image_file_name, :dispostion=>'inline'
    end
  end

  private

  def decrease_story_count(access_token)
    token = Token.find_by_access_token(access_token)
    token.story_count = token.story_count - 1
    token.save
  end
end
