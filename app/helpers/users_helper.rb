module UsersHelper
  @@access_token = ""
  def get_user_info(username)
    cert = File.join(File.dirname(__FILE__), "../../app/assets/certs/cacert.pem")             # Sertifika hatasını fixlemek için sertifika manuel alınıyor.
    connection = Faraday.new('https://api.github.com', ssl: { ca_file: cert })

    response_user  = connection.get("users/#{ username }?access_token=#{ @@access_token }")
    response_repos = connection.get("users/#{ username }/repos?access_token=#{ @@access_token }") # Github apilerinden bilgi almak için gerekli bağlantı kuruldu

    user  = JSON.parse(response_user.body)                                                    # Gelen stringi daha rahat kullanmak için hash'e çevirdik
    repos = JSON.parse(response_repos.body)



    if user['login'].present?
      stars       = sum_star(repos)
      fav_lang    = fav_lang(repos)

      other_infos = { "repos" => repos, "fav_lang" => fav_lang, "stars" => stars }            # user değişkeni ile birleştirmek için hash haline getiriyoruz.

      user.merge! other_infos                         # Bilgileri user değişkeninin içerisine atarak tek bir değişken return ediyoruz.
    end
    return user
  end

  def spaces_on number
    humanized = number.to_s.reverse.gsub(/.{3}/, '\0.').reverse
    if number.digits.count % 3 == 0                   # Eğer rakam sayısı 3 veya daha fazlaysa başındaki . yı kaldırdım
      humanized = humanized[1..-1]                    # Örnek : .123.456.789 ==> 123.456.789
    end
    return humanized
  end
  # Bu metod Büyük bir sayıyı daha rahat okunabilmesi için 3 rakam 3 rakam ayırıyor.
  # Bu methodu https://stackoverflow.com/a/9166572/7244925 adresinden aldım.

  def sum_star(repos)
    sum = 0                                           # Bu metod toplam yıldız sayısını buluyor.
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

    langs.max_by{ |lang| langs.count(lang) }          # En çok tekrar eden dili return ediyorum.
  end

  def get_line_count(username)
    cert = File.join(File.dirname(__FILE__), "../../app/assets/certs/cacert.pem")
    connection = Faraday.new('https://api.github.com', ssl: { ca_file: cert })

    response_repos = connection.get("users/#{ username }/repos?access_token=#{ @@access_token }")
    repos = JSON.parse(response_repos.body)

    redirect_to(query_error_path) and return if repos.include? 'message'

    line_sum = 0

    repos.each do |repo|
      unless repo["fork"]                             # Eğer depo forklanmamışsa
        langs = connection.get("repos/#{ username }/#{ repo['name'] }/languages?access_token=#{ @@access_token }")
        langs = JSON.parse(langs.body)                # Bu iki satırda hangi dillerle kaç satır yazıldığının bilgisi geliyor.

        redirect_to(query_error_path) and return if repos.include? 'message'

        line_sum += langs.values.sum                  # gelen veriler önce birbiriyle, sonra da diğer depoların satır sayıları ile toplanıyor.


      end
    end
    spaces_on(line_sum)                               # Yukarıda tanımlı line_sum methodu ile sayı daha okunaklı yapıldı.
  end

  def remaining_time()
    cert = File.join(File.dirname(__FILE__), "../../app/assets/certs/cacert.pem")             # Sertifika hatasını fixlemek için sertifika manuel alınıyor.
    connection = Faraday.new('https://api.github.com', ssl: { ca_file: cert })

    headers = connection.get("").headers
  end
end
