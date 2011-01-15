module HasPoster
  def poster_url_small
    poster.url(:small)
  end
  
  def poster_url_medium
    poster.url(:medium)
  end
  
  def poster_url_thumb
    poster.url(:thumb)
  end
  
  def poster_url_original
    poster.url(:original)
  end
end