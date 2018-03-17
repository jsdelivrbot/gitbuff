class UsersController < ApplicationController
  def index
    @user = User.new
  end

  def show
    @user = User.find_by(username: params[:username])               # Eğer kullanıcı var ise getirdik
    @git_user = get_user_info(params[:username])                    # Githubdan kullanıcının verilerini getirdik.

    if @user.nil? && @git_user['login'].present?                    # Kullanıcı veritabanında yok ama githubdan geliyorsa
      @user = User.create(username: @git_user['login'], count: 1)   # bu kullanıcıyı veritabanına ekledik
    elsif @user.present?
      @user.count += 1                                              # Kullanıcı zaten varsa sayacını bir arttırdık
      @user.save!
    end
  end

  def most
    @users = User.order(count: :desc).first(10)
  end

  def search
    redirect_to user_show_path(params[:username])
    # Arama formunu get metodu ile show sayfasına bağlayamadığım için araya bir search katmanı koydum.
    # Kullanıcı arama yaptığında user#search çalışıyor. Burdan da user#show 'a yolluyorum.
  end

  private

  def get_user_info(username)
    access_token = "8cb02b324d0713ad491bd957c708f274be313719"

    url = 'https://api.github.com'
    cert = File.join(File.dirname(__FILE__), "../../app/assets/certs/cacert.pem")
    # Sertifika hatasını fixlemek için sertifika manuel alınıyor.
    connection = Faraday.new(url, ssl: { ca_file: cert })

    response_user  = connection.get("users/#{ username }?access_token=#{access_token}")
    response_repos = connection.get("users/#{ username }/repos?access_token=#{access_token}")
    # Github apilerinden bilgi almak için gerekli bağlantı kuruldu

    user  = JSON.parse(response_user.body)        # Gelen stringi daha rahat kullanmak için hash'e çevirdik
    repos = { "repos" => JSON.parse(response_repos.body) }

    user.merge! repos         # repoları user değişkeninin içerisine atarak tek bir değişken return ediyoruz.
  end
end
