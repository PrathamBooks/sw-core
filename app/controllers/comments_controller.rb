class CommentsController < ApplicationController

  def create
    @blog_post = BlogPost.find(params[:blog_post_id])
    @comment = Comment.new(comment_params)
    @comment.blog_post = @blog_post
    if current_user
    @comment.user = current_user
    @comment.save
    else
      flash[:notice] = "Please login before making comments"
      flash.keep(:notice)
      render :js => "window.location = '#{blog_post_path(@blog_post)}'"
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :user_id, :blog_post_id)
  end
end
