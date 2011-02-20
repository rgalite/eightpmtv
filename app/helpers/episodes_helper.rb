module EpisodesHelper
  def aired_on(air_day, air_time)
    if air_day.nil?
      return "The air date of this episode is not available ... yet."
    elsif air_day > Date.today
      sentence = "Will be aired on "
    elsif air_day == Date.today
      return sentence = "Airing today at #{air_time}"
    else
      sentence = "Aired on "
    end
    (sentence + (l air_day.to_date, :format => :dmy_with_long_month)).html_safe
  end
end
