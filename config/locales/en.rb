{
  :en => {
    :date => {
      :formats => {
        :dmy_with_long_month => lambda { |date, options| "%B #{date.day.ordinalize}, %Y" },
        :day => lambda { |date, options| "%A" }
      }
    }
  }
}