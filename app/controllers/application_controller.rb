class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  before_filter :init
  before_filter :authenticate_user!

  def init
    @page = params[:page].to_i
    @page = 1 if @page < 1

    @per_page = params[:per_page].to_i
    @per_page = 10 if @per_page < 1
  end

  def corrected_search_filter
    return @search_filter if @search_filter
    @search_filter = params[:search].to_s.strip unless params[:search].blank?
    return nil unless @search_filter
    @search_filter = "#{@search_filter}*" unless @search_filter.strip.match /.*[\*]$/
    @search_filter = "*#{@search_filter}" unless @search_filter.strip.match /^[\*].*/
    @search_filter
  end

end
