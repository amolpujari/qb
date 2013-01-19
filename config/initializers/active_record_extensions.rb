module ActiveRecordExtensions
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find_by_id id
      where(' id = ? ', id.to_s).first
    end
  end
  
  # instance methods below
end

ActiveRecord::Base.send(:include, ActiveRecordExtensions)

