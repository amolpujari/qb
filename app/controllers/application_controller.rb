class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  before_filter :authenticate_user!

  def corrected_search_filter
    filter = params[:serach].to_s.strip rescue nil
    return nil unless filter
    filter = "#{filter}*" unless filter.strip.match /.*[\*]$/
    filter = "*#{filter}" unless filter.strip.match /^[\*].*/
    filter
  end

end
