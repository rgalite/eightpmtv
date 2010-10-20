module ShowsHelper

  def az_shows_initials
    content = ""
    ('A'..'Z').each do |l|
      content << "<li>" + (link_to l, shows_path(:letter => l)) + '</li>'
    end
    
    content.html_safe
  end
end
