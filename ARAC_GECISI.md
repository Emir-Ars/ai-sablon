# Claude ↔ Codex geçişi: ne yapacağım?

Bir aracın kullanım limiti dolduğunda diğerine geçerken bilgi kaybolmasın diye izlenecek
adımlar. İki yönde de aynıdır: Claude → Codex ve Codex → Claude.

Kısayolları Claude'da `/` ile, Codex'te `$` ile yazarsın: `/basla` ve `$basla`, `/devir` ve
`$devir`, `/karar` ve `$karar`.

Bilgi araçların hafızasında değil, projenin dosyalarındadır. Yeni kurulan projelerde:
kurallar `AGENTS.md`'de, plan `PLAN.md`'de, kararlar `KARARLAR.md`'de, günlük `GUNLUK.md`'de,
yarım kalan iş `DEVAM.md`'dedir (yalnız `DEVAM.md` yereldir, Git'e girmez). Dosya adları
her projenin `AGENTS.md`'sindeki Belge haritasında yazar.

## 1. Geçmeden önce (çalışan araçta)

Şunu yaz:

```text
/devir
```

Codex'te `$devir`.

- Aracın cevabını sonuna kadar bekle. Dosya yazarken kapatma.
- `DEVAM.md`'yi aç ve en üstteki "Son güncelleme" tarih ve saatinin şimdiki zaman olduğunu
  kontrol et. Araç raporda da bu saati söyler.
- Mümkünse geçişi bir commit'ten hemen sonra yap. Yarım iş olsa da sorun değil: commit
  edilmemiş dosyalar devir notunda listelenir. `/devir` commit yapmaz; commit için sen onay
  verirsin.

## 2. Yeni araçta (yeni sohbetle)

Yeni bir sohbet aç ve şunu yaz:

```text
/basla
```

Codex'te `$basla`.

- Araç durumu okur, en çok 15 satırlık bir özet verir ve "Onayını bekliyorum" der.
- Özet doğruysa devam et. Yanlış ya da eksikse düzelt, sonra `/devir` yazıp düzeltmenin devir
  notuna girmesini sağla.
- Özette `UYARI` (ör. "devir notu eski") çıkmışsa araç bunu ilk satırda söylemeli. Claude'un
  oturum başı kancası uyarıyı yalnız araca gösterir, sen görmezsin; söylemediyse `/basla`
  yaz.

## 3. Limit birden biterse (araç devir notunu yazamadıysa)

Yeni araçta ilk mesaj:

```text
/basla devir notu yazılamadı
```

Codex'te `$basla devir notu yazılamadı`. Araç koddaki değişikliklerden neyin yapıldığını
çıkarıp devir notunu kendisi yeniden kurar. Dosyaya dokunmasını istemiyorsan
`/basla yalnız özetle` yaz.

## 4. Karar verdiğinde

```text
/karar Şunu seçtik, çünkü …
```

Codex'te `$karar …`. Araç kararı Kararlar'a gerekçesiyle yazar, Plan'daki açık kararı ve
devir notundaki bekleyeni düzeltir. Gerekçeyi söylemezsen bir kez sorar; uydurmaz.

## Unutma

- İki aracı **aynı anda** çalıştırma.
- Bir araca geri dönerken eski sohbeti sürdürme, **yeni sohbet** aç. Eski sohbet, diğer aracın
  sonradan yaptıklarını bilmez.
- Commit'ten önce dosya listesini ve mesajı görüp onay verirsin, push için ayrı onay
  verirsin. Commit'te yazar yalnız sensin; yapay zekâ imzası olmaz.
- Araç izin sorunca **tek seferlik "Yes"** seç, "don't ask again" seçme. Kalıcı izinler
  projenin ayar dosyasını şişirir.
- Kalıcı bir kural söylediysen ("bundan sonra hep şöyle yap"), aracın bunu doğru yere
  yazmasını iste: kişisel kural `ai-sablon`'daki `genel\KURALLAR.md`'ye (sonra `kur.ps1`
  yeniden çalıştırılır), projeye özel kural o projenin `AGENTS.md`'sine. Aracın kendi hafızası
  diğer araçta görünmez.
- Projeye özel uyarılar (zamanlanmış işler, canlı komutlar gibi) o projenin `AGENTS.md`'sinde
  yazar; araç onları okur.

## Kısayollar görünmezse

Önce şunları dene: Claude'da yeni bir oturum aç. Codex'i tamamen kapatıp yeniden başlat ve
yeni sohbette `$` yaz ya da `/skills` yaz. Sonra `ai-sablon` klasöründe
`powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kur.ps1 -Kontrol` çalıştır; skill
klasörleri YENİ görünüyorsa kurulum yapılmamıştır.

Yine de görünmezse aşağıdaki mesajları kopyala-yapıştır. Belge haritası olmayan (eski düzenli)
projelerde araç, `AGENTS.md`'de adı geçen dosyaları kullanır.

**Yeni araçta ilk mesaj** (`/basla` yerine):

```text
AGENTS.md'yi oku; oradaki Belge haritasında Plan ve Devir notu olarak gösterilen dosyaları da
oku (harita yoksa AGENTS.md'de adı geçen plan ve devir dosyalarını). git status ve
git log --oneline -5 çıktısına bak. Nerede kaldığımızı, commit edilmemiş işleri, bekleyen
kararları ve sıradaki adımı bana kısaca özetle; onayımı bekle.
```

**Geçmeden önce** (`/devir` yerine):

```text
Devir notunu güncelle: AGENTS.md'deki Belge haritasında Devir notu olarak gösterilen dosyayı
baştan yaz. Tarih ve saati Get-Date -Format 'yyyy-MM-dd HH:mm' ile al, tahmin etme. Biten işi
Günlük'e, kararı Kararlar'a taşı (dosyalar haritada varsa). Commit yapma; hangi belgeleri
güncellediğini söyle.
```

**Limit birden bittiyse** (`/basla devir notu yazılamadı` yerine):

```text
Önceki araç devir notunu yazamadan durdu; devir notu eski olabilir. AGENTS.md'yi ve Belge
haritasındaki Plan dosyasını oku, git status ve git diff ile commit edilmemiş değişiklikleri
incele, Belge haritasındaki Devir notunu güncelle, sonra nerede kaldığımızı özetle ve
onayımı bekle.
```

**Karar** (`/karar` yerine):

```text
Şu kararı Belge haritasındaki Kararlar dosyasına gerekçesiyle yaz (yalnız ekle, eski kaydın
yalnız Durum satırı değişir), Plan'daki açık kararı sil, devir notundaki bekleyeni düzelt;
commit yapma. Gerekçeyi ben söylemediysem sor, uydurma. Karar: …
```
