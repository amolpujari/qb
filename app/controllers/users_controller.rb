class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find_by_id params[:id]
  end

end
