# Memorial Patolojinin
Günlük Pratiğinde
Dijital Patoloji

![](img%5Cgpdp0.jpg)

![](img%5Cgpdp1.gif)

![](img%5Cgpdp2.png)

![](img%5Cgpdp3.png)

![](img%5Cgpdp4.png)

# Daha önce gönderdiğim sunum ve yazılara lütfen bakın

_[Patolojide Yapay Zeka](https://docs.google.com/presentation/d/1o1Glh4xTOPYEjX0s9uUKxwhEdwj7NZa7pj7fjZv6gAE/edit#slide=id.p)_

_[Dijital Patoloji'ye Geçerken](https://docs.google.com/document/d/10osEzn36YuIaLW8qQp3ANuQeCZi-SqJkA5LV-R7bcWU/edit#heading=h.vk8e6k5f2h73)_

_[Patolojide Bilişim](https://docs.google.com/document/d/1HUWnkXb-6_IzNHiU3LTVDwLvgQM8eLZUaYWRzeSDl2U/edit#heading=h.awc8eb1l8ncb)_

# Kılavuzlar

_[Leeds Guide to Digital Pathology](https://www.serdarbalci.com/edufiles/18778_Leeds_Guide_to_Digital_Pathology_Brochure_A4_final_hi.pdf)_

_[The Leeds Guide to Digital Pathology Volume 2](https://www.serdarbalci.com/edufiles/Horizontal_Leeds_guide_032222_whtpg1.pdf)_

_[Aperio AT2 DX Users Guide](https://www.serdarbalci.com/edufiles/Aperio_AT2_DX_User_s_Guide.pdf)_

_[Aperio AT2 DX Users Guide Türkçe](https://www.serdarbalci.com/edufiles/Aperio_AT2_DX_User_s_Guide_TR.pdf)_

_[Aperio AT2 Console User Guide](https://www.serdarbalci.com/edufiles/MAN-0251_Aperio_AT2_Console_User_Guide.pdf)_

_[Aperio Brightfield Tarayıcı Güvenlik Talimatları](https://www.serdarbalci.com/edufiles/Aperio-Brightfield-Tarayici-Guvenlik-Talimatlari.pdf)_

_[Sectra Users Guide Pathology Türkçe](https://www.serdarbalci.com/edufiles/Sectra_UsersGuide_Pathology_Turkish.pdf)_

# Nelerden bahsedeceğiz?

Spesmen Kabulü

Makroskopi resimleri

Scanner’dan önce

Scanner’da ne oluyor

Sectra’ya aktarım

Tanı koyarken nelere dikkat edeceğiz

![](img%5Cgpdp5.png)

via \#dalle  _[https://labs\.openai\.com/s/jqJBiW0lElfHIGygPnBhFlBj](https://labs.openai.com/s/jqJBiW0lElfHIGygPnBhFlBj)_

# Spesmen Kabulü

# 

# ViraPis → Sectra

![](img%5Cgpdp6.png)

![](img%5Cgpdp7.jpg)

![](img%5Cgpdp8.png)

# Makroskopi Resimleri

# Makroskopi Resimlerini Yüklemek

# Uniview

_[https://sectra\.memorial\.com\.tr/uniview/](https://sectra.memorial.com.tr/uniview/)_

![](img%5Cgpdp9.png)

![](img%5Cgpdp10.png)

![](img%5Cgpdp11.png)

![](img%5Cgpdp12.png)

![](img%5Cgpdp13.png)

![](img%5Cgpdp14.png)

![](img%5Cgpdp15.png)

![](img%5Cgpdp16.png)

![](img%5Cgpdp17.png)

![](img%5Cgpdp18.png)

![](img%5Cgpdp19.png)

# Makroskopi Resimlerini Yüklemek

# IDS7

IDS7 sadece windows ve sadece Edge browser ile çalışıyor

![](img%5Cgpdp20.png)

![](img%5Cgpdp21.png)

# Dışarıdan Gelen Resimleri Yüklemek

Bunun için de IDS7’deki yöntem en ideali\.

![](img%5Cgpdp22.png)

# Makroskopi Resimlerini Bulmak

# Uniview

![](img%5Cgpdp23.png)

![](img%5Cgpdp24.png)

# IDS7

![](img%5Cgpdp25.png)

![](img%5Cgpdp26.png)

![](img%5Cgpdp27.png)

# Mikroskopi WSI

# Aperio / Tarama Cihazı

# Tarama Öncesi

Barkod

Lam

![](img%5Cgpdp28.png)

# Barkod

__Barkod\, Karekod\, QR Code\, Datamatrix__

_[What Are Those Other Weird QR Codes?](https://youtu.be/KMsvtqQqz5g)_

![](img%5Cgpdp29.jpg)

![](img%5Cgpdp30.jpg)

![](img%5Cgpdp31.png)

# 

![](img%5Cgpdp32.jpg)

![](img%5Cgpdp33.png)

_[https://regex101\.com/r/OmbUN6/12](https://regex101.com/r/OmbUN6/12)_

# Barkod neden önemli

* Sanal mapenin düzgün oluşması
* Lamların sıralı dizilmesi
* HE ve Özel boyaların sıralı dizilmesi
* İleride ilgili algoritması çalışacak lamların tespiti
  * Mesela Ki\-67 düzgün bir şekilde düzgün yere yazılırsa bu lamda algoritma taramadan hemen sonra çalışacaktır\. Aksi halde algoritmayı manuel çalıştırmak gerekecek\.
  * Bunun için sadece barkod da yeterli olmayacak\, SUT kodlu istek türleri yerine klinik anlamlılığı olan ifadelerle gruplamalar yapmak gerekecektir\.

# Barkod olmayınca ne oluyor?

* Uyumsuz olarak belirlenip geçici alana kopyalanıyor
* El ile bunları taşımak gerekiyor
  * Bu sırada hatalar oluyor
* Geçici alanda biriken dosyalar sistemin performansını düşürüyor
* Lamdan haberi olmayan patolog raporu o lama bakmadan yazabiliyor

![](img%5Cgpdp34.png)

![](img%5Cgpdp35.png)

![](img%5Cgpdp36.png)

# Sanal Mape

# 

![](img%5Cgpdp37.png)

![](img%5Cgpdp38.jpg)

![](img%5Cgpdp39.jpg)

![](img%5Cgpdp40.png)

![](img%5Cgpdp41.png)

![](img%5Cgpdp42.png)

# Görüntü Silmek

![](img%5Cgpdp43.png)

![](img%5Cgpdp44.png)

# Görüntü Bilgisini Düzeltmek

![](img%5Cgpdp45.png)

![](img%5Cgpdp46.png)

# Kalibrasyon

![](img%5Cgpdp47.png)

![](img%5Cgpdp48.png)

![](img%5Cgpdp49.png)

_[https://www\.instagram\.com/p/CacgqWKo68d/](https://www.instagram.com/p/CacgqWKo68d/)_

![](img%5Cgpdp50.png)

![](img%5Cgpdp51.png)

![](img%5Cgpdp52.png)

![](img%5Cgpdp53.png)

![](img%5Cgpdp54.png)

![](img%5Cgpdp55.jpg)

![](img%5Cgpdp56.jpg)

![](img%5Cgpdp57.jpg)

![](img%5Cgpdp58.jpg)

![](img%5Cgpdp59.jpg)

![](img%5Cgpdp60.jpg)

![](img%5Cgpdp61.jpg)

![](img%5Cgpdp62.jpg)

![](img%5Cgpdp63.jpg)

![](img%5Cgpdp64.jpg)

# 

![](img%5Cgpdp65.png)

![](img%5Cgpdp66.png)

# Lam Özellikleri

![](img%5Cgpdp67.png)

# 

![](img%5Cgpdp68.png)

![](img%5Cgpdp69.png)

![](img%5Cgpdp70.png)

![](img%5Cgpdp71.png)

![](img%5Cgpdp72.png)

![](img%5Cgpdp73.jpg)

![](img%5Cgpdp74.jpg)

![](img%5Cgpdp75.png)

![](img%5Cgpdp76.png)

# Aynı cam, aynı alan, aynı makina, aynı büyütme.

![](img%5Cgpdp77.png)

# Küçük bir kabarcık tüm taramanın kalitesini bozmuş. alanı seçip fokus noktasını ayarlamak lazım. Bunun için her lamın tarandıktan sonra kalite kontrolünden geçmesi lazım

![](img%5Cgpdp78.png)

![](img%5Cgpdp79.png)

![](img%5Cgpdp80.png)

![](img%5Cgpdp81.png)

![](img%5Cgpdp82.png)

![](img%5Cgpdp83.png)

# Tarama Nasıl Yapılır

# Tarama nasıl yapılır?

![](img%5Cgpdp84.jpg)

![](img%5Cgpdp85.jpg)

![](img%5Cgpdp86.png)

![](img%5Cgpdp87.jpg)

![](img%5Cgpdp88.jpg)

![](img%5Cgpdp89.jpg)

![](img%5Cgpdp90.jpg)

# Lamların Dizilmesi

![](img%5Cgpdp91.jpg)

![](img%5Cgpdp92.jpg)

![](img%5Cgpdp93.jpg)

![](img%5Cgpdp94.jpg)

![](img%5Cgpdp95.png)

![](img%5Cgpdp96.png)

![](img%5Cgpdp97.jpg)

![](img%5Cgpdp98.jpg)

# Önizleme

![](img%5Cgpdp99.png)

![](img%5Cgpdp100.png)

![](img%5Cgpdp101.png)

![](img%5Cgpdp102.png)

![](img%5Cgpdp103.png)

![](img%5Cgpdp104.jpg)

# Odaklama Noktaları

![](img%5Cgpdp105.png)

# Tarama Sırasında

![](img%5Cgpdp106.png)

![](img%5Cgpdp107.png)

![](img%5Cgpdp108.png)

# Mikroskopi Resimleri Nasıl Yükleniyor

![](img%5Cgpdp109.png)

![](img%5Cgpdp110.png)

![](img%5Cgpdp111.png)

![](img%5Cgpdp112.png)

![](img%5Cgpdp113.png)

# Uyumsuz Vakalar
Barkod Nedenli

![](img%5Cgpdp114.png)

![](img%5Cgpdp115.png)

![](img%5Cgpdp116.png)

![](img%5Cgpdp117.png)

![](img%5Cgpdp118.png)

![](img%5Cgpdp119.png)

![](img%5Cgpdp120.png)

# Uyumsuz Vakalar
Hasta Numarası Nedenli

![](img%5Cgpdp121.png)

![](img%5Cgpdp122.png)

![](img%5Cgpdp123.png)

![](img%5Cgpdp124.png)

![](img%5Cgpdp125.png)

![](img%5Cgpdp126.png)

![](img%5Cgpdp127.jpg)

# Uyumsuz Vakalar
Hatalı Görüntülerin Transferi

# Sectra’da hasta birleştirme ve görüntü aktarımı

![](img%5Cgpdp128.jpg)

![](img%5Cgpdp129.jpg)

# Dışarıdan Gelen 
WSI dosyalarını (.svs)
Yüklemek

![](img%5Cgpdp130.png)

![](img%5Cgpdp131.png)

![](img%5Cgpdp132.png)

![](img%5Cgpdp133.png)

![](img%5Cgpdp134.png)

# Rutin Dışı Farklı Özellikle Vaka Taramak

![](img%5Cgpdp135.jpg)

# 

![](img%5Cgpdp136.png)

![](img%5Cgpdp137.png)

![](img%5Cgpdp138.jpg)

![](img%5Cgpdp139.jpg)

![](img%5Cgpdp140.jpg)

![](img%5Cgpdp141.jpg)

![](img%5Cgpdp142.jpg)

# IHK taranması

![](img%5Cgpdp143.png)

# Sitoloji Taraması

# 

![](img%5Cgpdp144.jpg)

![](img%5Cgpdp145.png)

# Mega Lam Taraması

![](img%5Cgpdp146.jpg)

![](img%5Cgpdp147.jpg)

![](img%5Cgpdp148.png)

![](img%5Cgpdp149.jpg)

![](img%5Cgpdp150.png)

![](img%5Cgpdp151.png)

![](img%5Cgpdp152.jpg)

![](img%5Cgpdp153.png)

# Aradan nasıl vaka taranır?

![](img%5Cgpdp154.png)

![](img%5Cgpdp155.jpg)

![](img%5Cgpdp156.jpg)

![](img%5Cgpdp157.jpg)

# Hata Mesajları

![](img%5Cgpdp158.png)

![](img%5Cgpdp159.png)

![](img%5Cgpdp160.png)

![](img%5Cgpdp161.png)

![](img%5Cgpdp162.png)

![](img%5Cgpdp163.png)

![](img%5Cgpdp164.png)

![](img%5Cgpdp165.jpg)

![](img%5Cgpdp166.jpg)

# En hızlı tarama için camları taramaya nasıl koyalım?

![](img%5Cgpdp167.png)

Teknikerleri gerçek acil olmayan vakalar için aramayalım

Mümkün olduğu kadar cihazı durdurmadan taramalara ekleme yapalım

Taranacak vakaların önden kesilmesini\, farklı renkli lama kesilmesini sağlayalım

Biraz sabırlı olalım\.

GT450 denemesi sonrasında satın alma kronometre ile ölçüm yapıyor günlerdir\.

2 \- 10 dakika arasında değişiyor bir lamın taranması\.

3 \- 4 dakika x 10 rack x 40 lam = 1200 \- 1600 dakika \(20\-26 saat\)

Bu sorudan önce:

__En hızlı tarama için lamları nasıl hazırlayalım?__

__Eskinin analitik süreci \(tüm laboratuvar\)\, dijital için preanalitik süreç oldu\.__

![](img%5Cgpdp168.jpg)

![](img%5Cgpdp169.jpg)

![](img%5Cgpdp170.jpg)

# Tarama Cihazı Bakımı

Kalibrasyon

Cam Kırıkları

Toz

6 ayda bir kırılma indisi düzeltmesi

![](img%5Cgpdp171.jpg)

![](img%5Cgpdp172.png)

![](img%5Cgpdp173.png)

![](img%5Cgpdp174.jpg)

![](img%5Cgpdp175.jpg)

![](img%5Cgpdp176.png)

# Memorial Patolojinin Günlük Pratiğinde Dijital Patoloji
Önceki Sunumdan Kalanlar

![](img%5Cgpdp177.gif)

![](img%5Cgpdp178.png)

![](img%5Cgpdp179.png)

![](img%5Cgpdp180.png)

![](img%5Cgpdp181.png)

__Şu an iş akışımızda mape dizimi önce geliyor\. Boyadan çıkan lamlar kurutulduktan sonra mapelere diziliyor\. Daha sonra dağıtıma çıkıyor\. Dijitale giden vakalar da bu mape dizilimini beklediği için saat 3\-4’e kadar bekliyor\. Daha sonra raklara dizme\, ön tarama yapılması ve cihazın çalıştırılması başlıyor\. Sabaha kadar çalışan cihazda 400 lamın yaklaşık %75\-80’i taranmış oluyor\. Kalanlar da ertesi sabah tamamlanmış oluyor\.__

![](img%5Cgpdp182.png)

__Hibrid bir iş akışında boyama cihazından çıkan vakaların dijitale mi yoksa mape dizimine mi gideceğine karar verilmesi gerekecek\. Bu adım potansiyel hatalara ve gecikmelere sebep olacaktır\.__

![](img%5Cgpdp183.png)

__Tam dijital bir iş akışında ise boyadan çıkan lamlar direk taramaya alınacak ve mape dizimi yapılmadan lamlar arşive gidecektir\. Bu durumda bir mape hazırlama basamağı olmayacaktır\.__

# Tam dijital ve hibrid bir iş akışında şu noktalara dikkat etmek lazım

__Hangi vakanın dijitalde tamamlandığı \(dijital bir mape ile hazır olduğu\) nasıl bilinecek?__

__Uzman vakayı açıp blok ve lam sayısına bakıp vaka hazır diye mi kabul edecek?__

__Yoksa bir tekniker bu vaka tam diye kontrol edip bunu haber mi verecek?__

__Tekniker haber verecekse bu nasıl olacak? Mail ile olan bildirimler karışıklığa neden oluyor\.__

__Sectra’da vaka durumu özelliği var\. Ancak bir lam bile yüklense “çekim” durumuna geliyor\. Bunu kontrol eden tekniker “gönderildi” gibi bir sonraki basamağa bunu aktarabilir\.__

__Bu bilgi sadece sectra’da mı olacak yoksa rapora hazır bilgisi virapis’e de giderek bunu güncelleyecek mi \(bildiğim kadarıyla sectra durum bilgilerini güncelleyip virapise gönderecek bir yapıda değil\)__

![](img%5Cgpdp184.png)

# Tarama Sonrası

# Tanı süreci

# Sectra eğitim videoları

_[https://trainingvideos\.sectra\.com/library/lang/en](https://trainingvideos.sectra.com/library/lang/en)_

_[Sectra Training Video Library](https://trainingvideos.sectra.com/library/tag/pathology)_

Sectra Yardım menüsünden ulaşılabilecek kılavuzlar:

Kullanıcı Kılavuzu IDS7

Kullanıcı Kılavuzu Patoloji Görüntü Penceresi

![](img%5Cgpdp185.jpg)

# 

![](img%5Cgpdp186.jpg)

![](img%5Cgpdp187.jpg)

# Mikroskopi Resimlerini Bulmak

# ViraPis üzerinden

![](img%5Cgpdp188.png)

# IDS7

![](img%5Cgpdp189.png)

![](img%5Cgpdp190.png)

![](img%5Cgpdp191.png)

# Uniview

![](img%5Cgpdp192.png)

# Lamların Tümü Taranmış Mı?

__Virapisten lam sayısı sectraya gidiyor\. Ancak bu lam sayısına sadece HE’ler dahil\, özel boyalar ve yaymalar dahil değil\. Bu sayı sadece virapisin numaraladığı blok ve lamlar üzerinden hesaplanıyor\. Dolayısıyla bize bir fikir verebilse de tam işe yaramış diyemeyiz\.__

![](img%5Cgpdp193.png)

![](img%5Cgpdp194.png)

![](img%5Cgpdp195.png)

![](img%5Cgpdp196.png)

![](img%5Cgpdp197.png)

![](img%5Cgpdp198.png)

![](img%5Cgpdp199.png)

![](img%5Cgpdp200.png)

![](img%5Cgpdp201.png)

# Lamın Tamamı Taranmış Mı?

__Lamların tümünün taranmış olması vakanın onaylanması için yeterli olur mu? \(İstek kağıdı\, makroskopide sorun olmadığını varsayarak\)\. Taramayı yapan tekniker vakanın onaya hazır olduğunu belirtmeden önce taramada sorun olup olmadığını kontrol edecek mi? \(Şu anki cihaz için söylüyorum\) Ya da boyaların durumunu kontrol edecek mi? Bu kısmı teknikerlerin yapabileceğini sanmıyorum\. Artık o vakanın uzmanına kalacak\. Ve gerekirse yeniden tarama ya da lamları isteyecek\.__

![](img%5Cgpdp202.png)

![](img%5Cgpdp203.png)

![](img%5Cgpdp204.png)

# Doğru Lam Taranmış Mı?

![](img%5Cgpdp205.png)

![](img%5Cgpdp206.png)

# Ekranda Gezinti

Muscle Memory

Yeni kuşak patolojinin yeni ergonomi sorunları

# 

![](img%5Cgpdp207.png)

![](img%5Cgpdp208.jpg)

![](img%5Cgpdp209.png)

_[https://www\.sysmex\.com\.tr/ueruenler/products\-detail/slidedriver\.html](https://www.sysmex.com.tr/ueruenler/products-detail/slidedriver.html)_

![](img%5Cgpdp210.png)

![](img%5Cgpdp211.png)

![](img%5Cgpdp212.jpg)

![](img%5Cgpdp213.png)

![](img%5Cgpdp214.png)

![](img%5Cgpdp215.png)

![](img%5Cgpdp216.png)

__Mac kullananlar için: __  <span style="color:#1155CC"> _[https://middleclick\.app/](https://middleclick.app/)_ </span>

<span style="color:#434343">Mouse\, 3D Mouse:</span>

<span style="color:#1155CC"> _[https://www\.cimri\.com/klavye\-mouse/en\-ucuz\-3dconnexion\-klavye\-mouse\-fiyatlari](https://www.cimri.com/klavye-mouse/en-ucuz-3dconnexion-klavye-mouse-fiyatlari)_ </span>

<span style="color:#1155CC"> _[https://3dconnexion\.com/uk/product/spacemouse\-pro/](https://3dconnexion.com/uk/product/spacemouse-pro/)_ </span>

<span style="color:#434343">Digital Pathology Cockpit:</span>

<span style="color:#1155CC"> _[Digital Pathology Cockpit \- 3DHISTECH Ltd\.](https://www.3dhistech.com/solutions/digital-pathology-cockpit/)_ </span>

<span style="color:#1155CC"> _[SlideDriver \- 3DHISTECH Ltd\.](https://www.3dhistech.com/diagnostics/lab-components/slidedriver/)_ </span>

# Lamları Gözden Geçirildi Olarak İşaretleme

![](img%5Cgpdp217.jpg)

# Ekran

_[https://www\.virtualpathology\.leeds\.ac\.uk/research/systems/pouqa/pathology/](https://www.virtualpathology.leeds.ac.uk/research/systems/pouqa/pathology/)_

![](img%5Cgpdp218.png)

![](img%5Cgpdp219.png)

# Öğretim Dosyası Anahtar Sözcükleri

![](img%5Cgpdp220.png)

![](img%5Cgpdp221.png)

![](img%5Cgpdp222.png)

![](img%5Cgpdp223.png)

# Anahtar kelimeler ile vakayı bulmak

![](img%5Cgpdp224.png)

![](img%5Cgpdp225.png)

![](img%5Cgpdp226.png)

![](img%5Cgpdp227.png)

![](img%5Cgpdp228.png)

![](img%5Cgpdp229.png)

![](img%5Cgpdp230.png)

![](img%5Cgpdp231.png)

![](img%5Cgpdp232.png)

# İş Listesi Oluşturmak

![](img%5Cgpdp233.png)

![](img%5Cgpdp234.png)

![](img%5Cgpdp235.png)

![](img%5Cgpdp236.png)

![](img%5Cgpdp237.png)

![](img%5Cgpdp238.png)

![](img%5Cgpdp239.png)

![](img%5Cgpdp240.png)

![](img%5Cgpdp241.png)

![](img%5Cgpdp242.png)

# 

![](img%5Cgpdp243.png)

![](img%5Cgpdp244.png)

![](img%5Cgpdp245.png)

![](img%5Cgpdp246.png)

![](img%5Cgpdp247.png)

![](img%5Cgpdp248.png)

![](img%5Cgpdp249.png)

![](img%5Cgpdp250.png)

![](img%5Cgpdp251.png)

![](img%5Cgpdp252.png)

![](img%5Cgpdp253.png)

![](img%5Cgpdp254.png)

![](img%5Cgpdp255.png)

![](img%5Cgpdp256.png)

![](img%5Cgpdp257.png)

![](img%5Cgpdp258.png)

![](img%5Cgpdp259.png)

![](img%5Cgpdp260.png)

![](img%5Cgpdp261.png)

![](img%5Cgpdp262.png)

![](img%5Cgpdp263.png)

![](img%5Cgpdp264.png)

![](img%5Cgpdp265.png)

![](img%5Cgpdp266.png)

# Arşivlenmiş Vakalar

![](img%5Cgpdp267.png)

![](img%5Cgpdp268.png)

![](img%5Cgpdp269.png)

![](img%5Cgpdp270.png)

![](img%5Cgpdp271.png)

# Hastaları geçici olarak anonim hale getirmek

![](img%5Cgpdp272.png)

![](img%5Cgpdp273.png)

![](img%5Cgpdp274.png)

# Vaka dökümü almak

![](img%5Cgpdp275.png)

![](img%5Cgpdp276.png)

# 20x vs 40x

![](img%5Cgpdp277.png)

# Senkron görüntüleme

![](img%5Cgpdp278.jpg)

# Not alma

# Ölçüm

# Bağlantı hızı

# Işık / Gamma ayarı

![](img%5Cgpdp279.png)

# Dış Konsültasyon İçin Link Oluşturmak

![](img%5Cgpdp280.png)

via \#dalle  _[https://labs\.openai\.com/s/Yp6cRTIqZwB0LHxSz2uAZa9O](https://labs.openai.com/s/Yp6cRTIqZwB0LHxSz2uAZa9O)_

![](img%5Cgpdp281.png)

![](img%5Cgpdp282.png)

![](img%5Cgpdp283.png)

# Sanal Hasta, Çalışma Hastası Oluşturmak

![](img%5Cgpdp284.png)

![](img%5Cgpdp285.png)

![](img%5Cgpdp286.png)

![](img%5Cgpdp287.png)

![](img%5Cgpdp288.png)

![](img%5Cgpdp289.jpg)

# Görüntüleri Dışa aktarmak
.svs olarak kaydetmek

![](img%5Cgpdp290.png)

![](img%5Cgpdp291.png)

Bu dışarı aktarma uniview ekranından da yapılabiliyor\, ancak dışarı paylaşılan linklerde bu özellik aktif değil

![](img%5Cgpdp292.png)

![](img%5Cgpdp293.png)

![](img%5Cgpdp294.png)

![](img%5Cgpdp295.png)

![](img%5Cgpdp296.png)

_[10 Open\-source Whole\-Slide Image Viewers and Analysis Programs; Redefining Digital Pathology](https://medevel.com/10-os-whole-slide-image/)_

_[8 free open source software programs for image analysis of pathology slides](https://digitalpathologyplace.com/8-free-open-source-software-programs-for-image-analysis-of-pathology-slides/)_

![](img%5Cgpdp297.png)

_[https://www\.leicabiosystems\.com/digital\-pathology/manage/aperio\-imagescope/](https://www.leicabiosystems.com/digital-pathology/manage/aperio-imagescope/)_

![](img%5Cgpdp298.png)

_[https://qupath\.github\.io/](https://qupath.github.io/)_

![](img%5Cgpdp299.png)

_[https://www\.pathomation\.com/pma\-start/](https://www.pathomation.com/pma-start/)_

![](img%5Cgpdp300.png)

_[https://www\.iis\.fraunhofer\.de/en/ff/sse/health/medical\-image\-analysis/mikroskopie/micaia\.html](https://www.iis.fraunhofer.de/en/ff/sse/health/medical-image-analysis/mikroskopie/micaia.html)_

![](img%5Cgpdp301.png)

![](img%5Cgpdp302.png)

![](img%5Cgpdp303.png)

![](img%5Cgpdp304.png)

# 

# anonim olarak bir grup hastayı paylaşmak
(çalışma, kurs, eğitim ve öğrenci dersleri için)

__Paige ve başka firmalar çalışması için anonim olarak bir grup hastayı paylaşmak gerekti\. Bunun için svs dosyalarını indirmek ve tekrar yüklemek çok zaman alıyordu\.__

__Onun için bir "visitor" hesabı oluşturdu Sectra ekibi\.__

__Bu hesapla giren kişiler sadece bizim bu klasöre sürükleyip bıraktığımız vakaları anonim olarak görecekler\. \(burada notlar ve raporu görme opsiyonu da vardı ama ben onu istemedim\)\. Burada sadece patoloji mikroskopi ve makroskopi görüntüleri anonim olarak görünebiliyor\. Diğer tetkikler ve bilgiler görünmüyor\.__

__Bu hesapla giren kişiler svs dosyalarını da anonim olarak indirebilecekler\. Anonimleştirme işlemi erişim numarasını ve boyaları ortadan kaldırmıyor\. Erişim numarasının HIPAA'ya uygun olup olmadığı Sectra forumlarında tartışılıyordu\. Ama o konuda daha güncelleme gelmemiş\.__

__Bu hesapla ya da benzeri hesaplarla vaka paylaşabilir\, kurslar düzenleyebilir\, öğrenciler için kolleksiyonlar yapabilirsiniz\. Böylece vakanın tümünü anonim olarak paylaştığınız gerçek hayatla uyumlu eğitim ve kurslar düzenleyebilirsiniz\. Reklamlar :\)__

__İlerisi için aklınızda olsun\.__

![](img%5Cgpdp305.png)

![](img%5Cgpdp306.png)

![](img%5Cgpdp307.png)

# Sectra’da raporlama ve ses kaydı

![](img%5Cgpdp308.jpg)

Sectra’da rapor için ses kayıt

![](img%5Cgpdp309.jpg)

Sectra’da rapor için ses kayıt

![](img%5Cgpdp310.png)

Sectra’da rapor için ses kayıt

![](img%5Cgpdp311.jpg)

![](img%5Cgpdp312.png)

Rosai\, 10th Ed\. Chapter 1

_[https://my\.sectra\.com/en\-US/ideas/digital\_pathology/](https://my.sectra.com/en-US/ideas/digital_pathology/)_

![](img%5Cgpdp313.png)

![](img%5Cgpdp314.png)

![](img%5Cgpdp315.png)

![](img%5Cgpdp316.png)

![](img%5Cgpdp317.png)

![](img%5Cgpdp318.png)

![](img%5Cgpdp319.png)

![](img%5Cgpdp320.png)

![](img%5Cgpdp321.png)

_[https://cubicl\.io/portals/5c52931175aca05eac172ee5/](https://cubicl.io/portals/5c52931175aca05eac172ee5/)_

![](img%5Cgpdp322.png)

# 

![](img%5Cgpdp323.png)

# Kalite Kontrol

![](img%5Cgpdp324.jpg)

# Okuma önerileri

_[The Leeds Guide to Digital Pathology](https://www.virtualpathology.leeds.ac.uk/research/clinical/docs/2018/pdfs/18778_Leeds%20Guide%20to%20Digital%20Pathology_Brochure_A4_final_hi.pdf)_

_[Future\-proofing pathology: the case for clinical adoption of digital pathology](https://jcp.bmj.com/content/70/12/1010.long)_

![](img%5Cgpdp325.jpg)

![](img%5Cgpdp326.gif)

![](img%5Cgpdp327.gif)

![](img%5Cgpdp328.png)

![](img%5Cgpdp329.png)

![](img%5Cgpdp330.png)

![](img%5Cgpdp331.png)

![](img%5Cgpdp332.png)

https://www\.linkedin\.com/posts/igor2k\_artificialintelligence\-neuroscience\-cognitivescience\-activity\-6987973855575166976\-bdfA?utm\_source=share&utm\_medium=member\_desktop

![](img%5Cgpdp333.png)

_[https://www\.augmentiqs\.com/microscope\-based\-digital\-pathology\-system/](https://www.augmentiqs.com/microscope-based-digital-pathology-system/)_

![](img%5Cgpdp334.jpg)

![](img%5Cgpdp335.png)

![](img%5Cgpdp336.png)

![](img%5Cgpdp337.png)

![](img%5Cgpdp338.png)

![](img%5Cgpdp339.png)

