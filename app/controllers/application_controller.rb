class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  before_filter :authenticate_user!

  def corrected_search_filter
    return @search_filter if @search_filter
    @search_filter = params[:search].to_s.strip unless params[:search].blank?
    return nil unless @search_filter
    @search_filter = "#{@search_filter}*" unless @search_filter.strip.match /.*[\*]$/
    @search_filter = "*#{@search_filter}" unless @search_filter.strip.match /^[\*].*/
    @search_filter
  end

end
