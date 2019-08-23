class UsersController < ApplicationController
  before_action :logged_in_user, except: [:new, :show, :create]
  before_action :load_user, except: [:index, :new, :create]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page], per_page: Settings.page
  end

  def show
    @microposts = @user.microposts.paginate(page: params[:page],
      per_page: Settings.page)
    return if @user.activated?
    flash[:danger] = t ".flash_danger"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".flash_info"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = t ".flash_success_u"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".flash_success_d"
    else
      flash[:danger] = t ".flash_danger_d"
    end
    redirect_to users_url
  end

  def following
    @title = t "controller.users.title_following"
    @users = @user.following.paginate page: params[:page],
      per_page: Settings.following_per_page
    render :show_follow
  end

  def followers
    @title = t "controller.users.title_followers"
    @users = @user.followers.paginate page: params[:page],
      per_page: Settings.following_per_page
    render :show_follow
  end

  private

  def user_params
    params.require(:user).permit :name, :email,
      :password, :password_confirmation
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t ".flash_danger_lg"
    redirect_to login_url
  end

  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t ".flash_danger"
    redirect_to root_path
  end
end
