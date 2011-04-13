{
  :en => {
    :date => {
      :formats => {
        :dmy_with_long_month => lambda { |date, options| "%B #{date.day.ordinalize}, %Y" },
        :day => lambda { |date, options| "%A" },
        :day_number => lambda { |date, options| "%A %d" }
      }
    },
    :time => {
      :formats => {
        :dmy_with_long_month => lambda { |date, options| "%B #{date.day.ordinalize}, %Y at %I:%M %p" },
      }
    }
  }
}