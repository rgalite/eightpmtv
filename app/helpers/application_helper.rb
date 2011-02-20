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
      res = ""
      res << content_tag(:span, "", :class => "thumbs-up-normal") + "&nbsp;#{comment.likes.size}&nbsp;".html_safe unless comment.likes.size.zero?
      res << content_tag(:span, "", :class => "thumbs-down-normal") + "&nbsp;#{comment.dislikes.size}&nbsp;".html_safe unless comment.dislikes.size.zero?
      res.html_safe
    elsif user.likes?(comment)
      link_to("".html_safe, unlike_comment_path(comment), :remote => true, :class => "thumbs-up", :title => "You voted up")<<
      (comment.likes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.likes.size}&nbsp;").html_safe<<
      link_to("".html_safe, dislike_comment_path(comment), :remote => true, :class => "thumbs-down-hov")<<
      (comment.dislikes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.dislikes.size}&nbsp;").html_safe
    elsif user.dislikes?(comment)
      link_to("".html_safe, like_comment_path(comment), :remote => true, :class => "thumbs-up-hov")<<
      (comment.likes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.likes.size}&nbsp;").html_safe<<
      link_to("".html_safe, undislike_comment_path(comment), :remote => true, :class => "thumbs-down", :title => "You voted down")<<
      (comment.dislikes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.dislikes.size}&nbsp;").html_safe
    else
      link_to("".html_safe, like_comment_path(comment), :remote => true, :class => "thumbs-up-hov")<<
      (comment.likes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.likes.size}&nbsp;").html_safe<<
      link_to("".html_safe, dislike_comment_path(comment), :remote => true, :class => "thumbs-down-hov")<<
      (comment.dislikes.size.zero? ? "&nbsp;&nbsp;&nbsp;" : "&nbsp;#{comment.dislikes.size}&nbsp;").html_safe
    end
  end
  
  def comment_avatar_url(comment)
    comment.user.nil? ? "/images/user_default_icon_thumb.png" : comment.user.avatar_url(:thumb)
  end   
  
  def render_activity_title(activity)
    activity_data = JSON.parse(activity.data)
    res = ""
    case activity.kind
    when "comment"
      res = link_to(content_tag(:span, activity.actor_name), activity.actor_path) + " wrote a " + (link_to "comment", activity.subject_path).html_safe + " about " <<
      (link_to activity_data['commented_name'], activity_data['commented_path'])
    when "follow_serie"
      res = link_to(content_tag(:span, activity.actor_name), activity.actor_path) + " started following " + (link_to activity_data['serie_name'], activity_data['serie_path'])
    when "new_episode_available"
      res = link_to(content_tag(:span, activity.subject.full_name), activity.subject_path) + " is now available."
    when "new_episode_scheduled"
      res = link_to(content_tag(:span, activity.subject.full_name), JSON.parse(activity.data)["episode_path"]) + " is scheduled."
    when "follow_user"
      res = link_to(content_tag(:span, activity.actor_name), user_path(activity.actor)) + " is now following " + link_to(content_tag(:span, activity_data["user_name"]), activity_data["user_path"])
    when "likes_comment"
      res = link_to(content_tag(:span, activity.actor_name), activity.actor_path) + " likes " + link_to(activity_data["comment_author_name"], activity_data["comment_autor_path"]) + "'s " + link_to('comment', activity_data["comment_path"]) + " about " + link_to(activity_data['commented_name'], activity_data['commented_path'])
    end
    res + " - " + content_tag(:span, activity.created_at.to_pretty, :style => "font-style:italic")
  end
  
  def sanitized_object_name(object_name)
    object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/,"_").sub(/_$/,"")
  end

  def sanitized_method_name(method_name)
    method_name.sub(/\?$/, "")
  end

  def form_tag_id(object_name, method_name)
    "#{sanitized_object_name(object_name.to_s)}_#{sanitized_method_name(method_name.to_s)}"
  end
  
  def facebook_like_button
    content_tag(:div, '<iframe src="http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.eightpm.tv%2Fshows%2Fdesperate-housewives%2F7%2F15&amp;layout=box_count&amp;show_faces=true&amp;width=450&amp;action=like&amp;font=tahoma&amp;colorscheme=light&amp;height=65" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:65px;" allowTransparency="true"></iframe>')
  end
end
