module UsersHelper
  def follow_link(user)
    if !user_signed_in? || user.id == current_user.id
      "&nbsp;".html_safe
    elsif current_user.following?(user)
      link_to "Unfollow", unfollow_user_path(@user)
    else
      link_to "Follow", follow_user_path(@user)
    end
  end
end
