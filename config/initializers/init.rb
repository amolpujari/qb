#Attachment Module
require "#{File.dirname(__FILE__)}" + "/../../lib/attachment_module.rb"
ActiveRecord::Base.send(:extend, AttachableBase::ClassMethods)
