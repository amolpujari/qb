class Attachment < ActiveRecord::Base
  attr_accessible :upload

  belongs_to :attachable, :polymorphic=>true
  has_attached_file :upload, :styles => { :thumb => "100x100>" }
  before_post_process :image?

  validates_attachment_size :upload, :greater_than => 0.kilobytes, :less_than => 5.megabytes
#  validates_attachment_content_type :upload, :content_type => [
#    'image/jpeg', 'image/png', 'image/gif',
#    'application/pdf',
#    'application/msword',
#    '*',
#    'text/plain',
#    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
#    'application/vnd.ms-powerpoint',
#    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
#    'application/vnd.openxmlformats-officedocument.presentationml.slideshow'
#  ]

  def image?
    upload_content_type.include?('image')
  end
end
