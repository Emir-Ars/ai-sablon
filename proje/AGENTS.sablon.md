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
| Günlük | `GUNLUK.md` | Git | Oturum kayıtları; en yeni sonda. |
| Devir notu | `DEVAM.md` | Git dışı | "Şu an" durumu; her seferinde baştan yazılır. |
| Teknik belge | `docs/teknik.md` | Git | Kodun işleyişi. Yoksa kendiliğinden oluşturma; gerekirse kullanıcıya sor. |
| Araştırma | `docs/arastirma/` | Git | Proje başında toplanan araştırma ve kaynak notları. Klasör ilk dosyayla oluşur. |
| Durum betiği | `.ai/durum.ps1` | Git | Oturum başı durum ve devir notu denetimi (salt okunur). |

## Proje özeti

{{AMAC}}

## Oturum başında

Claude Code bu dosyayı, `PLAN.md` ve `DEVAM.md`'yi yerel `CLAUDE.md` üzerinden
kendiliğinden yükler. Codex `@` ile içe aktarma yapmaz: `PLAN.md` ve `DEVAM.md`'yi
kendin oku. Sonra `git status` ve `git log --oneline -5`. `/basla` (Codex'te
`$basla`) bu adımları yapar. Oturum başı durum çıktısında `UYARI` satırı varsa
ilk cevabında kullanıcıya söyle.

## Kod ve kontrol

- Testler: `{{TEST_KOMUTU}}`
- Biçim denetimi: `{{BICIM_KOMUTU}}`
- Kodlu bir adım, testi yazılıp geçmeden `PLAN.md`'de "Bitti" olmaz; testin dosyası
  adımın Test sütununa yazılır. Testler kodun modülüne göre ayrılır, adıma göre değil.
- Her adımda **bütün** testler çalışır, yalnız yeni test değil. Önceki bir aşamanın
  testi kırılırsa adım bitmiş sayılmaz; testi değiştirerek geçirme, nedenini bul.
- Commit mesajı adım numarasıyla başlar (ör. "1.1: app klasörü ve ilk test").

## Aşamalar ve bağımlılık

Amaç: sonraki aşamanın işi, biten aşamanın kodunu bozmasın.

- **Biten aşamanın kodu donmuştur.** Değiştirmek gerekirse (hata, zorunlu uyum) önce
  kullanıcıya sor. Sade dille sor: ne oldu, neyi etkiler, ne öneriyorsun; kullanıcının
  "evet" ya da "hayır" demesi yetsin, teknik ayrıntı bilmesi gerekmesin. Onay gelmeden
  değiştirme.
- Yeni aşama önceki aşamanın kodunu yalnız dışa açık fonksiyonları ve sınıfları
  üzerinden kullanır; iç ayrıntılarına (alt çizgili adlar, iç değişkenler) uzanmaz.
- Yeni işin kodu mümkünse yeni modüle yazılır; eski modüle ekleme gerekirse söyle.
- Dışa açık bir fonksiyonun imzası (ad, parametreler, dönüş) değişecekse önce onu
  çağıran her yeri ara ve listele, kullanıcıya söyle; mümkünse eskisini bozmadan
  genişlet (yeni parametre varsayılanlı olsun).
- Aşama kapanışı: bütün testler geçer, `PLAN.md`'de aşama "Bitti" olur ve Etiket
  sütunu doldurulur; kullanıcıya commit ve `git tag asama-N` önerilir (onayla).
  Biten aşamadan beri ne değiştiği: `git diff --stat asama-N`.

## Projeye özel kısıtlar ve canlı işler

{{KISITLAR}}

## Git (projeye özel)

Genel Git kuralları geçerlidir. Bu projede ek olarak:

- `DEVAM.md`, `CLAUDE.md`, `CLAUDE.local.md` ve `.claude/settings.local.json`
  commit edilmez (`.gitignore`'dadır).

<!-- EKLER -->

<!-- ai-sablon: {{SABLON_SURUM}} {{TARIH}} -->
