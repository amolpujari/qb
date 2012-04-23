class Statement < ActiveRecord::Base
  attr_accessible :title, :body
  can_have_attachments :max => 5
end
