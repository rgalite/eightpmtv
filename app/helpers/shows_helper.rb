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
    people_watching = serie.watchers
    
    if people_watching.size.zero?
      desc = "Nobody is watching this TV show"
    elsif user_signed_in?
      watchers = []
    
      # Put the current user in the watchers list if he watches the serie
      if people_watching.include?(current_user) 
        watchers << "You"
        people_watching = people_watching - [current_user]
      end
      
      friends_watching = current_user.friends_watching(serie)
      
      # Do not display more than 3 friends in the description
      if friends_watching.size > 3
        # If there are more than 3 friends put a number of friends !
        watchers << "#{friends_watching} of your friends"
      else
        # Otherwise, lists the friends
        friends_watching.each { |f| watchers << f.username ; people_watching.delete(f) } unless friends_watching.size.zero?
      end

      # Remove friends from anonymous people
      people_watching = people_watching - friends_watching
      
      # Finally, put the rest of the watchers (anonymous)
      if watchers.size.zero?
        watchers << "#{pluralize(people_watching.size, 'person', 'people')}"
      else
        watchers << "#{pluralize(people_watching.size, 'other person', 'other people')}" unless people_watching.size.zero?
      end
      desc = "#{watchers.to_sentence} are watching this show"
    else
      desc = "#{pluralize(people_watching.size, 'person is', 'people are')} watching this TV show"
    end
    desc
  end
end
