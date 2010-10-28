class Series < ActiveRecord::Base
  def to_param
    return "#{self.id}-#{self.name.parameterize}"
  end
end
