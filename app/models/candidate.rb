class Candidate < ActiveRecord::Base
  attr_accessible :email
  has_many :test_papers

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email, :allow_nil => false;

  def self.find_or_create_by_email email
    where(:email => email).first or Candidate.create :email => email
  end
end
