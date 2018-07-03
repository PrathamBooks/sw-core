class TranslationsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_languages
  def new
    if params[:contest_id].present?
      @contest_id = params[:contest_id]
    end
    @tr_story = Story.find_by_id(params[:story_id])
    @story = @tr_story.parent
    render_404 if @story.nil?
  end

  def translate_story
    params[:story]={}
    params[:story][:story_id] = params[:story_id]
    @story = Story.find_by_id(translate_story_params[:story_id])
    if params[:to_language].present?
      params[:story][:language_id] = params[:to_language]
    else
      english_language = Language.find_by_name("English").id
      language_id = english_language != @story.language.id ? english_language : Language.where.not(:id => @story.language.id).first.id
      params[:story][:language_id] = language_id
    end
    @tr_story = @story.create_new_derivation_without_pages(translate_story_params.slice!(:story_id), current_user, current_user, "translated")
    @tr_story.status= Story.statuses[:draft]
    @tr_story.dummy_draft = false if params[:to_language].present?
    unless(@tr_story.valid?)
      flash[:error] = @tr_story.errors.full_messages.join(", ")
      redirect_to :back
    else
      @tanslated_story = @story.translate(translate_story_params.slice!(:story_id), current_user, current_user)
      #if it is translation contest 
      @tanslated_story.update_attributes(contest_id: params[:story][:contest_id]) if params[:story][:contest_id].present?

      respond_to do |format|
        format.html { redirect_to(story_editor_path(@tanslated_story)) }
        format.js {}
      end
    end
  end

  def update
    @story = Story.find_by_id(params[:id])
    @tr_story = Story.find_by_id(params[:story_id])
    language = Language.find_by_id(params[:story][:language_id])
    @tr_story.language = language
    @tr_story.dummy_draft = false
    unless @tr_story.valid?
      return render :new
    else
     @tr_story.save
    end
  end

  private
  def translate_story_params
    params
      .require(:story)
      .permit(:language_id, :story_id)
  end

  def get_languages
    @languages= Language.all
  end

end
