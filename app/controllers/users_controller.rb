class UsersController < ApplicationController
  layout false, :only => [:line]
  def index
    @user = User.new
  end

  def line
    @git_user = get_user_info(params[:username])
    @line_count = get_line_count(params[:username], @git_user["repos"])
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
    repos = JSON.parse(response_repos.body)


    stars = sum_star(repos)
    fav_lang = fav_lang(repos)

    repos     = { "repos" => repos }                          # user değişkeni ile birleştirmek için hash haline getiriyoruz.
    fav_lang  = { "fav_lang" => fav_lang }
    stars     = { "stars" => stars }

    user.merge! repos         # repoları user değişkeninin içerisine atarak tek bir değişken return ediyoruz.
    user.merge! fav_lang
    user.merge! stars
  end

  def spaces_on number
    number.to_s.gsub(/\D/, '').reverse.gsub(/.{3}/, '\0.').reverse
  end
  # Bu metod Büyük bir sayıyı daha rahat okunabilmesi için 3 rakam 3 rakam ayırıyor.
  # Bu methodu https://stackoverflow.com/questions/9166553/formatting-a-number-to-split-at-every-third-digit
  # adresinden aldım.

  def sum_star repos
    sum = 0                           # Bu metod toplam yıldız sayısını buluyor.
    repos.each do |repo|
      sum += repo["stargazers_count"]
    end
    sum
  end

  def fav_lang repos
    langs = []
    repos.each do |repo|
      langs << repo['language'] unless repo['language'].nil?    # deponun dili varsa diziye ekliyorum.
    end

    langs.max_by{ |lang| langs.count(lang) }     # En çok tekrar eden dili return ediyorum.
  end

  def get_line_count(username, repos)
    access_token = "8cb02b324d0713ad491bd957c708f274be313719"
    cert = File.join(File.dirname(__FILE__), "../../app/assets/certs/cacert.pem")
    connection = Faraday.new('https://api.github.com', ssl: { ca_file: cert })

    line_sum = 0

    repos.each do |repo|
      langs = connection.get("repos/#{ username }/#{ repo['name'] }/languages?access_token=#{access_token}")
      langs = JSON.parse(langs.body)      # Bu iki satırda hangi dillerle kaç satır yazıldığının bilgisi geliyor.
      line_sum += langs.values.sum        # gelen veriler önce birbiriyle, sonra da diğer depoların satır sayıları ile toplanıyor.
    end
    spaces_on(line_sum)                   # Yukarıda tanımlı line_sum methodu ile sayı daha okunaklı yapıldı.
  end
end
