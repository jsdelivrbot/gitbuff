class UsersController < ApplicationController
  layout false, :only => [:line]

  def index
    @user = User.new
  end

  def show

    @user = User.find_by(username: params[:username].downcase)               # Eğer kullanıcı var ise getirdik
    @git_user = helpers.get_user_info(params[:username])            # Githubdan kullanıcının verilerini getirdik.


    redirect_to(query_error_path) and return if @git_user.include? 'message'

    if @user.nil? && @git_user.present?                    # Kullanıcı veritabanında yok ama githubdan geliyorsa
      @user = User.create(username: @git_user['login'].downcase, image_url: @git_user['avatar_url'], count: 1)
    elsif @user.present?                                            # ^^^^ bu kullanıcıyı veritabanına ekledik.
      @user.count += 1
      @user.save!                                                   # Kullanıcı zaten varsa sayacını bir arttırdık
    end                                                             # Böyle bir kullanıcı hiç yoksa diye view katmanında kontrol yapacağım.
  end

  def most
    @users = User.paginate(:page => params[:page], :per_page => 5).order(count: :DESC)
  end

  def search
    redirect_to user_show_path(params[:username])
    # Arama formunu get metodu ile show sayfasına bağlayamadığım için araya bir search katmanı koydum.
    # Kullanıcı arama yaptığında user#search çalışıyor. Burdan da user#show 'a yolluyorum.
  end

  def line
    @line_count = helpers.get_line_count(params[:username])         # Satır sayısını hesaplayan yardımcı methodu çağırdım.
  end

  def error
    headers = helpers.remaining_time
    @remaining_time = Time.at headers['x-ratelimit-reset'].to_i
    @remaining_time = @remaining_time.strftime("%H:%M")
  end
end
