class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :registerable

  #devise :registerable if CONFIG[:open_registration]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :confirmed_at
  # attr_accessible :title, :body

  has_many :statements
  has_many :questions, :through => :statements

  concerned_with :allowed_email_domains

  def name
    "#{first_name} #{last_name}"
  end
end
