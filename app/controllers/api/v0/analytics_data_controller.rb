class Api::V0::AnalyticsDataController < Api::V0::ApplicationController

  before_action :authenticate_tracker_request

  READ_EVENT = "read"
  DOWNLOAD_EVENT = "download"
  STORY_ENTITY = "story"
  ILLUSTRATION_ENTITY = "illustration"
  SW_PREFIX = "SW-"

  swagger_controller :analytics_data, 'Analytics Data'

  swagger_api :get_story_read_count do
    summary "Get read count for all stories of queried organization"
    param :query, :token, :string, :required, "Access Token"
    param :query, :org_prefix, :string, :required, "Organization Prefix"
  end

  swagger_api :get_story_download_count do
    summary "Get download count for each type (high res PDF, low res PDF, ePUB) for all stories of queried organization"
    param :query, :token, :string, :required, "Access Token"
    param :query, :org_prefix, :string, :required, "Organization Prefix" 
  end 

  swagger_api :get_illustration_view_count do
    summary "Get read count for all illustrations of queried organization"
    param :query, :token, :string, :required, "Access Token"
    param :query, :org_prefix, :string, :required, "Organization Prefix"
  end

  swagger_api :get_illustration_download_count do
    summary "Get download count for all illustrations of queried organization"
    param :query, :token, :string, :required, "Access Token"
    param :query, :org_prefix, :string, :required, "Organization Prefix"
  end

  swagger_api :get_illustration_reuse_count do
    summary "Get count of illustrations of queried organization that are being used in stories created by client"
    param :query, :token, :string, :required, "Access Token"
    param :query, :org_prefix, :string, :required, "Organization Prefix"
  end

  swagger_api :get_translated_stories do
    summary "Get all translated stories that dont belong to queried organization but are derived from story belonging to queried organization"
    param :query, :token, :string, :required, "Access Token"
    param :query, :org_prefix, :string, :required, "Organization Prefix"
  end

  swagger_api :get_relevelled_stories do
    summary "Get all relevelled stories that dont belong to queried organization but are derived from story belonging to queried organization"
    param :query, :token, :string, :required, "Access Token"
    param :query, :org_prefix, :string, :required, "Organization Prefix"
  end

  def authenticate_tracker_request
    if params["token"].nil? || params["token"].empty?
      render json: {error: 'No token present'}, status: :unauthorized
      return
    end

    token = Token.find_by_access_token params["token"]

    if token.nil?
      render json: {error: 'Incorrect token'}, status: :unauthorized
      return
    end

    if !(Time.now < token.expires_at)
      render json: {error: 'Invalid token'}, status: :unauthorized
      return
    end   
  end

  def get_story_read_count
    if params["org_prefix"].nil? || params["org_prefix"].empty?
      render json: {error: 'Organization prefix not present'}, status: :unauthorized
      return
    end

    stories = Story.where("uuid LIKE :prefix", prefix: "#{params["org_prefix"]}%")

    story_read_map = {}

    stories.each {|s| story_read_map[s.uuid] = s.reads}

    render json: story_read_map.to_json, status: 200
  end

  def get_story_download_count
    if params["org_prefix"].nil? || params["org_prefix"].empty?
      render json: {error: 'Organization prefix not present'}, status: :unauthorized
      return
    end

    stories = Story.where("uuid LIKE :prefix", prefix: "#{params["org_prefix"]}%")

    story_download_map = {}

    stories.each do |s| 
      story_download_map[s.uuid] = {
        :low_res_pdf => s.downloads, :high_res_pdf => s.high_resolution_downloads, :epub => s.epub_downloads
      }
    end

    render json: story_download_map.to_json, status: 200
  end

  def get_illustration_view_count
    if params["org_prefix"].nil? || params["org_prefix"].empty?
      render json: {error: 'Organization prefix not present'}, status: :unauthorized
      return
    end

    illustrations = Illustration.where("uuid LIKE :prefix", prefix: "#{params["org_prefix"]}%")

    illustration_read_map = {}

    illustrations.each {|i| illustration_read_map[i.uuid] = i.reads}

    render json: illustration_read_map.to_json, status: 200
  end

  def get_illustration_download_count
    if params["org_prefix"].nil? || params["org_prefix"].empty?
      render json: {error: 'Organization prefix not present'}, status: :unauthorized
      return
    end

    illustrations = Illustration.where("uuid LIKE :prefix", prefix: "#{params["org_prefix"]}%")

    illustration_download_map = {}
    id_uuid_map = {}

    illustrations.each do |illustration|
      illustration_download_map[illustration.uuid] = 0
      id_uuid_map[illustration.id] = illustration.uuid
    end

    illustration_downloads = IllustrationDownload.all

    illustration_downloads.each do |illustration_download|
      uuid = id_uuid_map[illustration_download.illustration_id]
      if uuid != nil
        illustration_download_map[uuid] = illustration_download_map[uuid] + 1
      end
    end

    render json: illustration_download_map.to_json, status: 200
  end

  def get_illustration_reuse_count
    if params["org_prefix"].nil? || params["org_prefix"].empty?
      render json: {error: 'Organization prefix not present'}, status: :unauthorized
      return
    end

    stories = Story.where("uuid LIKE :prefix", prefix: "#{Settings.org_info.prefix}-%")

    filtered_uuids = []
    stories.each do |s|
      story_illustration_uuids = s.illustrations.map(&:uuid)
      story_illustration_uuids.each do |uuid|
        filtered_uuids << uuid if uuid.start_with? params["org_prefix"]
      end
    end

    illustration_reuse_count = filtered_uuids.uniq.count
    
    render json: {count: illustration_reuse_count}, status: 200
  end

  def get_translated_stories
    if params["org_prefix"].nil? || params["org_prefix"].empty?
      render json: {error: 'Organization prefix not present'}, status: :unauthorized
      return
    end

    stories = Story.where(:status => 1).where(:derivation_type => "translated").where.not("uuid LIKE :prefix", prefix: "#{params["org_prefix"]}%")

    translated_stories_data = {}

    stories.each do |story|
      original_uuid = story.root.uuid
      if original_uuid.start_with? params["org_prefix"]
        translated_stories_data[story.uuid] = {
          "language"  => story.language.name,
          "ancestry"  => {
            "original_story_uuid" => original_uuid,
            "derived_story_uuid"  => story.parent.uuid
          }
        }
      end
    end

    render json: translated_stories_data, status: 200    
  end

  def get_relevelled_stories
    stories = Story.where(:status => 1).where(:derivation_type => "relevelled").where.not("uuid LIKE :prefix", prefix: "#{params["org_prefix"]}%")

    relevelled_stories_data = {}

    stories.each do |story|
      original_uuid = story.root.uuid
      if original_uuid.start_with? params["org_prefix"]
        relevelled_stories_data[story.uuid] = {
          "language"  => story.language.name,
          "ancestry"  => {
            "original_story_uuid" => original_uuid,
            "derived_story_uuid"  => story.parent.uuid
          }
        }
      end
    end

    render json: relevelled_stories_data, status: 200    
  end

  
  ###################### TRACKER PUSH API ##########################
  # TODO: DB structure is changed now. So we need to change the code.
  def track_event
    if params["operation"].nil? || params["entity"].nil? || params["org_id"].nil? || params["uuid"].nil?
      render json: {error: 'All required parameters not present'}, status: 406
      return
    end

    if params["operation"] == READ_EVENT
      if params["entity"] == STORY_ENTITY
        story = Story.find_by_uuid params["uuid"]
        story.partner_reads[params["org_id"]] = story.partner_reads[params["org_id"]] + 1
        story.partner_reads_will_change!
        if story.save
          render json: {ok: true}, status: 200
        else
          render json: {ok: false}, status: 500
        end
      elsif params["entity"] == ILLUSTRATION_ENTITY
        illustration = Illustration.find_by_uuid params["uuid"]
        illustration.partner_reads[params["org_id"]] = illustration.partner_reads[params["org_id"]] + 1
        illustration.partner_reads_will_change!
        if illustration.save
          render json: {ok: true}, status: 200
        else
          render json: {ok: false}, status: 500
        end
      end
    elsif params["operation"] == DOWNLOAD_EVENT
      if params["entity"] == STORY_ENTITY
        story = Story.find_by_uuid params["uuid"]
        story.partner_downloads[params["org_id"]] = story.partner_downloads[params["org_id"]] + 1
        story.partner_downloads_will_change!
        if story.save
          render json: {ok: true}, status: 200
        else
          render json: {ok: false}, status: 500
        end
      elsif params["entity"] == ILLUSTRATION_ENTITY
        illustration = Illustration.find_by_uuid params["uuid"]
        illustration.partner_downloads[params["org_id"]] = illustration.partner_downloads[params["org_id"]] + 1
        illustration.partner_downloads_will_change!
        if illustration.save
          render json: {ok: true}, status: 200
        else
          render json: {ok: false}, status: 500
        end
      end
    end
  end

end
