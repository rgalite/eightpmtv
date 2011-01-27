module ShowsHelper

  def az_shows_initials(current_letter)
    content = ""
    ('A'..'Z').each do |l|
      content << "<li"
      content << " class=\"selected\"" if current_letter == l
      content << ">" + (link_to l, name_shows_path(:letter => l)) + '</li>'
    end
    
    content.html_safe
  end
  
  def people_watching(serie)
    people_watching = serie.watchers.all
    
    if people_watching.size.zero?
      desc = "Nobody is watching this TV show"
    elsif user_signed_in?
      watchers = []
    
      # Put the current user in the watchers list if he watches the serie
      if people_watching.include?(current_user) 
        watchers << "You"
        people_watching = people_watching - [current_user]
      end
      
      followings_watching = current_user.followings_watching(serie)
      
      # Do not display more than 3 friends in the description
      if followings_watching.size > 3
        # If there are more than 3 friends put a number of friends !
        watchers << "#{followings_watching} of your friends"
      else
        # Otherwise, lists the friends
        followings_watching.each { |f| watchers << link_to(f.username, user_path(f)) ; people_watching.delete(f) } unless followings_watching.size.zero?
      end

      # Remove friends from anonymous people
      people_watching = people_watching - followings_watching
      
      # Finally, put the rest of the watchers (anonymous)
      if watchers.size.zero?
        watchers << "#{pluralize(people_watching.size, 'person is', 'people are')}"
        desc = "#{watchers.to_sentence} watching this show"
      else
        watchers << "#{pluralize(people_watching.size, 'other person', 'other people')}" unless people_watching.size.zero?
        desc = "#{watchers.to_sentence} " + (serie.watchers.size == 1 && serie.watchers.first != current_user ? "is" : "are") + " watching this show"
      end
    else
      desc = "#{pluralize(people_watching.size, 'person is', 'people are')} watching this TV show"
    end
    desc.html_safe
  end
  
  def people_watching_except_you(serie)
    people_watching = serie.watchers.all.reject{|u| u.id == current_user.id}
    if people_watching.size.zero?
      desc = "Nobody else is watching this TV show"
    elsif user_signed_in?
      watchers = []
    
      # Put the current user in the watchers list if he watches the serie
      if people_watching.include?(current_user) 
        watchers << "You"
        people_watching = people_watching - [current_user]
      end
      
      followings_watching = current_user.followings_watching(serie)
      
      # Do not display more than 3 friends in the description
      if followings_watching.size > 3
        # If there are more than 3 friends put a number of friends !
        watchers << "#{followings_watching} of your friends"
      else
        # Otherwise, lists the friends
        followings_watching.each { |f| watchers << link_to(f.username, user_path(f)) ; people_watching.delete(f) } unless followings_watching.size.zero?
      end

      # Remove friends from anonymous people
      people_watching = people_watching - followings_watching
      
      # Finally, put the rest of the watchers (anonymous)
      if watchers.size.zero?
        watchers << "#{pluralize(people_watching.size, 'person is', 'people are')}"
        desc = "#{watchers.to_sentence} watching this show"
      else
        watchers << "#{pluralize(people_watching.size, 'other person', 'other people')}" unless people_watching.size.zero?
        desc = "#{watchers.to_sentence} " + (serie.watchers.size == 1 && serie.watchers.first != current_user ? "is" : "are") + " watching this show"
      end
    else
      desc = "#{pluralize(people_watching.size, 'person is', 'people are')} watching this TV show"
    end
    desc.html_safe
  end
  
  def watch_button(series)
    if user_signed_in?
      if current_user.watch?(series)
        link_to "Unfollow", unfollow_show_path(series), :remote => true, :class => "rm-movie-icon"
      else
        link_to "Follow", follow_show_path(series), :remote => true, :class => "add-movie-icon"
      end
    else
      "&nbsp;".html_safe
    end
  end
end
