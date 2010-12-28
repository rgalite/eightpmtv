class CommentsController < ApplicationController
  def like
    comment = Comment.find(params[:id])
    like = comment.likes.build(:value => 1, :user => current_user)
    like.save
  end
  
  def unlike
    comment = Comment.find(params[:id])
    comment.likes.where(:user_id => current_user.id, :value => 1).destroy
  end
  
  def dislike
    comment = Comment.find(params[:id])
    like = comment.likes.build(:value => -1, :user => current_user)
    like.save
  end
  
  def undislike
    comment = Comment.find(params[:id])
    comment.likes.where(:user_id => current_user.id, :value => -1).destroy
  end
end
