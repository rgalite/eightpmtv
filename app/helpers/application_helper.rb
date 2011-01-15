module ApplicationHelper
  def truncate(text, length = 30, truncate_string = "...")
    return if text.nil?
    l = length - truncate_string.chars.count
    text.chars.count > length ? text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
  end
  
  def vote_options_attributes(comment)
    if comment.votes.size.zero?
      "style=\"display:none\" class=\"comment-options comment-no-vote\"".html_safe
    else
      "class='comment-options'"
    end 
  end
  
  def likes_buttons(comment, user)
    if user.nil?
      link_to("".html_safe, like_comment_path(comment), :remote => true, :class => "thumbs-up-hov") + ((comment.likes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.likes.size}&nbsp;").html_safe) + link_to("".html_safe, dislike_comment_path(comment), :remote => true, :class => "thumbs-down-hov") + ((comment.dislikes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.dislikes.size}&nbsp;").html_safe)
    elsif user.likes?(comment)
      link_to("".html_safe, unlike_comment_path(comment), :remote => true, :class => "thumbs-up") + ((comment.likes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.likes.size}&nbsp;").html_safe) + link_to("".html_safe, dislike_comment_path(comment), :remote => true, :class => "thumbs-down-hov") + ((comment.dislikes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.dislikes.size}&nbsp;").html_safe)
    elsif user.dislikes?(comment)
      link_to("".html_safe, like_comment_path(comment), :remote => true, :class => "thumbs-up-hov") + ((comment.likes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.likes.size}&nbsp;").html_safe) + link_to("".html_safe, undislike_comment_path(comment), :remote => true, :class => "thumbs-down") + ((comment.dislikes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.dislikes.size}&nbsp;").html_safe)
    else
      link_to("".html_safe, like_comment_path(comment), :remote => true, :class => "thumbs-up-hov") + ((comment.likes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.likes.size}&nbsp;").html_safe) + link_to("".html_safe, dislike_comment_path(comment), :remote => true, :class => "thumbs-down-hov") + ((comment.dislikes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.dislikes.size}&nbsp;").html_safe)
    end
  end
  
  def comment_avatar_url(comment)
    comment.user.nil? ? "/images/user_default_icon_thumb.png" : comment.user.avatar_url(:thumb)
  end
  
  def render_activity(activity)
    render :partial => "shared/activity_#{activity.kind}", :locals => { :activity => activity } 
  end    
  
  def render_activity_title(activity)
    activity_data = JSON.parse(activity.data)
    res = ""
    case activity.kind
    when "comment"
      res = link_to(content_tag(:span, activity.actor_name), activity.actor_path) + " wrote a " + (link_to "comment", activity_data['path']).html_safe + " about " <<
      (link_to activity_data['commented_name'], activity_data['commented_path'])
    when "follow_serie"
      res = link_to(content_tag(:span, activity.actor_name), activity.actor_path) + " started following " + (link_to activity_data['serie_name'], activity_data['serie_path'])
    end
    res + " - " + content_tag(:span, activity.created_at.to_pretty, :style => "font-style:italic")
  end
end
