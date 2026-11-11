# Gök Taşları

> Eski çalışma adı: "Tengri'nin Taşları" (paket adı `tengri_taslari` / `com.tengritaslari.tengri_taslari` değişmedi).

Okey taşlarıyla oynanan, Türk mitolojisi temalı, deste kurmalı **roguelike bulmaca oyunu**.
Flutter (+ ileride Flame), Android öncelikli, dikey ekran.

> Durum: **Faz 5 — Kalıcılık ve yayın hazırlığı** tamamlandı. Tüm fazlar bitti.

## Mimari

```
lib/
  core/            Saf Dart oyun mantığı (Flutter import'u YASAK, testle korunuyor)
    rng/           SeededRng (xoshiro128**), seed kodları, fork ile alt akışlar
    tiles/         Tile, RunDeck (106 taş), DrawPile, OkeyInfo (gösterge/okey/sahte okey)
    hands/         HandType, HandLevels, HandEvaluator (okey joker + Gök Taşı dahil)
    scoring/       ScoringEngine, ScoreEvent (animasyon akışı), Kut arayüzü
    round/         Round durum makinesi, RoundRules (boss kısıtları), rack sıralama
    run/           RunState (koşu durum makinesi), Pazar/Kese/Kupon, Destan/Tılsım, etiketler
    sim/           AutoPlayer (açgözlü bot: simülasyon & denge)
  data/            Veri odaklı içerik
    balance.dart   TÜM denge sayıları (el tablosu, hedefler, ekonomi, Kut değerleri)
    kuts.dart      20 Kut (kut_behaviors.dart'taki parametrik davranışlardan)
    bosses.dart    8 Boss (RoundRules olarak)
    consumables.dart  12 Destan, 8 Tılsım, 7 Kupon
    run_setup.dart    Denge sayılarını ve kataloğu çekirdeğe bağlar
  l10n/            ARB dosyaları (app_tr.arb varsayılan, app_en.arb) + üretilen sınıflar
  services/        Ses, müzik, titreşim, depolama (shared_preferences), kayıt, ayarlar,
                   MonetizationService (boş arayüz)
  ui/
    art/           Kodla çizilen yer tutucular (taş, renk sembolleri, tamgalar, Kut amblemi)
    theme/         Palette (tüm renkler tek yerde), tema
    game/          GameController (Riverpod) + GameState + GameRoot (ekran geçişleri)
    screens/       Ana Menü, Tur Seçimi, Tur Sonucu, Pazar, Kese, Koşu Sonu
    table/         Oyun masası widget'ları
    widgets/       Ortak efektler (count-up, zıplama, titreme, uçan etiket, ekran sarsıntısı)
    settings/      Oyun hızı (1×/2×/4×)
bin/
  simulate.dart    Konsolda tek tur oynatma (etkileşimli veya --auto)
  balance_sim.dart Bot ile tek tur kazanma oranı tablosu (kat × tur)
  run_sim.dart     Tam koşu simülasyonu: kazanma oranı, ölüm haritası, Kut tablosu
tool/
  gen_placeholder_sounds.py  assets/audio/ yer tutucu ses + müziğini sentezler
  gen_app_icon.py            Uygulama ikonu yer tutucusu (Android + iOS boyutları)
test/              Unit testler (core + data)
```

Bağımlılık yönü: `ui → data → core`. `core` hiçbir şeye bağımlı değildir.

### Puanlama sırası (`ScoringEngine`)
1. El türü → taban Puan / Çarpan (seviyeye göre).
2. Kut'ların `beforeScoring` kancası (ör. Gök Börü büyümesi).
3. Sayılan her taş soldan sağa, her tetiklenmede: sayı değeri → geliştirme → tamga → o taşa tepki veren Kut'lar.
   Kızıl Tamga ve Kam Davulu ekstra tetikleme ekler.
4. İstakada tutulan taşlar soldan sağa (Demir ×1.5, Ergenekon).
5. Kut'ların el efektleri soldan sağa.
6. Skor = ⌊Puan × Çarpan⌋, sonra boss kuralları (Şahmeran, Erlik Han).

Her adım bir `ScoreEvent` üretir (kaynak, miktar, ara toplamlar) — Faz 2'deki animasyonlar bu listeyi oynatır.

## Çalıştırma

```bash
flutter pub get
flutter run                                      # Android cihaz/emülatör
flutter test                                     # unit + widget testleri
dart run bin/simulate.dart                       # etkileşimli tur (rastgele seed)
dart run bin/simulate.dart --seed TENGRI42 --auto
dart run bin/simulate.dart --kuts umay_ana,bozkurt --boss kara_kus
dart run bin/balance_sim.dart --rounds 40        # tek tur kazanma oranları
dart run bin/run_sim.dart --runs 300             # tam koşu dengesi
```

Konsol komutları: `p 0 3 5` oyna, `d 1 2` değiştir, `v 0 3 5` önizleme, `m 7 0` taşı taşı,
`s`/`c` sayıya/renge göre diz, `r 2` kapalı taşı aç, `q` çıkış.

## Faz 2 — Oyun masası

- Masa **Flutter widget'ları** ile yapıldı (Flame yok): istaka, sürükle-bırak ve düzen widget'larla daha
  sağlam; animasyonlar `TweenAnimationBuilder`/`AnimationController` ile. Parçacıklar gerekirse Faz 4'te.
- **Riverpod** `TableController` mevcut `Round`'u tutar; oynanan elde çekirdeğin ürettiği `ScoreEvent`
  listesi adım adım oynatılır (taş zıplar + "+15", Kut kartı titrer + "+10 Çarpan", Puan/Çarpan
  kutuları sayarak artar, en sonda "+845"). Büyük skorda (hedefin %50'si) ekran sarsılır + güçlü titreşim.
- Oyun masasına dokunmak animasyonu atlar; HUD'daki **1×/2×/4×** oyun hızını değiştirir.
- İstakada **dokun = seç** (en fazla 6), **sürükle = yeniden diz**; "Sayı" / "Renk" ile otomatik diz.
- Faz 2 demo turu: Kat 1 Küçük Sınav (hedef 300), başlangıçta **Umay Ana + Bozkurt** Kut'ları
  (`demoKutIds`, Faz 3'te koşu döngüsüyle değişecek).
- Varsayılan dil **Türkçe**; dil seçimi Faz 5 ayarlarında. Web/debug derlemelerinde `?seed=KOD`
  aynı turu yeniden üretir.

## Faz 3 — Koşu döngüsü

Akış: **Ana Menü → Tur Seçimi → Masa → Tur Sonucu → Pazar → Tur Seçimi … → Koşu Sonu**.

- `RunState` (saf Dart) tüm koşuyu yönetir: 8 Kat × (Küçük, Büyük, Boss), Akçe, Kut'lar, eşyalar,
  Kuponlar, istatistikler. Her rastgele karar seed'in o yere özel bir dalından gelir
  (`boss-f3`, `shop-f2-r1` ...), yani aynı seed + aynı hamleler = aynı koşu.
- **Tur Seçimi:** Küçük/Büyük atlanabilir; her birinin önceden belli bir etiketi var
  (+5 Akçe veya bedava Kut/Destan/Tılsım Kesesi). Boss atlanamaz; kat başında seçilir, aynı Boss
  havuz bitene kadar tekrar gelmez.
- **Tur Sonucu:** tur ödülü (3/4/5) + kalan El başına 1 + Kut paraları (Dede Korkut) + istakadaki
  Altın taşlar + Altın Tamgalar + faiz (her 5 Akçe'ye 1, en fazla 5).
- **Pazar:** 2 tezgâh yuvası (Kut %70 / Destan %15 / Tılsım %15; nadirlik 70/25/5), 2 Kese,
  kat başına 1 Kupon, yenileme 5 (+1 artar; Kervan ilki bedava). Kut'lar ve eşyalar yarı fiyata satılır.
- **Keseler:** 3 seçenekten 1. Destan seçilince hemen uygulanır; Kut/Tılsım boş yuva ister;
  Taş Kesesi geliştirmeli/tamgalı yeni taşı desteye ekler.
- **Eşyalar:** dokun → açıklama, Kullan / Sat. Taş isteyen Tılsımlar masada, istakadan seçili taşlara
  uygulanır (istaka + deste birlikte güncellenir).
- **Kut'lar** sürüklenerek sıralanır (tetiklenme sırası); büyüyen Kut'lar kartta rozet gösterir (×2, +3).
- 8. Kat Boss'u yenilince koşu kazanılır; **Sonsuz Gök** ile 9. kattan devam edilebilir.
- Arka plan dünyaya göre değişir: Yeraltı (Kat 1-2), Yeryüzü (3-5), Gökyüzü (6-8, yıldızlı).

## Faz 4 — İçerik, denge ve his

**İçerik:** 24 Kut (yeni: Od Ana, Yer-Su, Ötüken, Kök Tengri), 12 Boss (yeni: Yalmavuz, Abası,
Şulmus, Kara Kam), 12 Destan, 8 Tılsım, 7 Kupon, 5 geliştirme, 4 Tamga. Tüm içeriğin TR/EN metni
bir testle denetlenir.

**Denge** (`bin/run_sim.dart`, 300 koşu, açgözlü bot + basit alışveriş):

| | Değer |
|---|---|
| Hedefler (Küçük; Büyük ×1.5, Boss ×2) | 250 · 450 · 800 · 1400 · 2500 · 4300 · 7200 · 12000 |
| Kat büyümesi | 1.67–1.8× |
| Bot kazanma oranı | ~%10 |
| 1. Kat'ta biten koşu | ~%11 |
| Ortalama bitiş katı | ~5.6 |

Bot bilinçli olarak sıradan bir oyuncudur (Tılsım planlamaz, Kut sırası düşünmez); gerçek oyuncunun
daha yükseğe çıkması beklenir. Tepegöz ve Erlik Han 2. Kat'tan itibaren gelir (Kut'suz ilk kat için
fazla sertlerdi). Kopuz +15, Oğuz Kağan +60/+8, Ergenekon +30 olarak ayarlandı.

**His:**
- Gerçek ses: `audioplayers` + sentezlenmiş yer tutucu WAV'lar (taş tıkı, ahşap vuruş, şaman davulu,
  para, arpejler). Aynı adla gerçek kayıtlarla değiştirilebilir.
- Puan zincirinde her adım bir öncekinden biraz daha tiz çalar (gerilim).
- Ekran sarsıntısı skorun hedefe oranıyla güçlenir; büyük ellerde, Tur Sonucu'nda ve koşu
  kazanılınca altın kıvılcım patlaması.
- Boss turları tam ekran Boss tanıtımıyla açılır (dokununca geçer).
- Kese seçenekleri kart gibi sırayla döner. Hepsi sistemin "hareketi azalt" ayarına uyar.

## Faz 5 — Kalıcılık ve yayın hazırlığı

- **Otomatik kayıt:** Koşu her tur arası değişiklikte cihaz deposuna JSON olarak yazılır
  (`run_v1`). Ana Menü'de "Devam Et" (Kat ve Akçe bilgisiyle) kaldığı yerden sürdürür. Tur
  ortasında kapatılan koşu o turun başından devam eder (aynı seed → aynı taşlar). Kaybedilen
  koşunun kaydı silinir. Bozuk/eski bir kayıt oyunu engellemez, sessizce atılır.
- **Ayarlar:** ses efektleri, müzik, titreşim, dil (Türkçe varsayılan / English), oyun hızı
  (1×/2×/4×), renk körü modu (yüksek kontrastlı renkler + büyük ve çift renk sembolü). Hepsi
  kalıcı ve anında uygulanır.
- **Koleksiyon:** Bir koşuda sahip olunan Kut'lar ve karşılaşılan Boss'lar açılır; başlanan /
  kazanılan koşu, en yüksek el ve en yüksek kat kayıtları.
- **Müzik:** sentezlenmiş 16 sn'lik döngü (gırtlak sesi benzeri dron + kopuz tınıları).
- **Yayın:** uygulama adı "Gök Taşları" (EN: "Sky Stones"), ikon yer tutucusu, yalnızca dikey ekran
  (Android + iOS; iPad `UIRequiresFullScreen`), Android release: R8 küçültme, kaynak küçültme,
  `android/key.properties` ile imzalama (yoksa debug anahtarı). `MonetizationService`
  arayüzü hazır; reklam/IAP yok.

### Android yayın derlemesi

```bash
# 1) Bir kez: yükleme anahtarı oluştur (bu dosyayı asla paylaşma/commit etme)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
# 2) android/key.properties dosyasını oluştur:
#    storeFile=/home/<sen>/upload-keystore.jks
#    storePassword=...
#    keyAlias=upload
#    keyPassword=...
# 3) Derle
flutter build appbundle --release   # Google Play için .aab
flutter build apk --release         # doğrudan kurulum için .apk
```
Sürüm `pubspec.yaml` içindeki `version: 0.1.0+1` satırından gelir (`+1` = versionCode).

## Günlük Meydan Okuma

- Seed günün tarihinden gelir (`GUN20261108`); o gün herkes aynı taşları, Boss'ları ve Pazar'ı görür.
- Her günün bir **başlangıç Kut'u** (Yaygın/Nadir) ve bir **günün lütfu** vardır (+10 Akçe, +1 El,
  +1 Değiştir, +1 istaka, Pazar'da %25 indirim veya faiz sınırı +5) — ikisi de seed'den seçilir.
- Günde tek deneme. Sonuç (ulaşılan kat, toplam skor) profilde saklanır; menüde durum, Günlük
  ekranında son günlerin listesi görünür. "Sonucu paylaş" sonucu panoya kopyalar.
- Günlük koşu ayrı bir kayıt yuvasındadır (`daily_run_v1`); normal koşuyu ezmez.
- Gün, cihazın yerel tarihine göre değişir (yerel gece yarısı).

### Günün sıralaması (mobil: Firebase)

- Uygulama, Firebase'e REST üzerinden bağlanır (yerel eklenti ve `google-services.json` gerekmez):
  anonim giriş (Identity Toolkit) + Firestore'da `daily/<tarih>/scores/<uid>` belgesi.
- Sonuç her değiştiğinde gönderilir; çevrimdışıyken sessizce atlanır, bir sonraki değişiklikte
  tekrar gönderilir. Oyuncu adı **Ayarlar → Oyuncu adı**'ndan belirlenir (boşsa "Bir oyuncu").
- Kurulum: Firebase konsolunda proje aç → Authentication'da **Anonim** girişi aç → Firestore
  veritabanı oluştur → Kurallar sekmesine `firebase/firestore.rules` içeriğini yapıştır →
  Proje ayarlarından **Proje kimliği** ve **Web API anahtarı**nı `lib/data/online_config.dart`
  içine yaz (veya `--dart-define=FIREBASE_PROJECT_ID=... --dart-define=FIREBASE_API_KEY=...`).
  Bu değerler gizli değildir; erişimi kurallar belirler.
- İki değer de boşken sıralama kapalıdır ("Çevrimiçi sıralama bu sürümde kapalı").
- Tarayıcı sürümü (claude.ai sayfası) sayfanın paylaşılan veritabanını kullanır.

## Reklamlar (AdMob)

- Android/iOS'ta **her boss yenildikten sonra**, Bozdurma'da "Topla"ya basınca tam ekran geçiş
  reklamı gösterilir (tur sırasında asla). Hazır reklam yoksa ya da internet yoksa oyun beklemeden
  devam eder; reklam sırasında müzik durur.
- İlk açılışta, yasanın gerektirdiği yerlerde (AB, Birleşik Krallık…) Google'ın izin formu (UMP)
  çıkar; bu bölgelerde Ayarlar'da **Reklam gizlilik seçenekleri** de görünür.
- Şu an Google'ın **test kimlikleri** kullanılıyor (her reklamda "Test Ad" yazar, gelir getirmez).
  Gerçek kimliklere geçmek için: `android/app/src/main/AndroidManifest.xml` içindeki
  `com.google.android.gms.ads.APPLICATION_ID` (ve iOS'ta `Info.plist` → `GADApplicationIdentifier`)
  ile `lib/data/ads_config.dart` içindeki reklam birimi (veya
  `--dart-define=ADMOB_INTERSTITIAL_ID=...`).
- Web ve masaüstü sürümlerinde reklam yoktur (`NoMonetizationService`).

## Kural kararları (spec'te belirsiz olanlar)

- **Alaca Seri** tam 4 taştır: "hepsi farklı renk" + 4 renk ⇒ en fazla 4.
- **Gösterge** taşı o tur desteden çıkarılır; sahte okey gösterge olamaz (ilk gerçek taş seçilir).
- **Okey (joker)** değerlendiricide en yüksek skoru verecek sayıya/renge atanır ve atanan sayının değeri kadar puan verir (ör. 12-13-okey → okey = 1 → 15).
- **Seri sınırı:** 12-13-1 geçerli, 13-1-2 geçersiz; 1 hem başta (1-2-3) hem sonda (12-13-1) olabilir.
- **El seçimi** yalnızca taban skora göre yapılır (`(el puanı + taş değerleri) × el çarpanı`); Kut'lar seçimi etkilemez, böylece önizleme ile oynanan el her zaman aynıdır. Eşitlikte güçlü el türü seçilir.
- **Etkiler sırayla uygulanır:** +Çarpan ve ×Çarpan tetiklenme sırasına göre karışık uygulanır; Kut sıralaması bu yüzden anlamlıdır.
- **Taşa bağlı Kut'lar** ("her Kırmızı taş sayıldığında") 4. adımda değil, taşın kendi tetiklenmesi içinde çalışır (retrigger'lar bu efektleri de tekrarlar).
- **Kristal** kırılma zarı el başına bir kez atılır; önizlemede asla kırılmaz.
- **Kızıl Tamga** elde tutulan Demir taşın efektini de iki kez tetikler.
- **Gök Taşı** renk kontrollerinde her renge uyar (Umay Ana, Tepegöz vb.).
- **Tepegöz:** her El için rastgele bir renk seçilir (seed'li); yalnızca o renk sayılır.
- **Şahmeran:** seri içeren ellerin final skoru ×0.5.
- **Erlik'in Pazarlığı:** El hakkı en az 1'e düşebilir.
- **Gök Börü:** Grup-4 oynandığı elde büyüme önce olur, o el zaten artmış çarpanla sayılır.
- **Hedef eğrisi:** Kat başına ~1.75×; bu yüzden Kat N+1 Küçük Sınav, Kat N Boss'undan düşük olabilir (spec'teki 1.6–1.9× aralığının doğal sonucu).
- Sıralamada **1**, 13'ün sağına konur (15 puan değeri ve 12-13-1 serileri için).
- **Renk Tılsımı**'nın rengi eşya oluşurken belirlenir (renk seçici yerine), adı/açıklaması rengi söyler.
- **Destan Kesesi**'nden seçilen Destan hemen uygulanır (yuva gerektirmez). Destan eşyası her an kullanılabilir.
- **Kam Tılsımı** ve Destan masa dışında da kullanılabilir; taş isteyen Tılsımlar yalnızca turda.
- **Zümrüdüanka** kurtarınca tur kazanılmış sayılır (normal ödül), Kut yok olur.
- **Mor Tamga** / **Gök Tamga** eşya yaratır ancak eşya yuvası boşsa.
- **Atlama etiketi**: Kese etiketleri kese hemen açılır; seçmeden geçilebilir.
- **Kut satışı** tur dışında yapılır (masada Kut yalnızca sıralanır).
