class Question < ActiveRecord::Base
  attr_accessible :delta
  define_index do
    indexes statement.body, :as => :body
    set_property :delta => true
  end
end
