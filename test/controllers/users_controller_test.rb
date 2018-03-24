require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_path
    assert_response :success
  end

  test "if counter successfully increasing" do      # Sayacın doğru bir şekilde artıp artmadığını kontrol eden test.
    get user_show_path("alperen")                   # user_show_path 'e bir username yollayarak sayacı arttırıyorum
    get user_show_path("alperen")                   # Veritanbanında kayıtlı bir kullanıcı olduğu için sayac burada 3 olacak. (bkz: test/fixtures/user.yml)
    user = User.find_by(username: "alperen")        # Veritabanından son durumu getiriyorum.
    assert user.count == 3                          # Eğer olması gereken sayı ile veritabanı eşitse test başarılı.
  end

  test "if the user not exists" do                  # Olmayan bir kullanıcıya istek yollanırsa veritabanına eklenmemesi gerekiyor.
    get user_show_path("wefjhwef")                  # Olmayan bir kullanıcıya istek yapılıyor.
    user = User.find_by(username: "wefjhwef")       # Veritabanından çekmeye çalışıyoruz.

    assert user.nil?                                # Eğer veritabanına eklemezse user nil olacak. Eğer user nilse test başarılıdır.
  end

  test "should get most" do
    get most_popular_users_path(1)
    assert_response :success
  end

  test "if the user is most popular" do
    100.times do
      get user_show_path("alperen")
    end
    user = User.paginate(:page => 1, :per_page => 5).order(count: :DESC).first
    assert user.username.eql? "alperen"
  end
  
end
