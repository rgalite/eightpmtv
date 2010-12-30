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
end
