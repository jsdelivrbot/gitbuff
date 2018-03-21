module UsersHelper
  def get_user_info(username)
    access_token = "8cb02b324d0713ad491bd957c708f274be313719"

    cert = File.join(File.dirname(__FILE__), "../../app/assets/certs/cacert.pem")             # Sertifika hatasını fixlemek için sertifika manuel alınıyor.
    connection = Faraday.new('https://api.github.com', ssl: { ca_file: cert })

    response_user  = connection.get("users/#{ username }?access_token=#{access_token}")
    response_repos = connection.get("users/#{ username }/repos?access_token=#{access_token}") # Github apilerinden bilgi almak için gerekli bağlantı kuruldu

    user  = JSON.parse(response_user.body)                                                    # Gelen stringi daha rahat kullanmak için hash'e çevirdik
    repos = JSON.parse(response_repos.body)


    stars       = sum_star(repos)
    fav_lang    = fav_lang(repos)

    other_infos = { "repos" => repos, "fav_lang" => fav_lang, "stars" => stars }              # user değişkeni ile birleştirmek için hash haline getiriyoruz.

    user.merge! other_infos                   # Bilgileri user değişkeninin içerisine atarak tek bir değişken return ediyoruz.

  end

  def spaces_on number
    number.to_s.gsub(/\D/, '').reverse.gsub(/.{3}/, '\0.').reverse
  end
  # Bu metod Büyük bir sayıyı daha rahat okunabilmesi için 3 rakam 3 rakam ayırıyor.
  # Bu methodu https://stackoverflow.com/questions/9166553/formatting-a-number-to-split-at-every-third-digit
  # adresinden aldım.

  def sum_star(repos)
    sum = 0                                 # Bu metod toplam yıldız sayısını buluyor.
    repos.each do |repo|
      sum += repo["stargazers_count"]
    end
    sum
  end

  def fav_lang(repos)
    langs = []
    repos.each do |repo|
      langs << repo['language'] unless repo['language'].nil?    # Deponun dili varsa diziye ekliyorum.
    end

    langs.max_by{ |lang| langs.count(lang) }     # En çok tekrar eden dili return ediyorum.
  end

  def get_line_count(username)
    access_token = "8cb02b324d0713ad491bd957c708f274be313719"
    cert = File.join(File.dirname(__FILE__), "../../app/assets/certs/cacert.pem")
    connection = Faraday.new('https://api.github.com', ssl: { ca_file: cert })

    response_repos = connection.get("users/#{ username }/repos?access_token=#{access_token}")
    repos = JSON.parse(response_repos.body)

    line_sum = 0

    repos.each do |repo|
      langs = connection.get("repos/#{ username }/#{ repo['name'] }/languages?access_token=#{access_token}")
      langs = JSON.parse(langs.body)      # Bu iki satırda hangi dillerle kaç satır yazıldığının bilgisi geliyor.
      line_sum += langs.values.sum        # gelen veriler önce birbiriyle, sonra da diğer depoların satır sayıları ile toplanıyor.
    end
    spaces_on(line_sum)                   # Yukarıda tanımlı line_sum methodu ile sayı daha okunaklı yapıldı.
  end
end
