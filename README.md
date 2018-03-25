
# Git Buff

Gitbuff, Github Api kullanarak Github kullanıcılarının bazı istatislikleri göstermek amaçlı yazılmış bir uygulamadır. Uygulama her bir kullanıcının kaç satır kod yazdığını, toplam kaç yıldız aldığını, favori dilini ve gitbuffdan kaç kez profiline bakıldığını gösterir.

## Kurulum
 - Öncelikle bu depoyu klonlamalısınız.
`git clone git@github.com:alperenbozkurt/gitbuff.git`
- Bağımlılıkları yüklemelisiniz.
`bundle install`
- Veritabanını kurmalısınız.
`rake db:setup`
- `rails server` dediğiniz zaman kurulum tamamlanmış olur.

## Ön izleme
Projeyi [http://gitbuff.tk](http://gitbuff.tk) adresinden ön izleyebilirsiniz.

## Teşekkürler
[Faraday gem](https://github.com/lostisland/faraday) geliştiricilerine,
[semantic-ui-sass](https://github.com/doabit/semantic-ui-sass) geliştiricilerine,
[Haml](https://github.com/haml/haml) ve [Sass](https://github.com/sass/sass) geliştiricilerine,
[Jquery](https://github.com/jquery/jquery) ve [Rails-jquery gem](https://github.com/rails/jquery-rails) geliştiricilerine,
Sayfalama için [Will_paginate gem](https://github.com/mislav/will_paginate) geliştiricilerine,
[Ruby](https://github.com/ruby/ruby) ve [Rails](https://github.com/rails/rails) geliştiricilerine,
Ve topluluktaki diğer herkese teşekkürler.

## Lisans
Bu uygulama MIT Lisansı ile lisanslanmıştır.
