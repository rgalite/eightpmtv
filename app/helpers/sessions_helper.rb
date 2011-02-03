module SessionsHelper
  def you_helper(name)
    name == current_user.name ? "you" : name
  end
  
  def your_helper(name)
    name == current_user.name ? "your" : name + "'s"
  end
end
