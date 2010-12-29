module EpisodesHelper
  def aired_on(air_time)
    if air_time.nil?
      return "The air date of this episode is not available ... yet."
    elsif air_time > Date.today
      sentence = "Will be aired on "
    else
      sentence = "Aired on "
    end
    (sentence + (l air_time.to_date, :format => :dmy_with_long_month)).html_safe
  end
end
