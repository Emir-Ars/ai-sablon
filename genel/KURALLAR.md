# Kişisel çalışma kuralları (her projede geçerli)

Kullanıcı: Emir-Ars, projeyi öğrenerek geliştiren bir stajyer (Windows 11,
PowerShell 5.1). Bu dosya `ai-sablon` deposundaki `genel\KURALLAR.md` dosyasından
`kur.ps1` ile kopyalanır. Elle düzenleme: değişikliği önce şablon deposunda yap,
sonra `kur.ps1`'i yeniden çalıştırmasını kullanıcıdan iste.

## Öncelik

- Projenin `AGENTS.md`'si bu dosyadan daha özeldir. Çelişki olursa proje kuralı
  geçerlidir; çelişkiyi kullanıcıya bir cümleyle söyle.
- Bu dosya yalnız kişisel kuralları tutar. Projeye özel kurallar (test komutu, canlı
  işler, veri, mimari sözleşmeler) projenin `AGENTS.md`'sine yazılır.

## İletişim

- Bütün mesajlar Türkçe yazılır, kısa durum satırları dahil. Terimleri açıkla.
- Her değişiklikte anlat: ne yapıldı, neden, akışa nasıl bağlanıyor, nasıl
  doğrulandı, açık sınırlar neler.
- Kod tanımlayıcıları İngilizce; yorumlar ve kullanıcıya dönük mesajlar Türkçe.
  Yorum yalnız "neden böyle?" sorusunu yanıtlar.
- Bilgi uydurma: görmediğin veriyi, komut çıktısını veya sonucu yazma. Bilmiyorsan
  bilmediğini söyle.

## Tempo

- Önce plan, sonra kullanıcının onayı, sonra kod. Kullanıcı plan ya da açıklama
  istediğinde kod yazma.
- Tek adım at, sonra dur. Hızlı ve toplu değişiklik kullanıcıyı kaybettirir.
- Yeni mimari seçimlerini kullanıcıyla netleştir. Kullanıcının güncel kararı bir
  belgeyle çelişirse çelişkiyi söyle ve belgeyi karara uydur.
- Planlanan, uygulanmış ve karar bekleyen işleri birbirine karıştırma.
- Gereksiz dosya, iskelet veya kopya üretme; dosyaları sorumluluğa göre ayır.
- Yarım kalmış bir taslağı ya da yalnızca kurulmuş bir bağımlılığı tamamlanmış
  özellik sayma.

## Komutlar ve sonuçlar

- Kullanıcı yalnızca dış sistemlere (site, API, sunucu) giden canlı işleri ve gerçek
  veriyi ya da veritabanını değiştiren komutları kendi terminalinden çalıştırır. Sen
  komutu ve çıktıda neye bakılacağını ver; bunları arka planda yürütme. Testler,
  onaylı git commit ve dosya düzenleme bu kuralın dışındadır: bunları kullanıcıya
  bırakma, sen yap.
- Gizli bilgi (şifre, anahtar, token) repoya, belgeye, komut satırına veya mesaja
  yazılmaz.
- "Testler geçti" ile "canlıda doğru çalışıyor" aynı şey değildir. Testler kuralları
  sınar; gerçek sonuç için canlı kanıt gerekir.
- Test çıktısında `skipped` sayısı 0 değilse "hepsi geçti" deme.

## Proje hafızası

- Durum, karar ve devir bilgisi yalnız repo dosyalarına yazılır (projenin
  `AGENTS.md`'sindeki Belge haritası). Aracın kendi hafızasına proje durumu
  yazılmaz: diğer araç onu göremez ve eskir.
- Kullanıcı yeni bir kalıcı kural söylerse ("bundan sonra hep…"): kişisel ise
  `ai-sablon` deposundaki `genel\KURALLAR.md`'ye eklemeyi öner; projeye özel ise
  projenin `AGENTS.md`'sine yaz.

## Oturum akışı

- Başlarken (varsa): Plan, Devir notu, `git status`, `git log --oneline -5`.
  Dosya adları projenin `AGENTS.md`'sindeki Belge haritasından okunur.
- Oturum başında durum çıktısında `UYARI` satırı varsa **ilk cevabında kullanıcıya
  söyle**. Bu çıktıyı kullanıcı görmez, sen söylemezsen bilmez.
- Sonunda ya da araç değişmeden önce: Devir notunu baştan yaz; projede Günlük varsa
  ona kısa kayıt ekle.
- Kısayollar: `/basla`, `/devir`, `/karar`, `/yeni-proje`. Codex'te `$basla`,
  `$devir`, `$karar`, `$yeni-proje`.
- İki araç aynı anda çalıştırılmaz. Araca dönünce yeni sohbet açılır.
- Tarih ve saat kabuktan alınır: `Get-Date -Format 'yyyy-MM-dd HH:mm'`. Tahmin etme.

## Belgeleri güncel tutma

Kullanıcı istemeden, aynı oturumda güncelle. Güncellenen belgeyi mesajda bir
cümleyle söyle. Roller ve dosya adları projenin Belge haritasındadır.

| Ne olduğunda | Hangi belge |
|---|---|
| Kullanıcı karar verdi | Kararlar'a yeni kayıt; Plan'daki açık karar kapatılır |
| Plan adımı bitti | Plan'ın durum tabloları; README'deki sayılar |
| Kodun davranışı, komutu veya kuralı değişti | Teknik belge; gerekirse README |
| Yeni sınır veya hata görüldü | Plan'ın "Bilinen sınırlar" bölümü |
| Kalıcı proje kuralı söylendi | Projenin `AGENTS.md`'si |
| Oturum bitiyor ya da araç değişecek | Devir notu; Günlük varsa Günlük |

- Belgeler baştan yazılmaz: yeni bilgi ilgili yere eklenir, eskiyle çelişirse eskisi
  düzeltilir. Tek istisna Devir notudur; o her seferinde baştan yazılır.
- Belge haritası olmayan (eski düzenli) projede yeni dosya oluşturma; projenin
  `AGENTS.md`'sinde adı geçen dosyaları kullan.

## Git

- `git add .` ve `git add -A` yok. Dosyalar tek tek seçilir, kullanıcının
  değişiklikleri korunur.
- Sıra: test ve biçim denetimi, dosya listesi ve Türkçe commit mesajı, açık onay,
  commit. Push ayrı onaydır. Soru sormak onay değildir.
- Projede CI varsa push sonrası sonucu kontrol et.
- Yazar yalnız kullanıcıdır (Emir-Ars). Commit'e ve PR açıklamasına `Co-Authored-By`
  ya da herhangi bir yapay zekâ imzası (Claude, Codex…) eklenmez.
- Projenin `.gitignore`'unda listelenen yerel dosyalar (`DEVAM.md`, `CLAUDE.md` gibi)
  commit edilmez.
- `gh` kurulu değilse GitHub'da repo açma gibi web işlerini kullanıcı yapar.

## Windows

- Kabuk Windows PowerShell 5.1'dir: `&&` ve `||` yok. Komutları `;` ile ya da ayrı
  çağrılarla ver.
- Türkçe commit mesajı UTF-8 bir dosyaya yazılır ve `git commit -F <dosya>` ile
  verilir; here-string ile boru hattı mesajı bozar.
- `.ps1` dosyaları UTF-8 **BOM'lu**, md/json/yaml dosyaları BOM'suz kaydedilir;
  PowerShell 5.1 BOM'suz dosyada Türkçe karakteri bozar. Bir `.ps1` düzenlendikten
  sonra ilk 3 baytı (`239 187 191`) kontrol et.
- Terminalde Türkçe çıktı için `[Console]::OutputEncoding = [Text.Encoding]::UTF8`.
- `psql -c` sorgusunda Türkçe harf kullanma (kod sayfası 857/1254); küçük bir betik
  daha güvenlidir.

## Okuma

- Çok dosyalı tarama ya da arama gerekiyorsa (araç destekliyorsa) alt ajana yaptır;
  yalnız düzenleyeceğin dosyayı doğrudan oku.
