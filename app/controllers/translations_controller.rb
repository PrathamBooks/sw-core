class TranslationsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_languages
  def new
    if params[:contest_id].present?
      @contest_id = params[:contest_id]
    end
    @tr_story = Story.find_by_id(params[:story_id])
    @story = @tr_story.parent
    @auto_translated_draft = @story.get_auto_translated_drafts(@tr_story.language.id)
    
    if @story.can_auto_translate? && @auto_translated_draft.present?
      @translated_draft = @auto_translated_draft.first
    end
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
    @translated_draft = nil
    if params[:to_language].present?
      language = Language.find_by_name(params[:to_language])
      @tr_story.language = language
    end
    unless(@tr_story.valid?)
      flash[:error] = @tr_story.errors.full_messages.join(", ")
      redirect_to(react_stories_show_path(@story))
    else
      @tanslated_story = @story.translate(translate_story_params.slice!(:story_id), current_user, current_user)
      #if it is translation contest 
      @tanslated_story.update_attributes(contest_id: params[:story][:contest_id]) if params[:story][:contest_id].present?
      if params[:to_language].present?
        language = Language.find_by_name(params[:to_language])
        @auto_translated_draft = @story.get_auto_translated_drafts(language.id)
        
        if @story.can_auto_translate? && @auto_translated_draft.present?
          @translated_draft = @auto_translated_draft.first
          @tanslated_story.update_attributes(language_id: language.id, dummy_draft: true)
        else
          @tanslated_story.update_attributes(language_id: language.id, dummy_draft: false)
        end
      end

      if(params[:translator_story].present? && params[:to_language].present? && current_user.is_translator?)
        @tanslated_story.update!(:organization => current_user.organization)
        TranslatorStory.find_by(:translate_language_id => Language.find_by_name(params[:to_language]).id, :translator_id => current_user.id, :story_id => params[:story_id]).update(:translator_story_id => @tanslated_story.id)
      end


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

    @auto_translated_draft = @story.get_auto_translated_drafts(language.id )

    if @story.can_auto_translate? && @auto_translated_draft.present?
      @translated_draft = @auto_translated_draft.first
    end

    @tr_story.language = language
    @tr_story.dummy_draft = false
    
    unless @tr_story.valid?
      return render :new
    else
     @tr_story.save
    end
  end

  def update_auto_translation
    @story = Story.find_by_id(params[:id])
    @auto_translated_draft = Story.find_by_id(params[:auto_translated_draft_id])
    render_404 if @story.nil? || @auto_translated_draft.nil?
    @story.pages.each do |page|
      page.content = @auto_translated_draft.pages.where(position: page.position).first.try(:content)
      page.save!
    end
    @story.update_attribute(:dummy_draft, false)
    @story.update_attribute(:is_autoTranslate, true)

    respond_to do |format|
      format.html { redirect_to(story_editor_path(@story)) }
      format.js {}
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
