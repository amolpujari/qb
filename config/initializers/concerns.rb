class << ActiveRecord::Base
  def concerned_with(*concerns)
    concerns.each do |concern|
      require_dependency "#{name.underscore}/#{concern}"
      klass = concern.to_s.classify.constantize rescue nil
      send(:include, klass) if klass.is_a? Module
    end
  end
end