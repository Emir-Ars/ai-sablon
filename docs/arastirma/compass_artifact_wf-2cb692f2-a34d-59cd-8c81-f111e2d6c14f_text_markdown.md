# "ai-sablon" Bağımsız Değerlendirme: Güçlü İskelet, Zayıf Uygulama Katmanı

Şablon zekâyı ciddi biçimde kısıtlamıyor. Asıl zayıflığı başka yerde: kuralların çoğu yalnızca "rica" düzeyinde, gerçek koruma olarak sunulan izin listesi ise Windows'ta PowerShell aracı ve komut varyasyonlarıyla atlatılabiliyor. Ayrıca devir mekanizması (PLAN/DEVAM içe aktarma, SessionStart kancası) Codex tarafında hiç çalışmıyor.

## TL;DR
- **Zekâ:** ~140 satırlık kural dosyası, ölçülmüş eşiklerin (IFScale'de bozulma yüzlerce talimatta belirginleşiyor; Anthropic <200 satır öneriyor) altında kalıyor. Zarar veren şey kural sayısı değil, "her adımda dur" ile "donmuş kod" kurallarının katılığı. Bu ikisi token limitini daha hızlı tüketiyor ve gerekli refactor'ları engelliyor.
- **Teknik doğruluk:** Claude tarafında en riskli üç nokta şunlar: `attribution` biçimi (`false` kısayolu eski sürümlerde bütün settings dosyasının atlanmasına yol açıyor), yalnız `Bash(...)` yazılmış izin kuralları (PowerShell aracını kapsamıyor) ve `Read(./.env)`'nin dar kapsamı. Codex tarafında PLAN.md ve DEVAM.md otomatik yüklenmiyor, `/basla` slash komutu çalışmıyor (`$basla` gerekiyor) ve `durum.ps1` hiç çalışmıyor.
- **Karar:** Şablonu tek kişilik öğrenme projelerinde ve küçük web/Python projelerinde kullan. Önce üç şeyi değiştir: (1) gerçek korumayı Git kancalarına ve sandbox'a taşı, (2) "tek adım" kuralını "onaylanmış plan içinde kontrol noktasına kadar ilerle" biçimine çevir, (3) "donmuş kod" kuralını "donmuş arayüz ve testler" biçimine gevşet.

---

## 0. Önce güvenlik uyarıları

1. **İzin listesi bir güvenlik sınırı değil.** Claude Code belgesi bunu açıkça yazıyor: Bash kuralı "isn't a security boundary around the program". `Bash(git push *)` kuralı `git -C . push origin main`, `git -c push.default=current push origin main` ve `git 'push' origin main` biçimlerini durdurmuyor; `bash -c '...'` ve tam yol (`/bin/rm`) da yakalanmıyor.\[1\] Sende `git add .` deny kuralı var ama `git add -A`, `git add --all` ve `git commit -a` bu kurala takılmıyor. Varsayılan (Manual) modda eşleşmeyen komutlar yine onay istediği için pratik risk düşük. Risk `acceptEdits`, `auto` veya `bypassPermissions` moduna geçtiğinde ya da onay ekranına bakmadan "Yes" dediğinde ortaya çıkıyor.
2. **Windows'ta PowerShell aracı ayrı bir kural ailesi kullanıyor.** Git Bash kurulu değilse PowerShell aracı otomatik açılıyor ve Bash aracı hiç kaydedilmiyor. Açık olduğunda Claude PowerShell'i birincil kabuk sayıyor.\[2\]\[3\] Kuralların yalnız `Bash(...)` biçimindeyse `PowerShell(git push *)` ve `PowerShell(Remove-Item *)` karşılıkları eksik demektir. Settings dosyanın tam sözdizimini görmediğim için bunun sende geçerli olup olmadığını **doğrulayamadım**; ama olasılık yüksek ve etkisi kritik.
3. **`Read(./.env)` dar kapsamlı.** Belgeye göre Read deny kuralı `cat`, `head`, `tail`, `sed` gibi Bash'te tanınan komutlara ve `< .env` yönlendirmelerine de uygulanıyor. Ancak `grep -r pattern .` gibi dosyayı adıyla anmayan komutları ve dosyayı kendisi açan Python/Node betiklerini kapsamıyor.\[1\] `./.env` yalnız çalışma dizinindeki dosyayı eşliyor. Çıplak `Read(.env)` ise her derinlikte eşleşiyor.\[1\] `.env.local` gibi varyantlar ayrıca yazılmalı. PowerShell `Get-Content .env` / `type .env` çağrısının Read kuralına takılıp takılmadığını **doğrulayamadım**.
4. **Claude Code'da belgelenmiş izin atlatma açıkları var.** CVE-2025-54795 (komut enjeksiyonu, CVSS 8.7, v1.0.20'de düzeltildi), CVE-2025-59829 (symlink ile deny atlatma, v1.0.120'de düzeltildi), CVE-2025-55284 (geniş güvenli-komut listesiyle onaysız okuma ve dışarı sızdırma, v1.0.4 öncesi) ve CVE-2025-59536 (depodaki `.claude/settings.json` kancalarıyla güven diyaloğu öncesi kod çalıştırma, v1.0.111 öncesi).\[4\]\[5\]\[6\]\[7\]\[8\] Adversa'nın bulgusunu aktaran The Register'a göre (1 Nisan 2026, >6 ay) `bashPermissions.ts` içindeki `MAX_SUBCOMMANDS_FOR_SECURITY_CHECK = 50` sınırı nedeniyle 50'den fazla alt komut zincirlendiğinde deny kontrolü atlanıyordu (PoC: 50 `true` ve ardından `curl`); açık "fixed without notice" biçimde v2.1.90'da kapatılmış. Bu CVE'lerin tamamı eski sürümlerde. Ders şu: kural tabanlı koruma kendi hatalarıyla birlikte geliyor. Aracı güncel tut.
5. **`kur.ps1` dosyaları yanlış kodlamayla yazabilir.** Windows PowerShell 5.1'de `Set-Content` yeni dosyayı ANSI kod sayfasıyla, `Out-File` ve `>` ise UTF-16LE ile yazıyor (Microsoft about_Character_Encoding).\[9\]\[10\] `-Encoding UTF8` ise BOM ekliyor. Türkçe kural dosyaları bu yüzden bozulabilir ve SKILL.md başındaki `---` frontmatter'ı BOM nedeniyle tanınmayabilir (BOM etkisini **doğrulamadım**).

---

## 1. Kısa hüküm

Şablon, bir stajyerin gerçek sorunlarına (araç değişiminde bilgi kaybı, kontrolsüz commit/push, tekrar tekrar yazılan kurallar) doğru hedeflenmiş ve sektördeki "durumu repoya yaz" eğilimiyle uyumlu. Ölçülmüş kanıtlar kural hacminin şimdilik sorun olmadığını gösteriyor. IFScale'de bozulma onlarca ile yüzlerce talimat arasında başlıyor.\[11\] Anthropic tek CLAUDE.md dosyası için 200 satırın altını öneriyor.\[12\] Senin ~140 satırın bu sınırın içinde; ancak proje dosyaları eklendiğinde toplam yük sınıra yaklaşıyor. Asıl zekâ kaybı iş akışı kurallarından geliyor. "Tek adım at ve dur" kuralı her adımda tur ve token maliyeti ekliyor; senin kısıtın token limiti olduğu için bu doğrudan zarar. "Donmuş kod" kuralı ise semver'in "arayüzü dondur, içi serbest" ilkesinden daha katı ve teknik borç biriktiriyor. En büyük tasarım hatası iki aracı simetrik saymak. Claude PLAN, DEVAM ve kancayı otomatik görüyor, Codex hiçbirini görmüyor. Kısacası şablon genel olarak iyi, ama koruma katmanı sandığından zayıf ve Codex tarafı yarım.

---

## 2. Bulgular tablosu

| # | Bulgu | Etkilenen parça | Önem | Kanıt ve kaynak | Öneri (hangi dosyada ne değişmeli) |
|---|---|---|---|---|---|
| 1 | İzin kuralları komut varyasyonlarıyla atlatılabiliyor (`git -C`, `git -c`, tırnaklı alt komut, `bash -c`, tam yol).\[1\] `git add .` deny kuralı `-A`/`--all`/`commit -a` biçimlerini yakalamıyor | `.claude/settings.json` | Yüksek | Claude Code "Configure permissions" belgesi, "What a Bash rule doesn't match" tablosu (erişim 30.09.2026) | Deny'ı "son savunma hattı" olarak bırak. Gerçek korumayı repo içindeki Git kancalarına (`pre-push`, `commit-msg`) ve bir PreToolUse kancasına (`matcher: "Bash\|PowerShell"`) taşı. `Bash(git add -A*)` ve `Bash(git add --all*)` kurallarını da ekle |
| 2 | PowerShell aracı Bash kurallarının kapsamı dışında | `.claude/settings.json` | Kritik (kurallar yalnız Bash ise) | Tools reference: "On Windows without Git Bash, the tool is enabled automatically".\[3\] Permissions belgesi: PowerShell kuralları ayrı `PowerShell(...)` biçiminde, alias'lar (`gci`, `ls`, `dir`) kanonikleştiriliyor\[1\] | Her Bash kuralının `PowerShell(...)` karşılığını ekle: `PowerShell(git push *)` ask, `PowerShell(Remove-Item * -Recurse*)` ask, `PowerShell(git add .)` deny vb. |
| 3 | `Read(./.env)` yalnız köktekini ve tanınan komutları kapsıyor; alt süreçleri kapsamıyor | `.claude/settings.json` | Yüksek | Permissions belgesi, Read/Edit uyarısı: "don't apply to … a Python or Node script that opens files itself"\[1\] | `Read(.env)`, `Read(.env.*)`, `Read(!.env.example)` ekle. Gerçek koruma için sandbox'ı aç ya da sırları repo dışında tut |
| 4 | `attribution` ayarının biçimi hassas. `"attribution": false` kısayolu yeni; eski CLI bu anahtarı içeren **bütün settings dosyasını atlıyor**,\[13\] deny kuralları da onunla birlikte gidiyor. `includeCoAuthoredBy` v2.0.62'den beri deprecated\[14\] | `.claude/settings.json` | Yüksek | Settings reference ("Deprecated since v2.0.62") ve Claude Code changelog ("older CLI versions skip a settings file that holds it, so keep the object form")\[13\]\[14\] | Nesne biçimini kullan: `"attribution": {"commit": "", "pr": ""}`. Git talimat çatışması için `includeGitInstructions` ayarını değerlendir |
| 5 | Codex PLAN.md ve DEVAM.md dosyalarını otomatik yüklemiyor. `@` içe aktarma yalnız Claude özelliği; Codex yalnız AGENTS.md zincirini okuyor | Proje belgeleri, `/basla` | Kritik (devir amacının yarısı) | OpenAI "Custom instructions with AGENTS.md": global → kök → alt dizin, dizin başına tek dosya, `project_doc_max_bytes` 32 KiB\[15\]\[16\] | Proje AGENTS.md'nin en üstüne tek satırlık zorunlu talimat koy: "Oturum başında PLAN.md ve DEVAM.md oku". Codex'te `$basla` ile başlamayı alışkanlık yap. Ya da Codex SessionStart kancası ekle (bkz. #7) |
| 6 | Codex 32 KiB sınırını aşan içeriği uyarı vermeden kesiyor. Türkçe karakterler UTF-8'de 2 bayt | `~/.codex/AGENTS.md` ve proje AGENTS.md | Orta | OpenAI AGENTS.md belgesi ("stops adding files once the combined size reaches the limit"); openai/codex issue #7138 (kullanıcı raporu)\[15\]\[17\] | `kur.ps1` içinde toplam bayt kontrolü yap, 24 KiB üstünde uyar. `~/.codex/AGENTS.override.md` varsa global AGENTS.md hiç okunmuyor; kur.ps1 bunu da kontrol etmeli |
| 7 | `durum.ps1` yalnız Claude'da çalışıyor. Codex'te kancalar Nisan 2026'dan (0.124.0) beri kararlı\[18\] ama şablonda tanımlı değil | `.ai/durum.ps1`, Codex yapılandırması | Yüksek | OpenAI Hooks belgesi (learn.chatgpt.com/docs/hooks): SessionStart stdout "extra developer context" olarak ekleniyor, varsayılan sınır ~2.500 token, `commandWindows` alanı var, proje kancaları yalnız güvenilen projede ve hash tabanlı onaydan sonra çalışıyor\[19\]\[20\]\[21\] | `.codex/hooks.json` içine `commandWindows: "powershell -NoProfile -ExecutionPolicy Bypass -File .ai/durum.ps1"` ekle ve `/hooks` ile onayla. Windows'ta kancayı hangi kabuğun çalıştırdığı resmî olarak belgelenmemiş; kullanıcı raporları `pwsh -NoProfile -Command` sarmalayıcısı ve çıkış kodu 2'nin 1'e dönüşmesi sorunlarını bildiriyor.\[22\]\[23\] Test et |
| 8 | Claude kancası Windows'ta Git Bash kuruluysa Git Bash'le, değilse PowerShell'le çalışıyor. Ters eğik çizgiler Git Bash'te kaçış karakteri gibi yutuluyor | `.claude/settings.json` hook tanımı | Orta | Hooks reference: "Git Bash on Windows, or PowerShell when Git Bash isn't installed"; statusline belgesindeki Windows notu\[2\]\[24\] | Hook girdisine `"shell": "powershell"` ekle ve komutu `& "$env:CLAUDE_PROJECT_DIR\.ai\durum.ps1"` biçiminde yaz. Ya da `powershell -NoProfile -ExecutionPolicy Bypass -File` kullan |
| 9 | `durum.ps1` çıktısında Türkçe karakter bozulması riski. PS 5.1 konsol çıktısı OEM kod sayfasıyla (Türkçe için 857) kodlanıyor | `.ai/durum.ps1` | Orta | Microsoft about_Character_Encoding. Claude'un kanca stdout'unu nasıl çözdüğü **doğrulanmadı** | Betiğin başına `[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)` ekle. Tarihi `[datetime]::ParseExact(..., 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)` ile ayrıştır; tr-TR kültüründe `Get-Date`/`[datetime]::Parse` farklı davranabilir |
| 10 | Aynı SKILL.md iki araçta konum ve çağrı biçimi farklarıyla çalışıyor. Claude `~/.claude/skills` + `/basla` kullanıyor. Codex `$HOME/.agents/skills` + `$basla` kullanıyor; `~/.codex/skills` eski yol ve yalnız geriye uyumluluk için okunuyor\[25\]\[26\] | SKILL.md'ler, `kur.ps1` | Orta | OpenAI "Build skills" belgesi: USER konumu `$HOME/.agents/skills`, "type `$` to mention a skill".\[25\] Kaynak koddaki "Deprecated user skills location" notu yalnız üçüncü taraf alıntısıyla görüldü.\[27\] Agent Skills spesifikasyonu: `name` ≤64 karakter, küçük harf/rakam/tire, klasör adıyla aynı; `description` ≤1024 karakter\[28\]\[29\]\[30\] | kur.ps1 skill'leri `~/.agents/skills` ve `~/.claude/skills` altına kopyalamalı. Adlarda Türkçe harf kullanmaman doğru; öyle kalsın. Belgelere "Codex'te `$basla`" notu ekle |
| 11 | Yan etkili skill'ler (`/devir`, `/karar`, `/yeni-proje`) model tarafından kendiliğinden tetiklenebilir | SKILL.md frontmatter | Orta | Claude skills belgesi: "Use disable-model-invocation: true for skills with side effects".\[31\]\[32\] Codex'te karşılığı `agents/openai.yaml` içindeki `policy.allow_implicit_invocation: false`\[25\] | Claude için `disable-model-invocation: true` ekle. Codex için her skill klasörüne `agents/openai.yaml` koy. Codex'in Claude'a özgü alanları nasıl ele aldığı belgelenmemiş (claude.ai yükleyicisi `argument-hint` alanını reddediyor); bu alanları ayrı tutmak daha güvenli |
| 12 | "Tek adım at ve dur" kuralı tur sayısını ve token tüketimini artırıyor | Genel kurallar | Yüksek | Doğrudan ölçen bir çalışma **bulamadım**. Gerekçe: her tur bağlamı yeniden işliyor; senin darboğazın token limiti | "Onaylanmış planın adımlarını tek tek uygula; yalnız kontrol noktalarında dur (commit, yeni bağımlılık, .env, donmuş arayüz, test kırmızı)" biçimine çevir |
| 13 | "Donmuş kod" kuralı refactor'ı ve hata düzeltmesini soru-onay döngüsüne bağlıyor ve borç biriktiriyor | Aşama yalıtımı kuralı | Yüksek | Semver: kararlılık sözü **genel API** için veriliyor, iç uygulama serbest. Açık-kapalı ilkesi de genişletmeye açık, arayüz değişikliğine kapalı olmayı söylüyor | "Donmuş = genel arayüz + testler" yap. İç refactor testler yeşilse serbest olsun, yalnız arayüz değişikliği onaya bağlansın. Arayüz değişikliği K-kaydı gerektirsin |
| 14 | PLAN.md her Claude oturumunda içe aktarılıyor ve büyüdükçe bağlam maliyeti artıyor. İçe aktarma bağlamı azaltmıyor | CLAUDE.md, PLAN.md | Orta | Claude memory belgesi: "Imports help you organize … but don't reduce its context cost"\[12\] | Biten aşamaları `PLAN-arsiv.md` dosyasına taşı (içe aktarma dışında). PLAN.md'de yalnız aktif aşama ve sonraki aşama kalsın |
| 15 | GUNLUK.md sınırsız büyüyor ve git log + DEVAM ile büyük ölçüde örtüşüyor | GUNLUK.md | Düşük | Tasarım gözlemi (ölçüm yok) | Ya kaldır ve bilgiyi commit mesajlarına taşı, ya da aylık dosyalara böl ve asla içe aktarma |
| 16 | Genel kurallar iki dosyada kopyalandığı için sürüklenme (drift) riski var | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` | Orta | Claude memory belgesi: kullanıcı kapsamındaki dosyalar `@~/...` içe aktarmasını onay diyaloğu olmadan yüklüyor\[12\] | Tek kaynak kullan: `~/.claude/CLAUDE.md` = `@~/.codex/AGENTS.md` + Claude'a özgü birkaç satır |
| 17 | Kural çatışmasında model rastgele seçebilir; araç varsayılanı ile senin kuralın çatışabilir | Genel kurallar ↔ araç varsayılanları | Orta | Claude memory belgesi: "Claude may pick one arbitrarily".\[12\] Attribution'da ise belgelenmiş öncelik var: Claude Code, CLAUDE.md'deki attribution kuralının öncelikli olduğunu modele kendisi söylüyor (managed ayar hariç)\[14\] | Çatışmayı ayarla çöz (attribution, `includeGitInstructions`, `autoMemoryEnabled: false`), metin kuralına güvenme. `autoMemoryEnabled` adı ve proje düzeyinde geçerliliği doğru (belgeyle doğrulandı)\[12\] |
| 18 | `kur.ps1` kullanıcı dosyalarının üzerine yazıyor; kodlama, yedek ve settings birleştirme riskleri var | `kur.ps1` | Yüksek | Microsoft about_Character_Encoding (PS 5.1 varsayılanları)\[10\] | Dosyaları `[IO.File]::WriteAllText($p, $t, [Text.UTF8Encoding]::new($false))` ile yaz. Yedeğe zaman damgası ekle, eski yedeği ezme. `settings.json` dosyasını ezme, birleştir. `-WhatIf`/kuru çalıştırma modu ekle. ExecutionPolicy'yi kalıcı değiştirme; `powershell -ExecutionPolicy Bypass -File kur.ps1` kullan. `CODEX_HOME` değişkenine saygı göster |
| 19 | Codex'te deny listesi eşdeğeri yok; koruma sandbox + onay politikasından geliyor. Windows'ta "elevated" sandbox'ın çalışma alanı dışına yazabildiğine dair açık kullanıcı raporu var | Codex yapılandırması (şablonda yok) | Orta | OpenAI "Sandbox" / "Config basics" (`sandbox_mode = "workspace-write"`, `approval_policy = "on-request"`, `[windows] sandbox = "elevated"`); openai/codex issue #18558 (kullanıcı raporu, doğrulanmadı)\[33\]\[34\]\[35\] | Şablona `~/.codex/config.toml` örneği ekle. Git kancalarını iki araç için ortak zorlama katmanı yap |

---

## 3. Proje türüne göre uygunluk

| Proje türü | Uygunluk | Gerekçe |
|---|---|---|
| Tek kişilik öğrenme projesi | **Çok uygun** | Onay kapıları öğrenmeyi zorunlu kılıyor, K-kayıtları gerekçe yazma alışkanlığı kazandırıyor. Tek sorun "tek adım" kuralının token maliyeti |
| Küçük web uygulaması | **Uygun (gevşetilmiş haliyle)** | Aşama/etiket yapısı özellik dilimlerine iyi oturuyor. Donmuş kod kuralı UI iterasyonunu yavaşlatır; "donmuş arayüz" biçimine geç |
| Veri/ML betikleri | **Kısmen** | Keşif işi doğrusal değil; aşama yalıtımı ve "önce plan" deneme hızını düşürüyor. Notebook/veri dosyaları için .gitignore ve büyük dosya kuralları eksik. `python-windows` eki yardımcı ama yeterli değil |
| Ekip projesi | **Uygun değil (bu haliyle)** | DEVAM.md ve CLAUDE.md yerel olduğu için devir kişisel kalıyor. Ekipte PR incelemesi, CODEOWNERS ve branch koruması zaten aynı işi görüyor. KARARLAR.md yerine ADR standardı (status/superseded) gerekir |
| Büyük monorepo | **Uygun değil** | Tek PLAN.md ve tek aşama ekseni ölçeklenmiyor. Claude'un `.claude/rules/` path-scoped kuralları, alt dizin AGENTS.md dosyaları ve `claudeMdExcludes` daha doğru araçlar. Codex 32 KiB sınırına takılma riski var |
| Prototip/hackathon | **Uygun değil** | Onay kapıları ve belge bakımı hızı öldürür. Yalnız git güvenlik kuralları ve .env koruması kalsın |
| Kodsuz belge projesi | **Kısmen** | PLAN/DEVAM/KARARLAR işe yarar. Test, CI ve aşama etiketi gereksiz. Türkçe/UTF-8 notları burada daha değerli |

---

## 4. Kural değişiklikleri

### Kaldırılması önerilenler
- **"Her mesaj Türkçe" kuralını genel dosyadan çıkar, tek satıra indir ya da çıktı stiline taşı.** Model bu kurala zaten iyi uyar. Uzun açıklaması bağlam israfı.
- **Genel dosyadaki Windows/BOM/UTF-8 düzyazı notlarını kaldır, `python-windows` ekine veya bir skill'e taşı.** Bu bilgi her oturumda gerekmiyor. Claude belgesi "yalnız bir kısımda gerekiyorsa skill veya path-scoped kurala taşı" diyor.\[12\]
- **GUNLUK.md (ya da içe aktarılmaması koşuluyla aylığa böl).** Git log ve DEVAM ile büyük ölçüde örtüşüyor; her oturum bakım maliyeti getiriyor.
- **"Kod kısaltma (`// ... mevcut kod`) yok" kuralı.** Diff/edit araçlarıyla çalışan ajanlarda bu hata nadir. Kural gerçekten gerekiyorsa tek satır yeterli. (Bu yargı gözleme dayanıyor, ölçüm değil.)

### Gevşetilmesi önerilenler
- **"Tek adım at ve dur" → "onaylı plan içinde ilerle, kontrol noktalarında dur".** Kontrol noktaları: commit, push, yeni bağımlılık, `.env`, donmuş arayüz değişikliği, testlerin kırmızıya dönmesi, plan dışı dosya. Trade-off: katı kural hata başına daha az zarar verir ama tur/token maliyeti yüksektir. Kontrol noktası modeli token verimli ve riskli anları yine yakalıyor. Senin kısıtın token olduğu için tercihim kontrol noktası modeli.
- **"Donmuş kod" → "donmuş genel arayüz + donmuş testler".** İç refactor testler yeşilse serbest; arayüz değişikliği onay ve K-kaydı gerektirir. Bu semver'in genel API kararlılığı ilkesiyle hizalı. Tam dondurmanın tek avantajı öğrenme sürecinde "neden değişti" sorusunu zorlaması; bunu K-kaydı zaten sağlıyor.
- **"Önce plan, onay, sonra kod" → yalnız çok dosyalı veya mimari işlerde zorunlu.** Tek satırlık düzeltmede plan istemek bürokrasi. Claude'un yerleşik plan modu (`plan` izin modu, kaynak dosyaları düzenlemiyor)\[1\] aynı işi araç düzeyinde ve daha güvenilir yapıyor.
- **"Canlı/dış sistem komutlarını kullanıcı çalıştırır" kuralını koru, ama "yerel test/lint/build komutlarını ajan çalıştırır" diye açık istisna ekle.** Aksi halde model test çalıştırmaktan da kaçınabilir.

### Eklenmesi önerilenler
- **Git kancaları (araçtan bağımsız gerçek zorlama):** `commit-msg` kancası `Co-Authored-By` satırlarını reddetsin. `pre-push` kancası bir ortam değişkeni veya etkileşimli onay olmadan push'u reddetsin. `pre-commit` kancası `.env` eklenmesini engellesin. Deny kurallarından farklı olarak iki araçta da çalışır ve komut varyasyonuyla atlatılamaz (`--no-verify` hariç; `Bash(* --no-verify*)` ve `PowerShell(* --no-verify*)` için deny ekle).
- **PowerShell eşdeğeri izin kuralları** (bkz. Bulgu #2).
- **PreToolUse kancası** (`matcher: "Bash|PowerShell"`): `git` + `push|reset --hard|clean|add -A|add .` desenlerini ve `-C`/`-c` varyasyonlarını düzenli ifadeyle yakalayıp deny döndürsün. Belgeye göre kanca deny'ı bypassPermissions modunda bile blokluyor.\[36\]
- **Codex tarafı:** `~/.codex/config.toml` örneği (`sandbox_mode = "workspace-write"`, `approval_policy = "on-request"`, `[windows] sandbox = "elevated"`), `.codex/hooks.json` + `commandWindows` ile `durum.ps1`, proje AGENTS.md başında "PLAN.md ve DEVAM.md'yi oku" satırı.
- **Skill güvenliği:** `/devir`, `/karar`, `/yeni-proje` için `disable-model-invocation: true` (Claude) ve `allow_implicit_invocation: false` (Codex).
- **KARARLAR.md'ye ADR alanları:** `Durum: önerildi/kabul/yerini aldı K-00X`. "Yalnız ekleme" ilkesini koru, ama iptal edilen kararın hangi kararla değiştirildiği görünür olsun.
- **Boyut bekçisi:** `durum.ps1` genel + proje AGENTS.md toplam baytını da raporlasın ve 24 KiB üstünde uyarsın.
- **Periyodik denetim:** Claude'da `/doctor prompt-audit` (v2.1.283+) ile çelişen/eskimiş talimatları tara.\[12\]

---

## 5. Ayrıntılar

### A1. Talimat yükü: ölçülmüş bulgular
- **IFScale (Jaroslawicz, Whiting, Shah, Maamari / Distyl AI, arXiv 2507.11538, 15 Temmuz 2025, >6 ay):** Yedi büyük sağlayıcıdan 20 model 10-500 anahtar kelime talimatıyla test edildi; makaleye göre "even the best frontier models only achieve 68% accuracy at the max density of 500 instructions". Üç bozulma kalıbı gözlendi: akıl yürüten modellerde eşik sonrası çöküş (o3, gemini-2.5-pro), doğrusal azalma (gpt-4.1, claude-sonnet-4) ve üstel azalma (gpt-4o, llama-4-scout). Önce gelen talimatlara öncelik verme eğilimi (primacy) 150-200 talimat civarında zirve yapıyor.\[37\] **Şablona anlamı:** 140 satırda muhtemelen 40-70 ayrı kural var (sayı **tahmin**, dosyayı görmedim). Doğrusal azalan modellerde küçük ama gerçek bir kayıp beklenir. En kritik kurallar (git, .env, onay) dosyanın **başında** olmalı. Sınırlama: görev iş raporuna anahtar kelime eklemek; kod ajanı davranışına doğrudan genellenemez.
- **"Evaluating AGENTS.md" (Gloaguen, Mündler, Müller, Raychev, Vechev / ETH Zürih, arXiv 2602.11988, v1 Şubat 2026 >6 ay, v2 23 Haziran 2026, ICLR 2026 workshop):** Claude Code, Codex ve Qwen Code ile yapılan çalışmanın v2 özetine göre "providing context files does not generally improve task success rates, while increasing inference cost by over 20% on average"; ayrıca "instructions in the context files are well followed by coding agents", depo genel bakışları ise "not helpful". İkincil özetlerde çelişki var: bazıları geliştirici yazımı dosyalarda ~%4 kazanç bildiriyor, özetin bir sürümü ise "tend to reduce" diyor.\[38\]\[39\] **Şablona anlamı:** Senin dosyaların büyük kısmı "depo özeti" değil "davranış kuralı". Çalışmaya göre modelin uyduğu tür bu. Ama her kural ek keşif ve test adımı üretiyor, yani maliyet artıyor.
- **Context rot (Hong, Troynikov, Huber / Chroma, Temmuz 2025, >6 ay):** 18 model üzerinde raporun ifadesiyle "Across all experiments, model performance consistently degrades with increasing input length"; LongMemEval deneyinde ~300 tokenlık odaklı istem, ~113 bin tokenlık tam istemden daha iyi sonuç verdi.
- **Lost in the Middle (Liu vd., TACL 2024, >6 ay):** Bağlamın ortasındaki bilgi daha az kullanılıyor.\[40\] Sende CLAUDE.md → @AGENTS.md → @PLAN.md → @DEVAM.md sırasında DEVAM en sonda kalıyor; bu iyi bir yerleşim.
- **Anthropic belgesi (code.claude.com/docs/en/memory, erişim 30.09.2026):** "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." Ayrıca CLAUDE.md sistem isteminin parçası değil, sistem isteminden sonra kullanıcı mesajı olarak veriliyor: "there's no guarantee of strict compliance".\[12\]
- **Doğrulanmadı:** arXiv 2608.12426 ("Large Language Models Can Follow Instructions, But Not Many at Once: Phase Transitions…", Ağustos 2026) makalesinin yalnız başlığını ve kaynakçasını gördüm;\[41\] bulgularını okuyamadım.

### A2. "Tek adım" ve "önce plan" kuralları
Bu kuralların özerk görev başarısına etkisini doğrudan ölçen bir çalışma **bulamadım**. Mekanizma üzerinden akıl yürütürsem: SWE-bench tarzı ölçümler ajanın kesintisiz döngüde çalıştığı senaryoyu ölçüyor, her adımda durmak ise bu döngüyü kırıyor. Zarar verdiği durumlar şunlar: (a) çok dosyalı değişiklikler, çünkü ara durumlar derlenmiyor ve test edilemiyor; (b) hata ayıklama, çünkü hipotez-dene-gözle döngüsü tur başına bölünüyor; (c) token limiti. Yararlı olduğu durumlar: öğrenme ve riskli/geri dönüşsüz işlemler. Sonuç: kuralı işlem riskine göre kademelendir.

### A3. Donmuş kod ↔ yazılım mühendisliği
Semver kararlılık sözünü genel API için veriyor; iç uygulama değişikliği yama/küçük sürümle serbest. Açık-kapalı ilkesi davranışı değiştirmeden genişletmeyi öneriyor ama refactor'ı yasaklamıyor. Senin kuralın bu iki ilkeden de katı. Tipik belirtiler: yeni aşamada eski koddaki bir hatayı "sormak zahmetli" diye sarmalayıcı (wrapper) yazmak ve kopyala-yapıştır kodun çoğalması. "Yeni aşama eski koda yalnız dışa açık arayüzle erişir" ilkesi doğru ve kalmalı. "Her adımda bütün testler" ilkesi de doğru; refactor özgürlüğünü güvenli kılan tam olarak bu.

### A4. Araç varsayılanlarıyla çatışma
- **Attribution:** Claude Code bu konuda kullanıcı talimatının öncelikli olduğunu modele kendisi bildiriyor (managed ayar hariç).\[14\] Ayar ve kural aynı yönde olduğu için çatışma yok. Doğru ayar nesne biçimi (bkz. Bulgu #4).
- **Auto memory:** `autoMemoryEnabled: false` doğru ad; proje settings'inde geçerli. Alternatifi `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`. Açık kalsaydı MEMORY.md'nin ilk 200 satırı veya ilk 25 KB'ı her oturuma yüklenecek\[12\] ve "durum repoda" ilkesiyle çatışacaktı. Kapatman tutarlı.
- **Codex'in kendi hafıza özelliğinin** varlığını ve kapatma ayarını **doğrulamadım**.

### A5. Küçük modeller
Haiku sınıfına özgü bir uyum ölçümü **bulamadım**. IFScale'de model boyutu ve akıl yürütme yeteneği bozulma kalıbıyla ilişkili;\[42\] küçük modeller üstel azalma gösteriyor.\[11\] Çıkarım: alt ajanlar veya ucuz model kullanırsan kritik kurallar erken çiğnenir. Bu nedenle zorlamayı kancalara taşımak küçük modellerde daha da önemli.

### B6. Claude Code teknik doğrulama (code.claude.com, erişim 30.09.2026)
- **Yükleme:** Dosyalar managed → kullanıcı (`~/.claude/CLAUDE.md`) → proje → yerel sırasıyla yükleniyor. Birbirini geçersiz kılmıyor, uç uca ekleniyor; çalışma dizinine yakın olan en son okunuyor. Dizin başına `CLAUDE.local.md` ise `CLAUDE.md`'den sonra ekleniyor.\[12\]
- **İçe aktarma:** Göreli yol, içe aktaran dosyaya göre çözülüyor. **En fazla 4 atlama**\[12\] (bazı eski ikincil kaynaklar 5 diyor;\[43\]\[44\] güncel belge "four hops"). Kod bloğu içindeki `@` dikkate alınmıyor. Proje dışındaki içe aktarmalar bir kez onay istiyor. HTML yorumları bağlamdan çıkarılıyor; bakım notları için kullanabilirsin.\[12\]
- **AGENTS.md:** v2.1.277+ AGENTS.md'yi kendisi okuyor, ama dizinde CLAUDE.md varsa yalnız CLAUDE.md okunuyor. `@AGENTS.md` içe aktarman bu yüzden doğru, çift yükleme de olmuyor. `AGENTS.override.md` Claude tarafından okunmuyor.\[12\]
- **Yerel CLAUDE.md:** Git dışı `CLAUDE.md` yerine belgelenmiş ad `CLAUDE.local.md`. İkisi de çalışır; ama taze klonda CLAUDE.md olmadığında Claude AGENTS.md'yi doğrudan okur ve PLAN/DEVAM'ı içe aktarmaz. Belgeye not düş.
- **SessionStart:** Düz metin stdout Claude'un bağlamına ekleniyor. JSON kullanılırsa alan `hookSpecificOutput.additionalContext`; üst düzeyde verilirse sessizce yok sayılıyor.\[36\] Stdout ve additionalContext **10.000 karakterle sınırlı**.\[2\] Kaynak türleri `startup/resume/clear/compact/fork`.\[36\] `compact` eşleyicisiyle sıkıştırmadan sonra durumu yeniden enjekte etmek mümkün;\[45\] `/compact` sonrası devir için bunu kullan.
- **İzinler:** Sıra deny → ask → allow, ilk eşleşme kazanıyor ve özgüllük sırayı değiştirmiyor.\[1\] Settings önceliği managed > CLI argümanları > local > project > user. Proje `permissions.allow` kuralları güven diyaloğundan sonra uygulanıyor; deny/ask hemen geçerli.\[1\]\[46\]
- **VS Code eklentisi:** `~/.claude/settings.json` ayarları (izinler, kancalar) eklenti ve CLI arasında paylaşılıyor. Eklenti kendi CLI kopyasını paketliyor.\[47\] SessionStart kancasının eklentide birebir aynı çalıştığını ve skill slash çağrısının her sürümde çalıştığını belgeden **açıkça doğrulayamadım**; test et.

### B7. Codex teknik doğrulama (developers.openai.com / learn.chatgpt.com, erişim 30.09.2026; sayfalarda tarih yok)
- **AGENTS.md:** Global düzeyde `~/.codex/AGENTS.override.md` varsa yalnız o okunuyor, yoksa `AGENTS.md`. Sonra proje kökünden çalışma dizinine kadar her dizinde override → AGENTS.md → yedek adlar sırasıyla aranıyor ve dizin başına tek dosya alınıyor. Toplam `project_doc_max_bytes` = 32 KiB.\[15\]\[16\]
- **Skills:** Konumlar `$CWD/.agents/skills` → üst dizinler → `$REPO_ROOT/.agents/skills` → `$HOME/.agents/skills` → `/etc/codex/skills` → sistem. Başlangıç listesi bağlamın %2'si ya da 8.000 karakterle sınırlı. `name` ve `description` zorunlu.\[48\] Çağrı `$ad` ya da `/skills` ile yapılıyor.\[25\]
- **Hooks:** 0.124.0'da kararlı oldu\[18\] (release notu, ~23 Nisan 2026, >6 ay). Varsayılan açık; `codex_hooks` artık deprecated alias. SessionStart stdout geliştirici bağlamına ekleniyor, varsayılan sınır ~2.500 token (`additionalContextLimit` ile değiştirilebiliyor). Proje kancaları yalnız güvenilen projede ve hash tabanlı onaydan sonra çalışıyor.\[21\] Windows'ta hangi kabuğun kullanıldığı **belgelenmemiş**.\[23\] Kullanıcı raporları PowerShell sarmalayıcısı, "Access is denied" (MSIX PowerShell) ve çıkış kodu 2'nin 1'e dönüşmesi gibi sorunlar bildiriyor (openai/codex #48183, #47810, #48876; doğrulanmadı).\[22\]\[49\]\[50\]
- **Windows:** Doğal Windows sandbox'ı var; `[windows] sandbox = "elevated"` öneriliyor.\[34\]

### B8. Ortak SKILL.md gerçekçi mi?
Kısmen. Gövde ve `name`/`description` iki araçta ortak (Agent Skills açık standardı).\[25\]\[29\] Ayrışan noktalar: konum (`.claude/skills` ↔ `.agents/skills`), çağrı (`/ad` ↔ `$ad`), Claude'a özgü alanlar (`disable-model-invocation`, `argument-hint`, `allowed-tools`, `shell`, `paths`, `hooks` vb.) ve Codex'e özgü `agents/openai.yaml`. Codex'in Claude'a özgü alanları sessizce yok saydığı muhtemel ama **belgelenmemiş**. Öneri: ortak gövde + araç başına ince bir frontmatter; kur.ps1 iki kopyayı üretsin.

### B9. Windows + PowerShell 5.1 riskleri
- Kodlama: `Out-File`/`>` UTF-16LE, `Set-Content` yeni dosyada ANSI, `-Encoding UTF8` BOM'lu, `Get-Content` BOM'suz dosyayı ANSI olarak okuyor.\[10\] `Get-Content` ile BOM'suz UTF-8 okursan Türkçe karakterler bozulur; her zaman `-Encoding UTF8` ver.
- Konsol kod sayfası: kanca stdout'u için `[Console]::OutputEncoding` ayarla.
- ExecutionPolicy: Claude'un PowerShell **aracı** kendi süreç kapsamında `-ExecutionPolicy Bypass` ile başlıyor.\[3\] Kancalar için aynı davranışı **doğrulayamadım**; komuta açıkça `-ExecutionPolicy Bypass` yaz.
- Git `core.autocrlf`: bu oturumda doğrulamadım. Genel öneri `.gitattributes` içinde `* text=auto eol=lf` ve `*.ps1 text eol=crlf`. BOM'suz UTF-8 ve CRLF karışımında PS 5.1 betiklerinde Türkçe string sorunu yaşanabilir (**doğrulanmadı**).
- Symlink: Windows'ta yönetici veya Developer Mode gerektiriyor; `CLAUDE.md → AGENTS.md` symlink'i yerine `@` içe aktarması doğru seçim (Claude belgesi de bunu öneriyor).\[12\]

### C11. Bakım yükü ve bağlam maliyeti
- **Oturum başına dosya güncellemesi:** DEVAM.md (her zaman), PLAN.md (adım durumu), GUNLUK.md (her zaman), KARARLAR.md (bazen), yani 3-4 dosya. Devir notunu `/devir` skill'i yazıyor, ama bu da token harcıyor.
- **Bağlam maliyeti (kaba tahmin, ölçülmedi):** 140 satır × ~60 karakter ≈ 8-9 KB. Türkçe metnin tokenizer verimi İngilizceden düşük olduğu için genel kurallar büyük olasılıkla birkaç bin token tutuyor. Proje AGENTS.md + PLAN.md + ≤60 satır DEVAM + kanca çıktısıyla toplam kabaca 5-10 bin token bekliyorum. Bu 200 bin tokenlık pencerenin küçük bir yüzdesi; sorun pay değil, her istekte tekrarlanması (CLAUDE.md "stays in every request")\[31\] ve talimat yoğunluğu. **Ölç:** Claude'da `/context`, Codex'te oturum durum komutu.
- **Codex'te PLAN/DEVAM hiç yüklenmediği için** oradaki maliyet daha düşük ama devir kalitesi de düşük.

### C12. Benzer yaklaşımlarla karşılaştırma

| Yaklaşım | Şablonda fazlası | Şablonda eksiği |
|---|---|---|
| AGENTS.md standardı | Oturum durumu (DEVAM), karar kaydı | Alt dizin AGENTS.md katmanlaması |
| Claude yerleşikleri (plan modu, auto memory, `/compact`, `.claude/rules/` paths) | Araçtan bağımsız, repo içinde kalıcı durum | Plan modunu kullanmıyor (aynı işi metin kuralıyla yapıyor); path-scoped kurallar yok; `compact` sonrası yeniden enjeksiyon yok |
| GitHub Spec Kit (`constitution.md`, specify→plan→tasks→implement) | Daha hafif; onay/Git güvenliği güçlü | Özellik başına spec/tasks ayrımı yok. Not: Scott Logic'ten Colin Eberhardt'ın ölçümüne göre (26 Kasım 2025, >6 ay) Spec Kit ile bir özellik "33m30 of agent execution time", 2.577 satır markdown ve 3,5 saat inceleme gerektirdi; normal yöntemde 8 dk ajan + 15 dk inceleme + 9 dk test (~32 dk) yetti ve yazar "around ten times faster" diyor; aynı aşırı-seremoni riski sende de var |
| BMAD | Çok daha hafif, tek kişiye uygun | Persona/rol ayrımı yok; bu senin ölçeğinde gereksiz |
| ADR | K-001 yalnız-ekleme mantığı ADR ile aynı | Durum/yerini aldı alanları yok |
| Cursor rules, Aider conventions | Bu oturumda birincil kaynaktan **doğrulamadım**; karşılaştırma yapmıyorum | — |

Sonuç: Şablonun özgün değeri "araç değişiminde devir" ve "Git güvenliği". Spec Kit veya BMAD'e geçmek senin sorununu çözmez, seremoniyi artırır.

### D14. `kur.ps1` riskleri
(1) Kodlama bozulması (Bulgu #18). (2) Kullanıcının mevcut `~/.claude/settings.json` ve kişisel CLAUDE.md içeriğinin ezilmesi; yedek varsa bile ikinci çalıştırmada yedeğin ezilmesi. (3) `~/.codex/AGENTS.override.md` varsa yeni global kuralların hiç okunmaması. (4) `CODEX_HOME` farklıysa yanlış dizine yazma. (5) Kullanıcının betiği çalıştırmak için ExecutionPolicy'yi kalıcı olarak `Unrestricted` yapması. (6) Skill'lerin eski `~/.codex/skills` yoluna yazılması. Öneri: idempotent, `-WhatIf` destekli, zaman damgalı yedek alan, JSON birleştiren ve sonunda "ne yazıldı" özeti veren bir betik.

---

## 6. Doğrulanamayanlar ve kendin test etmen gerekenler

1. **PowerShell aracı açık mı?** Claude oturumunda `Get-ChildItem` çalıştırmasını iste ve araç adının `PowerShell` mi `Bash` mı olduğunu gör. Sonra `git -C . push --dry-run` ve PowerShell üzerinden `git push --dry-run` dene; hangisinin onay istediğine bak.
2. **`.env` koruması:** Sahte bir `.env` oluştur. `cat .env`, `type .env`, `Get-Content .env`, `grep -r SECRET .` ve `python -c "print(open('.env').read())"` dene. Hangileri bloklanıyor?
3. **Kanca kodlaması:** `durum.ps1` çıktısına "ğüşıöç" ekle, Claude'a "kanca çıktısını aynen yaz" de ve karakterleri karşılaştır.
4. **VS Code eklentisinde SessionStart ve skill'ler:** Eklentide yeni oturum aç; kanca çıktısının bağlamda olup olmadığını ve `/basla` komutunun göründüğünü kontrol et.
5. **Codex'te devir:** Codex'te yeni oturumda "PLAN.md'deki aktif adım ne?" diye sor. Dosyayı okumadan yanıt veriyorsa yüklenmemiş demektir. `.codex/hooks.json` + `commandWindows` ekleyip `/hooks` ile onayladıktan sonra tekrar dene. Çıkış kodu 2 davranışını da test et.
6. **Codex'in Claude'a özgü frontmatter alanlarına tepkisi:** `disable-model-invocation` içeren SKILL.md dosyasının Codex'te yüklenip yüklenmediğine ve uyarı verip vermediğine bak.
7. **BOM'lu SKILL.md:** Bir skill'i BOM'lu kaydet ve iki araçta da listelenip listelenmediğine bak.
8. **`"attribution": false` ile sürüm uyumu:** Kendi CLI sürümünde settings dosyasının atlanıp atlanmadığını `/permissions` ile deny kurallarının görünüp görünmediğine bakarak kontrol et.
9. **Token ölçümü:** `/context` ile gerçek bellek dosyası maliyetini ölç ve bu rapordaki kaba tahmini düzelt.
10. **Codex Windows sandbox:** `workspace-write` + `elevated` ile çalışma alanı dışına yazmayı dene (issue #18558 senaryosu).
11. **Tek adım ile kontrol noktası karşılaştırması:** Aynı küçük özelliği iki kuralla uygula; tur sayısını ve kullanım yüzdesini karşılaştır. Bu soruya doğrudan yanıt veren bir literatür bulamadım; kendi ölçümün en iyi kanıt olacak.

---

## Uyarılar ve kaynak tazeliği
- Araç belgelerinin (code.claude.com, developers.openai.com / learn.chatgpt.com) sayfalarında yayın tarihi yok; hepsine 30 Eylül 2026'da eriştim. Codex hooks sayfası kendini "release behavior reference" olarak tanımlıyor ve `main` şemalarının yayında olmayan alanlar içerebileceği uyarısını yapıyor.\[21\]
- **6 aydan eski kaynaklar:** IFScale (Tem 2025), Chroma context rot (Tem 2025), Lost in the Middle (2023/TACL 2024), ETH AGENTS.md (Şub 2026), 2025 CVE'leri, Adversa/The Register (1 Nis 2026), Codex hooks kararlılık notu (Nis 2026). Bulguları yön gösterici kabul et; model sürümleri değişti.
- GitHub issue'ları (openai/codex #7138, #18558, #48183 vb.) kullanıcı raporları; OpenAI tarafından doğrulanmış kabul etme.
- İkincil kaynaklardaki "%80 tasarruf" türü iddiaları ve spec çerçevelerinin yıldız sayılarını değerlendirmeye katmadım. Spec Kit süre karşılaştırması (Scott Logic, Colin Eberhardt, 26 Kasım 2025: 3,5 saat inceleme / normal yöntemle ~32 dk) tek bir yazarın tek özellik üzerindeki deneyi; genellenemez.
- Şablonun gerçek dosyalarını görmedim. Settings sözdizimi, kural sayısı ve kur.ps1 içeriği hakkındaki bulgular özetten çıkarıldı; "eğer … ise" koşullu okunmalı.

## Sources

1. [Configure permissions - Claude Code Docs](https://code.claude.com/docs/en/permissions)
2. [Hooks reference - Claude Code Docs](https://code.claude.com/docs/en/hooks)
3. [Tools reference - Claude Code Docs](https://code.claude.com/docs/en/tools-reference)
4. [Claude Code Security Vulnerabilities and Issues — Claude Code CVE List](https://vulners.com/search/vendors/anthropic/products/claude%20code)
5. [Claude Code Security Risks IT Teams Should Know in 2026](https://www.cloudeagle.ai/blogs/claude-code-security-risks)
6. [CVE-2025-55284: Claude Code Auth Bypass Vulnerability](https://www.sentinelone.com/vulnerability-database/cve-2025-55284/)
7. [CVE-2025-59829: Claude Code permission deny bypass through symlink](https://advisories.gitlab.com/npm/@anthropic-ai/claude-code/CVE-2025-59829/)
8. [CVE-2025-54795:InversePrompt: Turning Claude Against Itself](https://cymulate.com/blog/cve-2025-547954-54795-claude-inverseprompt/)
9. [Understanding Character Encoding in PowerShell](https://www.positioniseverything.net/understanding-character-encoding-in-powershell/)
10. [about Character Encoding](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Character_Encoding)
11. [How Many Instructions Can LLMs Follow at Once?](https://arxiv.org/html/2507.11538)
12. <https://code.claude.com/docs/en/memory>
13. [Claude Code changelog - Claude Code Docs](https://code.claude.com/docs/en/changelog)
14. [All settings - Claude Code Docs](https://code.claude.com/docs/en/settings-reference)
15. [Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
16. [Part 3: AGENTS.md — Codex Starter Best Practices](https://codex-best-practices-d67bea.pages.oit.duke.edu/best-practices/agents.html)
17. [\`AGENTS.md\` is silently truncated without any warning within the TUI · Issue #7138 · openai/codex](https://github.com/openai/codex/issues/7138)
18. [Release 0.124.0 · openai/codex](https://github.com/openai/codex/releases/tag/rust-v0.124.0)
19. [bug(hooks): Codex SessionStart hook is POSIX-only and never migrates to a Windows command · Issue #3298 · Gentleman-Programming/gentle-ai](https://github.com/Gentleman-Programming/gentle-ai/issues/3298)
20. [SessionStart hook exits with code 1 on native Windows Codex (bash/jq-only hook) · Issue #475 · addyosmani/agent-skills](https://github.com/addyosmani/agent-skills/issues/475)
21. [Hooks | ChatGPT Learn](https://developers.openai.com/codex/hooks)
22. [Windows: PreToolUse hook exit code 2 does not block; hook commands run under \`pwsh -Command\`, which reports exit 1 · Issue #48183 · openai/codex](https://github.com/openai/codex/issues/48183)
23. [Codex hooks fail on Windows: rendered hook commands are not valid PowerShell · Issue #68 · cfaysal/kherep](https://github.com/cfaysal/kherep/issues/68)
24. [Customize your status line - Claude Code Docs](https://code.claude.com/docs/en/statusline)
25. <https://developers.openai.com/codex/skills.md>
26. [A global Codex install writes \~/.codex/skills, the location Codex calls deprecated · Issue #33 · miqdadbadjuber/anti-slop](https://github.com/miqdadbadjuber/anti-slop/issues/33)
27. [fix(codex): install skills to \~/.agents/skills and clean the old folder by thearthurchen · Pull Request #620 · powerset-co/powerpacks](https://github.com/powerset-co/powerpacks/pull/620)
28. [How Do You Build Your First Agent Skill? A Complete SKILL.md Anatomy Guide](https://agentman.ai/blog/build-your-first-agent-skill-skillmd-anatomy)
29. [Codex Skills: How They Work and Which Ones to Install](https://www.skillsboard.sh/codex-skills)
30. [Agent Skills Specification: SKILL.md Format, Fields, and Directory Structure](https://www.scriptbyai.com/agent-skills-specification/)
31. [Extend Claude Code - Claude Code Docs](https://code.claude.com/docs/en/features-overview)
32. [Best practices for Claude Code - Claude Code Docs](https://code.claude.com/docs/en/best-practices)
33. [Sandbox](https://developers.openai.com/codex/concepts/sandboxing)
34. [Config basics](https://developers.openai.com/codex/config-basic)
35. [Windows: sandbox\_mode = "workspace-write" + \[windows\] sandbox = "elevated" allows mutable access outside the workspace · Issue #18558 · openai/codex](https://github.com/openai/codex/issues/18558)
36. [Automate actions with hooks - Claude Code Docs](https://code.claude.com/docs/en/hooks-guide)
37. [How Many Instructions Can LLMs Follow at Once? · Pith Review](https://pith.science/paper/2507.11538)
38. [Does AGENTS.md Actually Help Coding Agents? A New Study Has Answers](https://academy.dair.ai/blog/agents-md-evaluation)
39. [Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents? — AI Agents](https://awesomepapers.io/ai-agents/papers/2602.11988)
40. [(PDF) Lost in the Middle: How Language Models Use Long Contexts](https://www.researchgate.net/publication/378284067_Lost_in_the_Middle_How_Language_Models_Use_Long_Contexts)
41. [Large Language Models Can Follow Instructions, But Not Many at Once: Phase Transitions in Compositional Constraint Satisfaction](https://arxiv.org/pdf/2608.12426)
42. [arxiv.org](https://arxiv.org/abs/2507.11538)
43. [Claude Code Memory: End Repetitive Context Setup](https://claudefa.st/blog/guide/mechanics/memory-optimization)
44. [docs.anthropic.com](https://docs.anthropic.com/en/docs/claude-code/memory)
45. [Automate workflows with hooks - Claude Code Docs](https://code.claude.com/docs/en/hooks-guide?8adb0641_page=4&cc61befa_page=2&d7430fcd_page=5&r=0)
46. [Claude Code settings - Claude Code Docs](https://code.claude.com/docs/en/settings?s=03&fcdaa149_sort_date=desc)
47. [Use Claude Code in VS Code - Claude Code Docs](https://code.claude.com/docs/en/vs-code)
48. [Codex Skills: Writing a SKILL.md the Agent Actually Loads](https://www.testmuai.com/blog/codex-skills/)
49. [Windows command hooks fail with OS error 5 when outer shell resolves to Store/MSIX PowerShell · Issue #47810 · openai/codex](https://github.com/openai/codex/issues/47810)
50. [Windows: cmd/PowerShell windows stay visible for each shell command during a session (CLI 0.157.1) · Issue #48876 · openai/codex](https://github.com/openai/codex/issues/48876)
