class Question < ActiveRecord::Base
  has_one :statement, :dependent => :destroy, :as => :statement_for
  has_one :user, :through => :statement

  def title
    statement.title
  end
end
