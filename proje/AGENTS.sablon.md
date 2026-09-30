# {{PROJE_ADI}}: çalışma talimatları (Claude Code ve Codex için ortak)

Kişisel çalışma kuralları genel dosyalardadır (`~/.claude/CLAUDE.md`,
`~/.codex/AGENTS.md`); burada tekrarlanmaz. Bu dosya yalnız bu projeye özeldir.
Daha özel olduğu için çelişkide bu dosyanın kuralı geçerlidir; çelişkiyi
kullanıcıya söyle. Kalıcı bilgi araçların hafızasında değil, aşağıdaki
dosyalarda durur.

## Belge haritası

Skill'ler ve `.ai/durum.ps1` dosya adlarını bu tablodan okur; adı değiştirirsen
tabloyu da güncelle.

| Rol | Dosya | Git | Kullanım |
|---|---|---|---|
| Kurallar | `AGENTS.md` | Git | Bu dosya; projeye özel kalıcı kurallar. |
| Plan | `PLAN.md` | Git | Amaç, aşamalar, şu anki adımlar, açık kararlar, bilinen sınırlar. Kısa tutulur. |
| Kararlar | `KARARLAR.md` | Git | Kararların gerekçeli kaydı; yalnız eklenir. |
| Günlük | `GUNLUK.md` | Git | Biten adım ve kararların kısa kaydı; en yeni sonda. Her oturumda değil. |
| Devir notu | `DEVAM.md` | Git dışı | "Şu an" durumu; her seferinde baştan yazılır. |
| Teknik belge | `docs/teknik.md` | Git | Kodun işleyişi. Yoksa kendiliğinden oluşturma; gerekirse kullanıcıya sor. |
| Araştırma | `docs/arastirma/` | Git | `genel/`: projenin başındaki araştırma; `asama-N/`: N. ana başlık için araştırma. Ayrıntı: "Planlama ve araştırma". |
| Durum betiği | `.ai/durum.ps1` | Git | Oturum başı durum ve devir notu denetimi (salt okunur). |

## Proje özeti

İlk fikir (araştırmadan önce): {{AMAC}}

Amaç, kapsam ve teknoloji planlamadan sonra buraya yazılır.

## Planlama ve araştırma

Araştırma belgeleri `docs/arastirma/` altındadır: `genel/` projenin başındaki
araştırma, `asama-N/` N. ana başlık için yapılan araştırma. Belge tek bir adıma
özelse dosya adı adım numarasıyla başlar (ör. `asama-2/2.4-odeme.md`).

- **Araştırma eklemek:** Kullanıcı "araştırma ekleyeceğim" derse hangi aşama için
  olduğunu `PLAN.md`'den bul (şu an süren aşama; belli değilse sor). Aşama 0'daysa
  `genel/`, değilse `asama-N/`. Klasör yoksa aç ve kullanıcıya tam yolunu söyle.
  Kullanıcı bir dosyanın yerini verirse dosyayı oraya kendin kopyala (adıma özelse
  adın başına adım numarasını ekle); metin yapıştırırsa `.md` olarak kaydet. Sonra
  belgeyi oku ve kısa özet ver.
Planlama bir rehberdir, prosedür değil. Amaç planın geç değil erken değişmesi. Bir
adımı atlarsan ya da farklı yol izlersen bunu gerekçesiyle tek satırda söyle.

**İlkeler**
- Araştırma belgeleri girdidir, emir değil: eksik, eskimiş ya da hatalı olabilir.
  Sorgula; daha iyi bir yol görürsen öner, belgeyle çelişiyorsa açıkça "çelişki" de.
- Kaynağı görünür tut: her gereksinim ve kararın yanına `[B: dosya#bölüm]` belgeden,
  `[Ö]` senin önerin, `[V]` varsayım yaz.
- Yalnız cevabı planı değiştirecek soruları sor (mimari, veri modeli, dış arayüz);
  gerisini makul varsayımla `[V]` olarak yaz ve ilerle. Soruları tek turda topla.
- En riskli varsayımı en erken sına: ilk aşama, uçtan uca en ince çalışan yol olsun
  ve yüksek riskli `[V]`'leri gerçek kodla denesin. Bunu iskelette sınayamıyorsan
  küçük, süresi sınırlı, atılacak bir deneme öner.
- Yakını ayrıntılı, uzağı kaba planla: yalnız üzerinde çalışılan ana başlık adımlara
  bölünür; uzak başlık = amaç + "bitti" + açık riskler.
- "Bitti" çalıştırılabilir olsun: bir komut ya da test ve beklenen sonuç.
- Yalnız aşama sınırını geçen arayüzleri tanımla; ileride lazım olur diye soyutlama kurma.
- Karar kaydını yalnız geri dönüşü pahalı kararlara yaz (veri modeli, kütüphane,
  dosya biçimi, dış servis).

**Kontrol noktaları** (kullanıcı onayı beklenir)
1. **Anlama:** `genel/` belgelerinden amaç, kapsam dışı, etiketli gereksinimler,
   ölçülebilir başarı ölçütleri, "çelişki / eskime" listesi ve sorular. Hiçbir
   dosyaya yazma.
2. **Plan taslağı:** ana başlıklar (ad, amaç, "bitti", bağımlılık), önemli kararlar ve
   varsayım tablosu. Onaylanınca: ana başlıklar, başarı ölçütleri ve varsayımlar
   `PLAN.md`'ye (Aşama 0 "Bitti" olur); amaç ve kapsam `PLAN.md`'ye ve yukarıdaki
   Proje özetine; kısıtlar aşağıdaki bölüme; kararlar `KARARLAR.md`'ye. Kullanıcıya
   planı yeni bir oturumda ya da Codex'te eleştirtmeyi öner (isteğe bağlı): "Bu proje
   başarısız oldu; en olası 5 teknik neden ne? Her gereksinim bir başlığa bağlı mı?"
   Aynı sohbette kendi planını eleştirme; bu yeni bilgi getirmez.
3. **Her ana başlığın başında** (ör. "2. başlığı planla"): varsayımları güncelle
   (doğrulandı / çürüdü), "Sürprizler"i oku, `genel/` ve `asama-2/` klasörlerini oku
   (başka aşamanın araştırmasını okuma), başlığı adımlara böl (2.1, 2.2…), etkilenen
   sonraki başlıkları söyle. Onaylanınca `PLAN.md` adım tablosuna yaz.

**Değişiklik**
- Uygulama plandan sapıyorsa dur, sessizce doğaçlama yapma: `PLAN.md` değişikliğini ve
  etkisini öner. Beklenmedik bir şey görürsen `PLAN.md` "Sürprizler"e bir satır yaz.
- Çürüyen varsayım ya da donmuş arayüz değişikliği `KARARLAR.md`'ye yeni kayıt olur.

**Ölçek:** Tek cümleyle anlatılabilen iş için plan yapma, doğrudan yap. Küçük
projede karar tablosu ve ayrı deneme gerekmez.
- **Ek:** Teknoloji belli olunca uygun ek varsa (`{{SABLON_KOKU}}\ekler` altındaki
  klasörler; ör. Python için `python-windows`) kurmayı öner ve ne eklediğini söyle.
  Onaylanırsa ekin `EK.md` dosyasındaki soruları sor, sonra şunu çalıştır:
  `powershell -NoProfile -ExecutionPolicy Bypass -File "{{SABLON_KOKU}}\scripts\yeni-proje.ps1" -Hedef . -Ekler <ek adı>`
  Betiğin raporladığı yer tutucuları doldur ve "Kod ve kontrol" bölümündeki test ve
  biçim satırlarını ekin komutlarına yönlendir.
- Plan modunda hazırlanan plan araç klasöründe kalır ve diğer araç göremez;
  onaylanınca mutlaka yukarıdaki dosyalara yazılır.

## Oturum başında

Claude Code bu dosyayı, `PLAN.md` ve `DEVAM.md`'yi yerel `CLAUDE.md` üzerinden
kendiliğinden yükler. Codex `@` ile içe aktarma yapmaz: `PLAN.md` ve `DEVAM.md`'yi
kendin oku. Sonra `git status` ve `git log --oneline -5`. `/basla` (Codex'te
`$basla`) bu adımları yapar. Oturum başı durum çıktısında `UYARI` satırı varsa
ilk cevabında kullanıcıya söyle.

## Kod ve kontrol

- Testler: henüz belirlenmedi (teknoloji seçilince yazılır).
- Biçim denetimi: henüz belirlenmedi (teknoloji seçilince yazılır).
- Kodlu bir adım, testi yazılıp geçmeden `PLAN.md`'de "Bitti" olmaz; testin dosyası
  adımın Test sütununa yazılır. Testler kodun modülüne göre ayrılır, adıma göre değil.
- Her adımda **bütün** testler çalışır, yalnız yeni test değil. Önceki bir aşamanın
  testi kırılırsa adım bitmiş sayılmaz; testi değiştirerek geçirme, nedenini bul.
- Commit mesajı adım numarasıyla başlar (ör. "1.1: app klasörü ve ilk test").

## Aşamalar ve bağımlılık

Amaç: sonraki aşamanın işi, biten aşamanın kodunu bozmasın.

- **Donmuş olan, biten aşamanın dışa açık arayüzü ve testleridir.** Arayüz: başka
  modüllerin kullandığı fonksiyon ve sınıfların adı, parametreleri, dönüşü. Testler:
  o aşamanın testleri; testi geçirmek için değiştirilmez.
- Biten aşamanın **içinde** hata düzeltme ya da iç düzenleme (refactor) serbesttir,
  yeter ki arayüz aynı kalsın ve bütün testler yeşil olsun. Yaptıktan sonra
  kullanıcıya sade dille bildir (ne değişti, neden); onay beklemen gerekmez.
- **Arayüz değişecekse** önce kullanıcıya sor. Sade dille sor: ne oldu, neyi etkiler,
  ne öneriyorsun; kullanıcının "evet" ya da "hayır" demesi yetsin, teknik ayrıntı
  bilmesi gerekmesin. Önce onu çağıran her yeri ara; mümkünse eskisini bozmadan
  genişlet (yeni parametre varsayılanlı olsun). Onaylanırsa Kararlar'a yaz.
- Yeni aşama önceki aşamanın kodunu yalnız dışa açık fonksiyonları ve sınıfları
  üzerinden kullanır; iç ayrıntılarına (alt çizgili adlar, iç değişkenler) uzanmaz.
- Yeni işin kodu mümkünse yeni modüle yazılır.
- Aşama kapanışı: bütün testler geçer, `PLAN.md`'de aşama "Bitti" olur ve Etiket
  sütunu doldurulur; kullanıcıya commit ve `git tag asama-N` önerilir (onayla).
  Biten aşamadan beri ne değiştiği: `git diff --stat asama-N`.

## Projeye özel kısıtlar ve canlı işler

Henüz belirlenmedi; planlamada yazılır (canlı işler, gerçek veri, gizli bilgi,
dokunulmayacak dosyalar).

## Git (projeye özel)

Genel Git kuralları geçerlidir. Bu projede ek olarak:

- `DEVAM.md`, `CLAUDE.md`, `CLAUDE.local.md` ve `.claude/settings.local.json`
  commit edilmez (`.gitignore`'dadır).
- `.githooks/commit-msg` kancası, mesajında yapay zekâ imzası olan commit'i reddeder.
  Etkin olması için kullanıcı Git'i kurduktan sonra bir kez
  `git config core.hooksPath .githooks` çalıştırır. `--no-verify` ile kancayı atlama.

<!-- EKLER -->

<!-- ai-sablon: {{SABLON_SURUM}} {{TARIH}} -->
