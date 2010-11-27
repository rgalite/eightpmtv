module ApplicationHelper
  def truncate(text, length = 30, truncate_string = "...")
    return if text.nil?
    l = length - truncate_string.chars.count
    text.chars.count > length ? text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
  end
end
