class CommentsController < ApplicationController
  before_filter :authenticate_user!
  private
  def respond_to_like
    respond_to do |format|
      format.js { render "like" }
    end
  end
  
  def delete_likes(comment)
    comment.votes.where(:user_id => current_user.id).destroy_all
  end
  
  public
  def like
    @comment = Comment.find(params[:id])
    delete_likes(@comment)
    @like = @comment.votes.build(:value => 1, :user => current_user)

    if @like.save
      if @comment.user != current_user
        comment_activity = Activity.where(["subject_type = ? AND subject_id = ? and kind = ?", 'Comment', @comment.id, 'comment']).first
        if !comment_activity.nil?
          comment_activity_data = JSON.parse(comment_activity.data)
          current_user.activities.create!(:kind => "likes_comment",
                                          :actor => current_user,
                                          :actor_img => current_user.avatar_url(:thumb),
                                          :actor_path => user_path(current_user),
                                          :subject => @like,
                                          :data => { :commented_name => @comment.commentable.full_name,
                                                     :commented_path => comment_activity_data["commented_path"],
                                                     :comment_path => comment_activity.subject_path,
                                                     :comment_content => @comment.content,
                                                     :comment_author_name => @comment.user.full_name,
                                                     :comment_autor_path => user_path(@comment.user),
                                                     :comment_author_img => @comment.user.avatar_url(:thumb) }.to_json)
        end
      end
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
