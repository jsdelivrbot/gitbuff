class UsersController < ApplicationController
  layout false, :only => [:line]

  def index
    @user = User.new
  end

  def show

    @user = User.find_by(username: params[:username])               # Eğer kullanıcı var ise getirdik
    @git_user = helpers.get_user_info(params[:username])            # Githubdan kullanıcının verilerini getirdik.
                                                                    # Methodlar userhelpers.rb'de tanımlı.

    if @user.nil? && @git_user['login'].present?                    # Kullanıcı veritabanında yok ama githubdan geliyorsa
      @user = User.create(username: @git_user['login'], count: 1)   # bu kullanıcıyı veritabanına ekledik
    elsif @user.present?
      @user.count += 1                                              # Kullanıcı zaten varsa sayacını bir arttırdık
      @user.save!
    end                                                             # Böyle bir kullanıcı hiç yoksa diye view katmanında kontrol yapacağım.
  end

  def most
    @users = User.order(count: :desc).first(10)
  end

  def search
    redirect_to user_show_path(params[:username])
    # Arama formunu get metodu ile show sayfasına bağlayamadığım için araya bir search katmanı koydum.
    # Kullanıcı arama yaptığında user#search çalışıyor. Burdan da user#show 'a yolluyorum.
  end

  def line
    @line_count = helpers.get_line_count(params[:username])         # Satır sayısını hesaplayan yardımcı methodu çağırdım.
  end
end
