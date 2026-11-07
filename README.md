# Tengri'nin Taşları

Okey taşlarıyla oynanan, Türk mitolojisi temalı, deste kurmalı **roguelike bulmaca oyunu**.
Flutter (+ ileride Flame), Android öncelikli, dikey ekran.

> Durum: **Faz 1 — Çekirdek motor** tamamlandı (UI yok).

## Mimari

```
lib/
  core/            Saf Dart oyun mantığı (Flutter import'u YASAK, testle korunuyor)
    rng/           SeededRng (xoshiro128**), seed kodları, fork ile alt akışlar
    tiles/         Tile, RunDeck (106 taş), DrawPile, OkeyInfo (gösterge/okey/sahte okey)
    hands/         HandType, HandLevels, HandEvaluator (okey joker + Gök Taşı dahil)
    scoring/       ScoringEngine, ScoreEvent (animasyon akışı), Kut arayüzü
    round/         Round durum makinesi, RoundRules (boss kısıtları), rack sıralama
    sim/           AutoPlayer (açgözlü bot: simülasyon & denge)
  data/            Veri odaklı içerik
    balance.dart   TÜM denge sayıları (el tablosu, hedefler, ekonomi, Kut değerleri)
    kuts.dart      20 Kut (kut_behaviors.dart'taki parametrik davranışlardan)
    bosses.dart    8 Boss (RoundRules olarak)
  ui/              (Faz 2)
  services/        (Faz 5: kayıt, ses, haptik, lokalizasyon)
bin/
  simulate.dart    Konsolda tek tur oynatma (etkileşimli veya --auto)
  balance_sim.dart Bot ile toplu kazanma oranı tablosu
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
flutter test                                     # tüm unit testler
dart run bin/simulate.dart                       # etkileşimli tur (rastgele seed)
dart run bin/simulate.dart --seed TENGRI42 --auto
dart run bin/simulate.dart --kuts umay_ana,bozkurt --boss kara_kus
dart run bin/balance_sim.dart --rounds 40        # bot kazanma oranları
```

Konsol komutları: `p 0 3 5` oyna, `d 1 2` değiştir, `v 0 3 5` önizleme, `m 7 0` taşı taşı,
`s`/`c` sayıya/renge göre diz, `r 2` kapalı taşı aç, `q` çıkış.

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
