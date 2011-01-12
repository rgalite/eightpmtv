class String
  COLORS = { "green" => "e[32m", "red" => "e[31m" }
  def to_color(color)
    COLORS[color] + self + "[0m" if COLORS.keys.include?(color)
  end
end