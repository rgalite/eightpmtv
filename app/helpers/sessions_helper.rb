module SessionsHelper
  def you_helper(name)
    name == current_user.name ? "you" : name
  end
  
  def your_helper(name)
    name == current_user.name ? "your" : name + "'s"
  end
  
  def calendar_day(day)
    if day == Date.today
      "Today"
    elsif day == Date.today + 1.days
      "Tomorrow"
    else
      l day, :format => :day_number
    end
  end
end
