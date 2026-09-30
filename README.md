# ai-sablon

Claude Code ve Codex'i dönüşümlü kullanırken bilgi kaybolmasın diye kurulan çalışma düzeninin
şablonu: kişisel kurallar, belge şablonları, kısayollar (skill) ve betikler.

> **Durum:** kullanıma hazır. Kurulum yapıldı, `/yeni-proje` bir deneme projesinde çalıştı.
> Git'i (git init, commit, push) kullanıcı yönetir; şablon Git'e dokunmaz.

## Ne işe yarar

- Kişisel kurallar (Türkçe, adım adım, `git add .` yasağı, yapay zekâ imzası yok…) **bir kez**
  yazılır ve her projede geçerli olur.
- Yeni projede belge düzeni (kurallar, plan, kararlar, günlük, devir notu) tek komutla kurulur.
- Araç değişiminde (Claude ↔ Codex) devir notu ve durum denetimi kısayollarla yapılır.

## Üç yer

1. **Bu depo** (`Desktop\ai-sablon`): ana kopya. Geliştirme yalnız burada yapılır.
2. **Genel klasörler** (`C:\Users\Emir\.claude`, `C:\Users\Emir\.codex`): `kur.ps1` kişisel
   kuralları ve kısayolları buraya kopyalar. Araçlar bu dosyaları her projede okur.
3. **Her yeni proje:** klasörde `/yeni-proje` (Codex'te `$yeni-proje`).

## Yapı

```
ai-sablon\
├─ README.md               bu dosya
├─ AGENTS.md               bu depoda çalışan araca talimat (.sablon dosyaları talimat değildir)
├─ ARAC_GECISI.md          Claude ↔ Codex geçiş rehberi (kullanıcı için tek kopya)
├─ .gitignore              yedek dosyaları ve yerel ayar
├─ genel\
│  └─ KURALLAR.md          kişisel kuralların TEK kaynağı
├─ proje\                  çekirdek proje şablonu (adlar hedefte dönüşür)
│  ├─ AGENTS.sablon.md
│  ├─ CLAUDE.sablon.md
│  ├─ PLAN.sablon.md
│  ├─ KARARLAR.sablon.md
│  ├─ GUNLUK.sablon.md
│  ├─ DEVAM.sablon.md
│  ├─ gitignore.sablon
│  └─ _claude\
│     └─ settings.sablon.json
├─ ekler\                  isteğe bağlı paketler
│  └─ python-windows\
│     ├─ EK.md
│     ├─ AGENTS.ek.md
│     ├─ izinler.ek.json
│     └─ gitignore.ek
├─ skills\                 kısayollar (Claude ve Codex için aynı dosya)
│  ├─ basla\
│  │  └─ SKILL.md
│  ├─ devir\
│  │  └─ SKILL.md
│  ├─ karar\
│  │  └─ SKILL.md
│  └─ yeni-proje\
│     ├─ SKILL.md
│     ├─ references\
│     │  └─ sorular.md
│     └─ agents\
│        └─ openai.yaml
└─ scripts\
   ├─ kur.ps1
   ├─ durum.ps1
   └─ yeni-proje.ps1
```

`.sablon` soneki ve `_claude` klasörü, şablon deposunda çalışırken aracın bu dosyaları talimat
ya da ayar sanmaması içindir. `yeni-proje.ps1` hedefe kopyalarken dönüştürür: `.sablon` silinir,
`_claude` → `.claude`, `gitignore.sablon` → `.gitignore`, `scripts\durum.ps1` → `.ai\durum.ps1`.

## Kurulum (bilgisayara bir kez)

`scripts\kur.ps1` bu bilgisayarın genel klasörlerine yazar; **kullanıcı çalıştırır**.

1. Önce kuru çalışma (hiçbir şey yazmaz):

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kur.ps1 -Kontrol
   ```

   Her hedef için durum yazar: YENİ, BOŞ (0 bayt), AYNI, FARKLI, YABANCI (ai-sablon işareti
   yok, atlanır). `settings.json` için BOZUK çıkarsa dosya geçerli JSON değildir ve dokunulmaz.
2. Sonra gerçek kurulum:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\kur.ps1
   ```

   Ne yazar:
   - `genel\KURALLAR.md` → `~\.claude\CLAUDE.md` ve `~\.codex\AGENTS.md`.
   - Dört skill → `~\.claude\skills\<ad>` ve `~\.agents\skills\<ad>`.
   - `~\.claude\settings.json` içine yalnız `attribution` (commit ve PR imzası kapalı) eklenir;
     diğer anahtarlar korunur, ama dosya yeniden biçimlenir.
   - Değişecek ya da yabancı dosyalar önce yedeklenir: dosyalar yanına `.yedek-<tarih>`,
     skill klasörleri `~\.ai-sablon-yedek\<tarih>\claude` ya da `codex` altına.
   - Dokunulmaz: `skills\synced`, `skills\.trash`, `.codex\skills\.system`.
3. Claude Code'da yeni bir oturum aç; Codex'i yeniden başlat.

Seçenekler: `-CodexSkillKlasoru <yol>` Codex skill klasörünü değiştirir (Codex masaüstü
uygulaması `~\.agents\skills` yolunu görmezse `$HOME\.codex\skills` ile yeniden kur; iki yere
birden kurma, skill'ler çift listelenir). `-Zorla` ai-sablon işareti olmayan dosyaların da
yedeklenip ezilmesine izin verir.

## Günlük kullanım

| Ne zaman | Claude | Codex |
|---|---|---|
| Oturum başında | `/basla` | `$basla` |
| Oturumu bitirirken ya da araç değiştirirken | `/devir` | `$devir` |
| Bir karar verdiğinde | `/karar metin` | `$karar metin` |
| Yeni projede, bir kez | `/yeni-proje` | `$yeni-proje` |

`/yeni-proje` yalnız elle çağrılır. Adım adım geçiş rehberi ve skill görünmezse yedek mesajlar:
[ARAC_GECISI.md](ARAC_GECISI.md).

## Yeni proje kurma

1. Yeni (ya da boş) bir klasör aç ve o klasörde Claude Code ya da Codex'i başlat.
2. `/yeni-proje` yaz. Araç hedefi onaylatır, envanter çıkarır, soruları tek mesajda sorar (ad,
   amaç, ekler, test ve biçim komutları, kısıtlar, ilk adım), özet gösterip onay
   ister, sonra `yeni-proje.ps1` ile dosyaları kopyalar ve kalan alanları doldurur.
3. Şablon deposunun içi, ev klasörü, Masaüstü kökü ve Staj'a kurulum yapılmaz.
4. Yeni oturum aç, güven penceresini kabul et; Codex'te `$basla`.

Betiği doğrudan da çalıştırabilirsin (yer tutucuları doldurmaz, onu araç yapar):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <ai-sablon>\scripts\yeni-proje.ps1 -Hedef . -Ekler python-windows -ProjeAdi "Ad" -Arac Claude
```

`-Kontrol` yalnız envanter çıkarır. Var olan hiçbir dosyanın üzerine yazılmaz; `.gitignore`
satırları ve ek bölümleri yalnız eklenir.

## Proje içindeki belge düzeni

| Rol | Dosya | Git | Sınır |
|---|---|---|---|
| Kurallar | `AGENTS.md` | Git | Yalnız projeye özel; kişisel kurallar genel dosyada. |
| Plan | `PLAN.md` | Git | Kısa (~100 satır); biten aşama tek satır. |
| Kararlar | `KARARLAR.md` | Git | Yalnız eklenir (`K-001`, `K-002`…). |
| Günlük | `GUNLUK.md` | Git | Yalnız eklenir; en yeni sonda. |
| Devir notu | `DEVAM.md` | Git dışı | "Şu an"; her seferinde baştan yazılır, en çok ~60 satır. |
| Durum betiği | `.ai/durum.ps1` | Git | Salt okunur; devir notunun güncelliğini denetler. |

Claude Code, `AGENTS.md`, `PLAN.md` ve `DEVAM.md`'yi yerel `CLAUDE.md` ile yükler. Codex `@`
içe aktarma yapmadığı için bunları talimatla (`$basla`) okur.

**Oturum başı durum denetimi.** Claude Code'da projenin `.claude/settings.json` dosyası
`.ai/durum.ps1 -Kanca` komutunu her oturum başında çalıştırır (proje ayarları çalışma alanı
güven onayından sonra geçerli olur). Codex'te aynı denetim `$basla` içinde çalışır. Uyarılar:

| Kod | Anlamı |
|---|---|
| U1 | Devir notu yok |
| U2 | Devir notunda "Son güncelleme" tarihi okunamadı |
| U3 | Son commit devir notundan yeni |
| U4 | Commit edilmemiş bir dosya devir notundan yeni |
| U5 | Devir notu 60 satırdan uzun |
| U6 | Devir notunun tarihi gelecekte |

Betiği elle de çalıştırabilirsin (herhangi bir klasör için, salt okunur):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\durum.ps1 -Proje <klasör>
```

## Kural değiştirme

Kişisel kuralların tek kaynağı `genel\KURALLAR.md`'dir.

1. `genel\KURALLAR.md`'yi düzenle (araç kalıcı bir kural önerirse oraya ekler).
2. `scripts\kur.ps1 -Kontrol` çalıştır: değişen dosyalar FARKLI görünür.
3. `scripts\kur.ps1` çalıştır.

`~\.claude\CLAUDE.md` ya da `~\.codex\AGENTS.md`'yi elle düzenleme: sonraki `kur.ps1`
yedekleyip ezer. Projeye özel kural ilgili projenin `AGENTS.md`'sine yazılır.

## Skill değiştirme

`skills\<ad>\SKILL.md`'yi düzenle, sonra `kur.ps1`'i yeniden çalıştır. Kurallar (aynı dosya
Claude ve Codex'te çalışsın):

- Frontmatter'da yalnız `name` (klasör adıyla aynı, `a-z0-9-`), `description` ve `metadata`.
  Claude'a özgü öğe (`$ARGUMENTS`, `` !`komut` ``) yok.
- Kök yol `__SABLON_KOKU__`, sürüm `__SABLON_SURUM__` yazılır; `kur.ps1` doldurur.
- Belge adları sabit yazılmaz; projenin Belge haritasından okunur.
- Gövde 150 satırdan kısa; sonda "Bitti ölçütü" ve "Yapma" bölümleri.
- Elle çağrılacak skill'e `metadata.yalniz-elle: "evet"` yaz: `kur.ps1` Claude kopyasına
  `disable-model-invocation: true` ekler, Codex için `agents\openai.yaml` kullanılır.

## Yeni ek ekleme

`ekler\<ad>\` klasörü aç (`<ad>` yalnız `a-z0-9-`). Dosyalar isteğe bağlıdır:

- `EK.md`: ekin tanımı ve `yeni-proje`'nin soracağı ek sorular (hedefe kopyalanmaz).
- `AGENTS.ek.md`: hedef `AGENTS.md`'de `<!-- EKLER -->` işaretinin önüne eklenir.
- `izinler.ek.json`: `permissions.allow/ask/deny` girdileri `.claude/settings.json`'a eklenir.
- `gitignore.ek`: satırlar `.gitignore`'a tekrarsız eklenir.

`yeni-proje` ek listesini bu klasörden okur; başka yere kayıt gerekmez.

## Bilinen sınırlar

- Oturum başı durum çıktısını kullanıcı görmez; uyarının ilk cevapta söylenmesi aracın kurala
  uymasına bağlıdır. Söylemezse `/basla` yaz.
- Proje izinleri çalışma alanı güven onayından önce çalışmaz. Komut metni izin kuralıyla birebir
  eşleşmezse izin yine sorulur.
- Codex'in skill klasör yolu sürüme göre değişebilir (bkz. Kurulum, `-CodexSkillKlasoru`).
- Eski düzenli bir projeye (kendi plan dosyası olan) ekleme yapılırsa `yeni-proje.ps1` yine de
  boş bir `PLAN.md` oluşturur; gerekmiyorsa silinir.
- `kur.ps1` sonrası `~\.claude\settings.json` yeniden biçimlenir (yedeği alınır).

## Bu depoda çalışma

Bu depoda çalışan araç için kurallar [AGENTS.md](AGENTS.md)'dedir: adım adım ilerle, her
adımdan sonra onay al, dosyaları tek tek ekle, commit ve push ayrı onaydır.
