class RelevelsController < ApplicationController
  before_action :authenticate_user!

  def new
    @rl_story = Story.find_by_id(params[:story_id])
    @story = @rl_story.parent
  end

  def relevel_story
    params[:story]={}
    params[:story][:story_id]=params[:story_id].to_i
    @story = Story.find_by_id(relevel_story_params[:story_id])
    params[:story][:reading_level] = ([0, 1, 2, 3]-[@story.reading_level]).sample
    @rl_story = @story.create_new_derivation_without_pages(relevel_story_params.slice!(:story_id), current_user, current_user, "relevelled")
    @rl_story.status= Story.statuses[:draft]
    unless(@rl_story.valid?)
      flash[:error] = @rl_story.errors.full_messages.join(", ")
      redirect_to :back
    else
      @relevelled_story = @story.relevel(relevel_story_params.slice!(:story_id), current_user, current_user)

      respond_to do |format|
        format.html { redirect_to(story_editor_path(@relevelled_story)) }
        format.js {}
      end
    end
  end

  def update
    @story = Story.find_by_id(params[:id])
    @rl_story = Story.find_by_id(params[:story_id])
    @rl_story.dummy_draft = false
    @rl_story.reading_level = params[:story][:reading_level]
    unless @rl_story.valid?
      return render :new
    else
      @rl_story.save
    end
  end

  private
  def relevel_story_params
    params
      .require(:story)
      .permit(:title, :synopsis, :english_title, :language_id, :status, :reading_level, :story_id, category_ids: [])
  end

end
