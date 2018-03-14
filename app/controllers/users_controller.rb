class UsersController < ApplicationController
  def index
    @user = User.new
  end

  def show
    @user = get_user(params[:username])
  end

  def most
  end

  def search
    redirect_to( user_show_path(params[:username]) )
    # Arama formunu get metodu ile show sayfasına bağlayamadığım için araya bir search katmanı koydum.
    # Kullanıcı arama yaptığında user#search çalışıyor. Burdan da user#show 'a yolluyorum.
  end

  private

  def get_user(username)
    cert = File.join(File.dirname(__FILE__), "../../app/assets/certs/cacert.pem")
    # Sertifika hatasını fixlemek için sertifika manuel alınıyor.

    url = 'https://api.github.com'

    connection = Faraday.new(url, ssl: { ca_file: cert })
    response = connection.get("users/#{ username }")        # Github apilerinden bilgi almak için gerekli bağlantı kuruldu

    user = JSON.parse(response.body)                        # Gelen stringi daha rahat kullanmak için hash'e çevirdik
  end
end
