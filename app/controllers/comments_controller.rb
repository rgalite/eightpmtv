class CommentsController < ApplicationController
  before_filter :authenticate_user!
  private
  def respond_to_like
    respond_to do |format|
      format.js { render "like" }
    end
  end
  
  def delete_likes(comment)
    comment.votes.where(:user_id => current_user.id).delete_all
  end
  
  public
  def like
    @comment = Comment.find(params[:id])
    delete_likes(@comment)
    @like = @comment.votes.build(:value => 1, :user => current_user)

    if @like.save
      Activty.create!(:kind => "likes_comment",
                      :actor => current_user, :actor_img => current_user.avatar_url(:thumb),
                      :subject => @like,
                      :data => { :comment_content => @comment.content,
                                 :comment_author_name => @comment.user.full_name,
                                 :comment_author_img => @comment.user.avatar_url(:thumb) })
      respond_to_like
    else
      render :text => @like.errors.full_messages.to_s
    end
  end
  
  def unlike
    @comment = Comment.find(params[:id])
    delete_likes(@comment)
    
    respond_to_like
  end
  
  def dislike
    @comment = Comment.find(params[:id])
    delete_likes(@comment)
    @like = @comment.votes.build(:value => -1, :user => current_user)
    
    if @like.save
      respond_to_like
    else
      render :text => @like.errors.full_messages.to_s
    end
  end
  
  def undislike
    @comment = Comment.find(params[:id])
    delete_likes(@comment)
    
    respond_to_like
  end
end
