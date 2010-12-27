class ApplicationSetting < ActiveRecord::Base
  @@instance = self.first

  def self.instance
    @@instance
  end

  def self.method_missing(method, *args)
    option = method.to_s
    if option.include? '='
        var_name = option.gsub('=', '')
        value = args.first
        @@instance[var_name] = value
      else
        @@instance[option]
    end
  end
end
