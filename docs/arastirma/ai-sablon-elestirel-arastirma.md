# ai-sablon — Eleştirel Araştırma ve Değerlendirme

**Araştırma tarihi:** 30 Eylül 2026  
**Kapsam:** Kullanıcının sunduğu şablon özeti; Windows 11, PowerShell 5.1, Claude Code ve OpenAI Codex.  
**Not:** Bu dosya, sohbet içindeki araştırmanın Markdown aktarımıdır. Sohbete özgü kaynak işaretleri, taşınabilir kaynakça numaralarına dönüştürülmüştür. Dosyalar ekli olmadığı için `kur.ps1`, `durum.ps1`, JSON ayarları ve skill içerikleri uygulama düzeyinde denetlenmemiştir.

## Kısa hüküm

**Şablonun temel fikri iyi; mevcut kontrol modeli gereğinden katı.** Modelin “zekâsını düşürdüğünü” söylemek için doğrudan kanıt yok, fakat yoğun ve gereksiz talimatlar görev başarısını artırmadan maliyeti yükseltebiliyor. [1, 4] Araçlar arasında taşınan repo belgeleri, bilgi kaybı problemi için mantıklı bir çözüm. Buna karşılık “tek adım at ve dur”, her değişiklikte onay ve bitmiş kodu dondurma kuralları, modelin düzeltme–test–iyileştirme döngüsünü kesiyor; bu, şablona ilişkin mühendislik değerlendirmesidir. Güvenlikte en önemli zayıflık, doğal dil yasakları ile teknik erişim sınırlarının birbirine karışması: bunlar aynı korumayı sağlamıyor. [13, 14] Şablonu kaldırmak yerine, **kısa ortak kurallar + risk temelli onay + doğrulanabilir devir durumu** biçiminde sadeleştirmek önerilir.

Bu değerlendirme **30 Eylül 2026** tarihinde erişilen kaynaklara ve verilen özete dayanıyor. Aşağıda **kanıt** kaynak bulgusunu, **çıkarım** ise bu şablona uygulanan değerlendirmeyi ifade ediyor.

## 1. Yetenek, akıl yürütme ve talimat yükü

| Araştırma | Ölçülmüş bulgu | Bu şablon için anlamı ve sınırı |
|---|---|---|
| **IFScale**, 15.07.2025 — **6 aydan eski**, arXiv ön baskısı | 20 model, 500’e kadar anahtar sözcük ekleme talimatıyla değerlendiriliyor. En iyi modeller maksimum yoğunlukta yaklaşık **%68** uyum sağlıyor; model boyutu ve reasoning kapasitesiyle ilişkili farklı bozulma örüntüleri bulunuyor. | Çok sayıda talimatın güvenilirliği sınırlı. Ancak **140 satır, 140 bağımsız talimat değildir**; yazı benchmark’ından kod kalitesi kaybı yüzdesi çıkarılamaz. [1] |
| **FollowBench**, 31.10.2023 — **6 aydan eski** | 13 model; içerik, durum, stil, format ve örnek kısıtları, artan zorluk seviyelerinde ölçülüyor. Birden fazla kısıta uyumda eksikler gösteriliyor. | “Türkçe yaz + onay bekle + tek adım + test + belge güncelle” bileşimini tek bir basit talimat gibi düşünmemek gerekir. Bu araç akışını doğrudan test etmiyor. [2] |
| **Lost in the Middle**, 2023 — **6 aydan eski** | Soru cevap ve anahtar–değer retrieval görevlerinde, ilgili bilginin uzun bağlam içindeki konumu performansı etkiliyor; ortadaki bilgiye erişim zayıflayabiliyor. | Uzun `PLAN.md` ve oturum geçmişi, önemli kuralların görünürlüğünü azaltabilir. Bu çalışma güncel coding agent’ları veya bu şablonu ölçmüyor. [3] |
| **Evaluating AGENTS.md**, incelenen **v3: 29.09.2026**, arXiv ön baskısı | SWE-bench ve Python tabanlı CTXbench deneylerinde context dosyaları başarıyı genel olarak anlamlı artırmıyor; inference maliyeti ortalamada **%20’den fazla** yükseliyor. İnsan tarafından hazırlanmış dosyalar, model üretimi dosyalardan daha iyi. | En doğrudan ilgili kanıt bu. “Daha çok belge = daha iyi kod” varsayımını desteklemiyor; standart dışı gerekli bilgileri tutmayı öneriyor. **Devir senaryosunu ve öğrenme faydasını ölçmediği için dosyaları kaldırmayı kanıtlamaz.** [4] |
| **Instruction Stacking Collapse**, 2026 — güncel ön baskı | Üç modelde kısıtlar biriktikçe uyum düşüyor; bazı düşüşler birbirleriyle bağdaşmayan talimat çiftlerinden kaynaklanıyor. | Sadece uzunluğu azaltmak yetmez: çelişkileri de temizlemek gerekir. Çelişkili JSON/format görevlerindeki sonuçları doğrudan coding workflow’a taşımamak gerekir. [5] |

**Haiku sorusunun cevabı:** Küçük modellerin yoğun talimatlarda daha fazla zorlanabileceğine dair genel kanıt var; fakat **bu Türkçe şablonda belirli bir Haiku sürümünün Sonnet/Codex’ten ne kadar az uyacağı doğrulanmadı**. “Küçük model kesin daha az uyar” yerine, aynı görevleri aynı araç izinleriyle karşılaştırmak gerekir. IFScale’deki ilişki, tek başına Haiku’ya özgü sonuç değildir. [1]

## 2. Bulgular tablosu

Tablodaki önem seviyeleri, özete göre yapılan risk değerlendirmesidir.

| Bulgu | Etkilenen parça | Önem | Kanıt ve kaynak | Öneri: hangi dosyada ne değişmeli |
|---|---|---|---|---|
| Her işlem için plan/onay gereğinden geniş | Genel kurallar | Yüksek | Anthropic, küçük ve kapsamı açık değişikliklerde planın ek yük olduğunu açıkça belirtiyor. [12] | Global dosyalarda onayı **kapsam değişikliği, destructive işlem ve dış etki** için zorunlu yap. |
| “Tek adım” belirsiz ve görev döngüsünü kesiyor | Genel kurallar, `PLAN.md` | Yüksek | **Çıkarım:** Bir tool call, dosya değişikliği ve doğrulanmış görev birbirinden farklı birimler. Doğrudan A/B kanıtı yok. | “Onaylanan görev kapsamını tamamla; yeni karar veya kapsam dışı iş çıkarsa dur” biçiminde değiştir. |
| Donmuş kod, iç refactor ile API kırılmasını aynı sayıyor | Aşama yalıtımı | Yüksek | SemVer public API uyumluluğunu düzenler; bütün eski kaynak dosyalarının değişmezliğini gerektirmez. [26] | `AGENTS.md`: davranış koruyan refactor serbest; public API kırılması ve veri migration’ı onaylı olsun. |
| Her adımda bütün testler ölçeklenmiyor | Genel kurallar, Python eki | Orta–yüksek | **Çıkarım:** `s` adım ve tam test süresi `T` için yalnız test maliyeti yaklaşık `s×T`. | Adımda ilgili testler; görev sonunda gerekli regresyon; merge/CI aşamasında tam suite. |
| Claude ve Codex aynı dosyaları otomatik okumuyor | Belge haritası, `/basla` | Yüksek | Codex’in belgelenmiş otomatik keşfi `AGENTS.md` zinciridir; genel bir Claude `@import` eşdeğeri belirtilmiyor. [15] | `AGENTS.md` içine `/basla` için **DEVAM + aktif plan bölümü** okuma talimatı koy; yüklenmesini test et. |
| Tarih karşılaştırması devir doğruluğunu kanıtlamıyor | `durum.ps1`, `DEVAM.md` | Yüksek | **Çıkarım:** Yeni timestamp yanlış içeriği gizleyebilir; checkout dosya zamanlarını değiştirebilir. | Devirde `HEAD`, branch, çalışma ağacı durumu ve doğrulanmış test bilgisi sakla. Tarihi yardımcı sinyal yap. |
| Yalnız modelin gördüğü uyarı denetimi eksik bırakıyor | SessionStart, `/basla` | Orta | Claude hook çıktısı bağlama eklenebilir; bu, kullanıcının uyarıyı okuduğunu göstermez. [9] | `/basla`, bulunan uyarıları kullanıcıya kısa biçimde aktarsın. |
| İki global kopya zamanla ayrışabilir | `kur.ps1`, global kurallar | Orta | **Çıkarım:** Kopyaların aynı kalması bir bakım şartı. | Tek kaynak dosyadan iki hedef üret; sürüm/checksum koy; elle iki ayrı kopyayı düzenleme. |
| `Read(./.env)` kapsamlı secret koruması değildir | İzinler | Kritik | İzinler araç/komut düzeyindedir; OS izolasyonu ayrı katmandır. [13, 14] | `.env.*`, diğer secret yolları, shell/interpreter erişimi ve inherited environment için ayrı tehdit modeli oluştur. |
| Windows’ta Bash kuralları kullanılan tool’u karşılamayabilir | `.claude/settings.json` | Yüksek | Güncel Claude, ayrıca `PowerShell(...)` kuralları belgeliyor. [10] | Gerçekte kullanılan tool adını doğrula; ilgili Bash ve PowerShell kurallarını ayrı test et. |
| Kullanıcı ayarlarını yedekleyip tamamen değiştirmek hâlâ riskli | `kur.ps1` | Yüksek | **Çıkarım:** Yedek, mevcut izin/plugin/ayarların aktif yapılandırmadan silinmesini önlemez. | Dry-run, diff, seçici merge, geçici dosya üzerinden yazma ve rollback ekle. |
| `KARARLAR.md` değişmezliği eski kararları yürürlükte gösterebilir | `/karar` | Orta | ADR yaklaşımı kararın bağlamını ve sonuçlarını kaydeder. [25] | Yeni kayıtta “K-003’ü geçersiz kılar” ilişkisi; etkin kararlar için kısa indeks tut. |
| Global “AI imzası yok” ekip politikasına uyumsuz olabilir | Genel kurallar | Düşük–orta | **Çıkarım:** Kişisel tercih her repo için doğru politika olmayabilir. | “Repo politikası yoksa ekleme” yap. Git kimliğini değiştirmeme kuralını koru. |

### “Tek adım” ve onay ne zaman yararlı?

**Öğrenme sırasında**, anlaşılmayan bir algoritma, migration veya mimari karar üzerinde durmak yararlı olabilir. **Rutin uygulamada** ise okuma → değişiklik → test → hata düzeltme zincirinin her parçasında durmak, işi yarım bırakır. Bu ayrımın kullanıcının öğrenme başarısına etkisi ölçülmedi; öğretim ve mühendislik çıkarımıdır.

Önerilen iki çalışma biçimi:

- **Öğrenme:** Anlamlı bir değişiklik yap, gerekçesini açıkla, sonra dur.
- **Uygulama:** Onaylanmış görevi test ve düzeltmelerle tamamla; yeni karar gerektiğinde dur.

Anthropic’in kendi önerisi de keşif/planlama ile uygulamayı ayırıyor, ancak küçük değişikliklerde planı atlamayı destekliyor. [12]

### Aşama yalıtımı neye dönüşmeli?

**Aşama, zaman sınırıdır; modül ise mimari sınırdır.** Bunları eşitlemek, sırf eski aşamada yazıldı diye kötü bir abstraction’ı korumaya zorlayabilir. Bu, şablonun tasarımına ilişkin çıkarımdır.

Açık-kapalı ilkesini “eski dosyaya dokunma” biçiminde yorumlamamak gerekir. Public API kararlılığı, iç uygulamanın refactor edilebilmesiyle uyumludur. SemVer de yayımlanmış sürümü değiştirmemeyi ve public API değişikliklerini sürümlemeyi söyler; yeni sürümde iç kodu değiştirmeyi yasaklamaz. [26]

`asama-N` etiketi **geri dönülebilir checkpoint** olarak korunmalı; değişiklik yasağının dayanağı yapılmamalı.

## 3. Teknik doğrulama

Aşağıdaki resmî belgeler **30.09.2026’da kontrol edildi**. Yayın/güncelleme tarihi açıkça belirlenemeyen belgelerde erişim tarihi veriliyor; bu, yayın tarihi değildir.

| Konu | Doğrulanan davranış | Şablona etkisi |
|---|---|---|
| Claude yükleme ve birleşme | User/proje/yerel dosyalar bağlama eklenir; çalışma dizininin üstündekiler başlangıçta, alt dizinlerdekiler gerektiğinde yüklenir. Metin kuralları hard enforcement değildir. | Global/proje çelişkilerinde deterministik “son dosya kesin kazanır” varsayma. [6] |
| Claude `@import` | Göreli yol, import eden dosyaya göre çözülür; recursive import sınırı **dört hop**. Import edilen içerik de bağlam maliyetine girer. | `@PLAN.md` bütün büyüyen planı yükleyebilir. [6] |
| Claude artık `AGENTS.md` okuyabiliyor | Güncel belgelerde sürüm ve built-in plugin koşullarıyla doğrudan destek var. `@AGENTS.md` workaround’u kalabilir; belge aynı içeriğin iki kez yüklenmediğini söylüyor. | Eski “Claude AGENTS okumaz” varsayımını kurulumdan çıkar; sürüm uyumluluğunu belirt. [6] |
| Claude otomatik hafıza | Proje ayarında `"autoMemoryEnabled": false` belgelenmiş. | Geçerli tercih; fakat öğrenilmiş kişisel düzeltmelerin otomatik saklanmasını da kapatır. [6] |
| Claude SessionStart | Plain-text stdout bağlama eklenir; JSON ile `hookSpecificOutput.additionalContext` kullanılabilir. Başlangıç/resume/compact gibi kaynaklara matcher uygulanır. | Kancanın uyarı vermesi işi engellemez. **SessionStart stdout için kesin sayısal üst sınır doğrulanmadı.** [9] |
| Claude izin sözdizimi | `Bash(git push *)`, `PowerShell(...)`, `Read(./.env)` türleri belgelenmiş. Öncelik **deny → ask → allow**. | Ask, deny’ı açmaz; dar allow, geniş deny’a istisna oluşturmaz. [10] |
| Claude attribution | Resmî indeks `attribution` ve `attribution.commit` anahtarlarını listeliyor; ayrıntılı referans sayfası bu araştırma oturumunda alınamadı. | **Türü ve kapatma değeri tam doğrulanamadı.** “Attribution kapalı” özeti JSON denetimi için yeterli değil; `false` değeri doğrulanmış örnek olarak verilmiyor. [8] |
| Codex global/proje talimatları | Globalde önce `AGENTS.override.md`, yoksa `AGENTS.md`; proje kökünden CWD’ye doğru her dizinde en fazla bir dosya seçilir ve birleştirilir. | Override varsa normal dosya global seviyede birlikte yüklenmez. [15] |
| Codex boyut sınırı | `project_doc_max_bytes` varsayılanı **32 KiB**. | Bu byte sınırıdır; satır/token sınırı değildir. İç içe bölmek aynı keşif zincirinin toplam sınırını otomatik kaldırmaz. [15] |
| Codex skill yolları | Güncel belgede kullanıcı için `~/.agents/skills`, repo için `.agents/skills` var. | `~/.codex/skills` güncel belgede listelenmiyor; mevcut sürümde çalışması ayrıca denenmeli. [16] |
| Codex SKILL.md | `name` ve `description` gerekli; başta metadata, gerektiğinde tam içerik yüklenir. Açık çağrı CLI/IDE’de `$skill` veya `/skills` üzerinden belgelenmiş. | Claude’daki `/basla` çağrısını birebir taşınabilir kabul etme. [16] |
| Codex kancaları | Güncel belgede SessionStart dâhil hook desteği var. SessionStart stdout ek developer context olabilir; `additionalContextLimit` varsayılanı yaklaşık **2500 token**. Cloud/local kapsamları farklı. | `durum.ps1` için Codex adapter’ı mümkün; Claude JSON’unu aynen kopyalamak yeterli değil. [17] |

**Varsayılanlarla çatışma:** Ayar önceliği ile modelin metin talimatına uyumu farklı konular. Claude’un izin sistemi çağrıyı teknik olarak engelleyebilir; “imza ekleme” gibi metin tercihi ise model davranışıdır. Commit/PR attribution ayarının çalışması da Git GPG/SSH imzasını kapatmakla aynı şey değildir. Şablonda bu kavramlar ayrı yazılmalı.

### Aynı SKILL.md iki araçta çalışır mı?

**Yalnız Markdown prosedürü ve ortak `name`/`description` metadata’sıyla büyük ölçüde gerçekçi.** Claude’a özgü `$ARGUMENTS`, `context: fork`, `allowed-tools`, `disable-model-invocation` veya tool isimleri kullanılırsa taşınabilirlik azalır. Claude, tanımadığı frontmatter alanlarını sessizce yok sayabilir; dolayısıyla “dosya yüklendi” bütün davranışların uygulandığı anlamına gelmez. [11]

Tercih: **tek ortak prosedür, iki küçük araç adapter’ı**. `/devir`, `/karar` ve `/yeni-proje` gibi yazan skill’lerin otomatik tetiklenme davranışı iki araçta ayrıca sınanmalı.

### Windows + PowerShell 5.1

- `>` ve `Out-File` varsayılan olarak **UTF-16LE** yazabilir; `Set-Content` varsayılanı aynı değildir.
- PowerShell 5.1’de `-Encoding UTF8`, **BOM’lu UTF-8** üretir.
- BOM’suz, Türkçe karakterli `.ps1` kaynakları ANSI olarak yorumlanabilir.
- `$OutputEncoding`, dosyaya yazma encoding’ini belirleyen genel çözüm değildir. [18]

Bu nedenle `kur.ps1` için tek bir “her şey UTF-8 BOM’suz” kuralı konulmamalı: **PS5.1 betikleri ve Markdown/JSON dosyaları ayrı ele alınmalı**. `&&`/`||` kullanan PowerShell 7 örnekleri de 5.1’e taşınmamalı.

Satır sonlarını kullanıcıların global `core.autocrlf` ayarına bırakmak yerine repo içinde `.gitattributes` ile belirlemek daha tekrarlanabilir. Git belgeleri `text`/`eol` ile repo ve çalışma ağacı dönüşümlerini tanımlıyor. [19]

## 4. Güvenlik ve dayanıklılık

**İzin listesi işe yarar; güvenlik sınırının tamamı değildir.** Güncel Claude, PowerShell AST’sini ayrıştırıp compound komutların alt komutlarını ayrı denetlediğini belgeliyor. Bu yüzden “`;` veya pipeline eklenince mutlaka aşılır” iddiası yanlış olur. Ancak eşleşen komut metni ile o komutun bütün runtime davranışları aynı şey değildir. [10]

Şablona özgü açıklar:

- `git add .` yasağı, `git add -A` veya başka staging yöntemleriyle aynı sonucu engellediğini kanıtlamaz. **Asıl kontrol**, staged dosyalar ve staged diff’in onaylanması olmalı.
- `.env` dışında secret dosyaları, environment variable’lar, loglar ve kopyalar bulunabilir.
- İzin verilen `python`, test runner veya script, başka dosyalara erişebilir. Test çalıştırmak da kod çalıştırmaktır.
- Modelin kendi kural/izin dosyalarını değiştirmesi korumayı zayıflatabilir; bu dosyaların değişiklikleri ayrıca incelenmeli.

Bunlar doğrulanmış exploit iddiaları değil, özete göre test edilmesi gereken erişim yollarıdır. Anthropic de tam bağışıklık iddiasında bulunmuyor ve komut metninden bağımsız filesystem/network enforcement için sandbox katmanını ayırıyor. Ayrıca Claude’un bu sandbox’ı **native Windows’ta desteklenmiyor; WSL2 destekleniyor**. [13, 14]

`kur.ps1` için yedeklemeye ek olarak şunlar gerekli:

1. Yazmadan önce hedef dosya ve diff gösterimi.
2. Var olan kullanıcı ayarlarını koruyan seçici merge.
3. JSON parse/schema kontrolü; PowerShell JSON serialization depth’inin açık belirlenmesi.
4. Yarım yazmaya karşı geçici dosya ve kontrollü değiştirme.
5. Tekrar çalıştırmada aynı sonucu veren idempotency.
6. Restore komutu ve kurulum manifest’i.

Betik görülmediği için bunların hangilerinin eksik olduğu **bilinmiyor**.

## 5. Belge yükü ve benzer yaklaşımlar

**Dört belge farklı amaçlar taşıyor; sorun hepsinin sürekli güncellenmesi ve yüklenmesi.** Aşağıdaki bakım sayıları, verilen yapının işleyişinden çıkarımdır.

| Belge | Önerilen görev | Güncelleme zamanı |
|---|---|---|
| `AGENTS.md` | Sabit kurallar, komutlar, belge haritası | Kural/altyapı değişince |
| `PLAN.md` | Aktif iş ve kabul kriterleri | Görev durumu değişince |
| `KARARLAR.md` | Önemli karar, alternatif, sonuç | Gerçek karar alınca |
| `DEVAM.md` | Şu anki durum ve ilk sonraki işlem | Devir/oturum sonunda |
| `GUNLUK.md` | İsteğe bağlı kişisel öğrenme kaydı | Öğrenme notu varsa |

Mevcut yapıda sıradan oturum sonunda **PLAN + GUNLUK + DEVAM = üç dosya**, karar çıkarsa dört dosya yazılabilir. Bunu **PLAN + DEVAM** düzeyine indirmek; karar kaydını gerektiğinde eklemek önerilir. Günlük, görev durumunun ikinci kopyası yapılmamalı.

Kesin token sayısı dosyalar olmadan hesaplanamaz:

```text
C_başlangıç = C_global + C_proje + C_yüklenen_plan
            + C_devir + C_hook + C_skill_metadata
```

İki aracın ayrı oturumlarında aynı kuralların yüklenmesi toplam tüketimi artırır; fakat aynı anda çalışmadıkları için iki global kopya tek bağlamda otomatik iki kat yük oluşturmaz. **60 satır da token bütçesi değildir**: uzun satırlar sınırı anlamsızlaştırabilir.

| Yaklaşım | Şablonla karşılaştırma |
|---|---|
| **AGENTS.md** | Ortak Markdown formatı zaten var. Şablonun ek değeri devir ve durum doğrulaması; eksik tarafı araçlar arasındaki yükleme farklarını açık tanımlamamak. [20] |
| **Cursor rules** | Dosya/pattern ve relevance bazlı yükleme sunuyor. Şablondaki global Python/Windows ayrıntılarını gerektiğinde yükleme fikri buradan alınabilir. [21] |
| **GitHub Spec Kit** | Specification → plan → tasks → implementation zinciri kuruyor. Şablonda kontrol ayrıntılı; kabul kriterleri ve doğrulanabilir beklenen davranış daha zayıf tanımlanmış. [22] |
| **BMAD** | Güncel doküman farklı büyüklüklerde işe farklı başlangıç yolları sunuyor; küçük düzeltmede planlama atlanabiliyor. Şablonun tek tip süreç kuralı daha katı. [23] |
| **Aider conventions** | Read-only convention dosyalarıyla daha hafif yönlendirme. Şablonun devir yapısı daha güçlü; bakım yükü daha yüksek. [24] |
| **Claude memory/plan** | Araç içi özellikler pratik; repo belgeleri araç değişiminde taşınabilir. İkisi kullanılırsa hangi bilginin authoritative olduğu belirtilmeli. [6, 12] |
| **ADR** | `KARARLAR.md` yakın bir yaklaşım. Karar numarasına ek olarak bağlam, alternatifler, sonuçlar ve yerine geçen karar ilişkisi gerekli. [25] |

## 6. Proje türüne göre uygunluk

Bu tablo benchmark sonucu değil, şablon kuralları üzerinden uygunluk değerlendirmesidir.

| Proje türü | Mevcut hâli | Gerekli uyarlama |
|---|---|---|
| Tek kişilik öğrenme projesi | **Uygun, fazla katı** | Öğrenme/uygulama modlarını ayır; açıklama gerektiren noktada dur. |
| Küçük web uygulaması | **Koşullu uygun** | Refactor’ı serbestleştir; API, migration, auth ve deployment risklerini ayrı yönet. |
| Veri/ML betikleri | **Koşullu uygun** | Dataset/model sürümü, seed, environment ve deney sonucu kaydı ekle; pahalı testleri her adımda çalıştırma. |
| Ekip projesi | **Zayıf** | Ortak kuralları version control’a al; kişisel tercihleri ayır; PR/CI sürecini esas al. |
| Büyük monorepo | **Uygun değil** | Paket bazlı talimatlar, ilgili test seçimi ve scoped context gerekir. |
| Prototip/hackathon | **Fazla ağır** | Kısa talimat + devir; sürekli onay ve aşama dondurma kaldırılmalı. |
| Kodsuz belge projesi | **Kısmen uygun** | Git/test/aşama kurallarını çıkar; kaynak, revizyon ve teslim kriterlerini kullan. |

## 7. Kaldırılacak, gevşetilecek ve eklenecek kurallar

### Kaldır

- **Her tool call veya küçük değişiklik sonrası durma:** Görev tamamlamayı parçalar.
- **Her adımda tüm testler:** Ölçeklenebilir değil; test kapsamını riskle eşleştir.
- **Biten aşamanın bütün kodunu donmuş kabul etme:** Zaman sınırını mimari sınır yapıyor.
- **Her oturumda zorunlu günlük:** Devir ve planın tekrarına dönüşüyorsa faydası düşük.
- **“Bilgi uydurma”yı güvence gibi sunma:** Bunun yerine bilinmeyeni işaretleme ve doğrulama prosedürü yaz.

### Gevşet

- **Plan/onay:** Belirsiz veya kapsamlı görev başında; rutin işte kısa kapsam bildirimi yeterli.
- **Yeni bağımlılık:** Yeni production dependency ve major upgrade onaylı; önceden kabul edilen dev-tool kurulumu proje politikasına bağlı.
- **Dış sistem komutları:** Production yazma/deploy onaylı; public doküman okuma ile aynı sınıfa koyma.
- **60 satır:** Hedef olarak koru; kritik bilgiyi kesmek yerine içerik/token bütçesi uygula.
- **AI attribution:** Kişisel varsayılan yap; repo politikasına uyarlanabilir olsun.

### Ekle

- **Her görev için kabul kriteri:** Ne değişince tamam sayılacak?
- **Devir kimliği:** Repo, branch, `HEAD`, dirty durum.
- **Doğrulama kanıtı:** Test komutu, sonuç ve test edilen kod durumu.
- **İddia ayrımı:** Doğrulandı / denenmedi / varsayım.
- **Kapsam sınırı:** İzin verilen değişiklik alanı ve durmayı gerektiren koşullar.
- **Kural dosyası değişikliği incelemesi:** Model kendi izinlerini sessizce genişletmesin.
- **Kurulum sürümü ve uyumluluk matrisi:** Claude/Codex sürümü, native Windows/WSL, kullanılan shell.

Git kimliğini değiştirmeme, kullanıcı değişikliklerini ezmeme, kör silmeme, seçici staging ve push için ayrı onay kuralları korunmalı.

## 8. Doğrulanamayanlar ve deney planı

### Doğrulanmadı

- `attribution` ayarının şablondaki JSON dosyasında kullanılan türü ve gerçek etkisi.
- Claude SessionStart stdout’unun kesin sayısal bağlam sınırı.
- Kurulu Codex sürümünde `~/.codex/skills` keşfi.
- Dört skill’in iki araçta aynı çağrı ve yan etki davranışı.
- `durum.ps1` tarih/Git parsing doğruluğu ve gerçekten salt okunur olması.
- Şablonun Haiku’ya özgü uyum oranı.
- Şablonun token veya süre tasarrufu yüzdesi.

### Deney planı

| Deney | Nasıl ölç |
|---|---|
| Tam şablon vs sade şablon | Aynı başlangıç commit’inden bugfix, feature ve refactor görevleri; kabul testleri, süre, token, onay sayısı, kapsam dışı diff. Görev/model başına tekrarla. |
| Gerçek araç devri | Bir araçta işi yarım bırak; diğerine yalnız repo ve devir notunu ver. Sonraki adımı ve bilinmeyenleri doğru çıkarıp çıkarmadığını ölç. |
| Güncellik kontrolü | Devirden sonra commit, untracked dosya, staged değişiklik, silme, branch değişimi ve future timestamp senaryolarını dene. |
| İzinler | Gerçek secret yerine sahte `.env`; Read, shell, interpreter, farklı yol ve command chain denemelerinde block/ask/allow sonucunu kaydet. |
| Encoding | Türkçe karakter, boşluklu yol, BOM’lu/BOM’suz dosya; PS5.1 ve CI okumasını karşılaştır. |
| Kurulum | Önceden dolu ayarlar, bozuk JSON, ikinci çalıştırma, yarım yazma ve rollback. |

“Sıfır halüsinasyon” veya “%80 tasarruf” için şablona özgü kanıt yok. Böyle bir iddia ancak tanımlanmış görevler, baseline, model/araç sürümleri ve başarısızlık ölçütleriyle anlamlı olur.

## 9. Kaynakça

**Tarih notu:** Aşağıdaki canlı ürün belgelerinin erişim tarihi **30.09.2026**; ayrıca belirtilmedikçe yayın/güncelleme tarihleri doğrulanamadı. “6 aydan eski” işareti, araştırmaların yayın tarihine uygulanmıştır.

| No | Kaynak | Adres | Tarih |
|---|---|---|---|
| 1 | IFScale — How Many Instructions Can LLMs Follow at Once? | https://arxiv.org/abs/2507.11538 | 15.07.2025 — **6 aydan eski** |
| 2 | FollowBench | https://arxiv.org/abs/2310.20410 | 31.10.2023 — **6 aydan eski** |
| 3 | Lost in the Middle | https://arxiv.org/abs/2307.03172 | 06.07.2023; revizyon 20.11.2023 — **6 aydan eski** |
| 4 | Evaluating AGENTS.md — incelenen v3 | https://arxiv.org/html/2602.11988v3 | 29.09.2026 |
| 5 | Instruction Stacking Collapse | https://arxiv.org/abs/2608.02639 | 2026; arXiv kaydındaki gönderim 31.07.2026 |
| 6 | Claude memory | https://code.claude.com/docs/en/memory | Erişim 30.09.2026 |
| 7 | Claude settings precedence | https://code.claude.com/docs/en/settings | Erişim 30.09.2026 |
| 8 | Claude settings reference | https://code.claude.com/docs/en/settings-reference | Erişim 30.09.2026; tam içerik alınamadı, indeks kısmen görüldü |
| 9 | Claude hooks | https://code.claude.com/docs/en/hooks | Erişim 30.09.2026 |
| 10 | Claude permissions | https://code.claude.com/docs/en/permissions | Erişim 30.09.2026 |
| 11 | Claude skills | https://code.claude.com/docs/en/skills | Erişim 30.09.2026 |
| 12 | Claude best practices | https://code.claude.com/docs/en/best-practices | Erişim 30.09.2026 |
| 13 | Claude security | https://code.claude.com/docs/en/security | Erişim 30.09.2026 |
| 14 | Claude sandbox | https://code.claude.com/docs/en/sandboxing | Erişim 30.09.2026 |
| 15 | Codex AGENTS.md | https://learn.chatgpt.com/docs/agent-configuration/agents-md | Erişim 30.09.2026 |
| 16 | Codex skills | https://learn.chatgpt.com/docs/build-skills | Erişim 30.09.2026 |
| 17 | Codex hooks | https://learn.chatgpt.com/docs/hooks | Erişim 30.09.2026 |
| 18 | PowerShell character encoding — Microsoft Learn | https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-5.1 | Erişim 30.09.2026 |
| 19 | Git gitattributes | https://git-scm.com/docs/gitattributes | Erişim 30.09.2026 |
| 20 | AGENTS.md | https://agents.md/ | Erişim 30.09.2026 |
| 21 | Cursor rules | https://cursor.com/docs/rules | Erişim 30.09.2026 |
| 22 | GitHub Spec Kit | https://github.com/github/spec-kit | Erişim 30.09.2026 |
| 23 | BMAD | https://docs.bmad-method.org/ | Erişim 30.09.2026 |
| 24 | Aider conventions | https://aider.chat/docs/usage/conventions.html | Erişim 30.09.2026 |
| 25 | Architectural Decision Records | https://adr.github.io/ | Erişim 30.09.2026 |
| 26 | Semantic Versioning 2.0.0 | https://semver.org/spec/v2.0.0.html | Erişim 30.09.2026; sürüm **6 aydan eski** |
