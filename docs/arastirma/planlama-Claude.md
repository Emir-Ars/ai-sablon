# Yapay Zekâ Ajanıyla Araştırmadan Proje Planı: Taslak Yöntemin Değerlendirmesi ve Yeniden Yazılmış Planlama Kuralı

Taslak yöntemin doğru yolda, ama gereğinden ağır: planın az değişmesini en çok üç şey sağlıyor ve üçü de taslakta ya eksik ya zayıf kalmış. Bunlar: (1) riskli varsayımları ilk aşamada, çalışan ince bir uçtan uca iskeletle sınamak; (2) her plan maddesinin nereden geldiğini etiketlemek ve varsayımları aşama başlarında yeniden kontrol etmek; (3) eleştiriyi planı yazan oturumdan ayrı, yeni bir bağlamda yaptırmak.

## TL;DR

- **Hüküm:** Taslak iyi bir başlangıç, fakat 0.3 (kararlar), 0.4 (spike) ve 0.5 (plan + pre-mortem + kapsama + ikinci model) ayrı ayrı adımlar olarak fazla seremoni yaratıyor. Bunları "karar + risk → ilk aşama = riskli varsayımları sınayan walking skeleton → uzak aşamalar kaba" şeklinde sıkıştır. Ölçümlü kanıt şunu gösteriyor: ayrı bir spec/plan aşaması en çok zor ve çok kısıtlı işlerde fayda sağlıyor, kolay işlerde kazancın büyük kısmı "önce düşün" etkisinden geliyor.
- **En önemli 3 değişiklik:** (a) Planı sabit bir prosedür yerine, varsayımların sınandığı ve erken kırıldığı bir yapı olarak kur (iskelet + varsayım tablosu + aşama başı kontrol noktası). (b) Her maddeye `[B]` belge / `[Ö]` ajan önerisi / `[V]` varsayım etiketi koy, belgeyle çelişen önerileri gerekçesiyle ayrı listele. (c) Pre-mortem ve eleştiriyi aynı oturumda değil, yeni bir oturumda ya da Codex'te yaptır.
- **Kural dosyası:** AGENTS.md'deki planlama kuralı kısa olmalı (~30-40 satır). "Zorunlu adım" değil "ilke + kontrol noktası" olarak yazılmalı ve ajanın adım atlamasına izin vermeli, ama atladığını gerekçesiyle söylemesini istemeli. Bağlam dosyalarının fazla ve gereksiz talimatla şişirilmesi ölçümlerde başarıyı artırmıyor, maliyeti artırıyor.

## 1. Kısa hüküm

Taslak yöntemin iskeleti (anla → karar/risk → dene → planla → onayla) Claude Code, Codex, Cursor, Kiro ve Spec Kit belgelerinin önerdiği "önce keşfet, sonra planla, sonra kodla" akışıyla uyumlu.\[1\]\[2\] Temel sorun sıra değil, adım sayısı ve ağırlığı. Tek kişilik bir Python projesinde 0.2-0.5'i ayrı onay kapıları olarak işletmek, Böckeler'in Kiro ve Spec Kit'te gözlediği "küçük işe balyoz" sorununu yeniden üretir.\[3\]\[4\] Planın geç değişmesinin asıl nedeni genellikle ayrıntı eksikliği değil, sınanmamış varsayımlardır. Bu yüzden en yüksek getiri, riskli varsayımları ilk aşamada çalışan kodla kırmaktan gelir. İkinci neden, belgeden gelen bilgiyle ajanın tahmininin karışmasıdır: hangi maddenin çürüyebileceğini göremezsin. Üçüncü neden, planı yazan bağlamın kendi planını eleştirmesidir. Aynı oturumda öz-eleştiri zayıf; bağlamı ayırmak ölçülebilir fark yaratıyor. Önerdiğim üç değişiklik: **(1) 0.4 ile 0.5'teki walking skeleton'ı birleştir; ilk aşama riskli varsayımları sınasın. (2) Kaynak etiketi + varsayım tablosu + aşama başı yeniden gözden geçirme ekle. (3) Pre-mortem ve kapsama kontrolünü, planı yazmayan yeni bir oturuma veya Codex'e ver.**

## 2. Taslak yöntemin adım adım eleştirisi

| Adım | Karar | Gerekçe ve kaynak |
|---|---|---|
| 0.1 Araştırmayı klasöre koy | **Tut, küçük ek** | Gerekli. Ek olarak her belgenin başına üretim tarihi ve kaynağı yazılsın ki ajan eskimişliği değerlendirebilsin. Uzun belgelerde "ortada kalan" bilgi daha az kullanılıyor. Liu vd., "Lost in the Middle" (TACL 2024; arXiv 2023, **12 aydan eski**) bunu çok belgeli soru-cevapta ölçtü.\[5\]\[6\] Bu yüzden çok uzun belgeler için bölüm başlıklı yapı veya kısa bir özet dosyası işe yarar. |
| 0.2 Anlama özeti + sorular + onay | **Tut, değiştir** | Soru sorma kanıtla destekleniyor. "Ask or Assume?" (Edwards & Schuster, arXiv 2603.26233, Mart/Haziran 2026) çalışmasında eksik tanımlı SWE-bench Verified'da Claude Sonnet 4.5 ile gizli bilgi koşulu %54,80, tam tanımlı koşul %70,80 çözdü. Belirsizliğe duyarlı çok-ajanlı soru soran düzen %69,40'a çıktı.\[7\] Ancak AMBIG-SWE (arXiv 2502.13069, ICLR 2026; v1 Şubat 2025, **12 aydan eski**) modellerin iyi ve eksik tanımlı talimatı ayırt etmekte zorlandığını buldu.\[8\] Değişiklik: gereksinimleri `[B]/[Ö]/[V]` etiketiyle yaz, tek turda yüksek etkili az soru sor, cevaplanmayanları `[V]` olarak ilerlet. Spec Kit'in `[NEEDS CLARIFICATION]` işaretleri aynı fikir.\[9\]\[10\] |
| 0.3 Kararlar ve riskler | **Tut, 0.2 ile aynı çıktıda birleştir** | Karar kaydı değerli. ExecPlan şablonunda (OpenAI Cookbook) "Decision Log" zorunlu bölüm.\[11\] Ama alternatif-ölçüt-gerekçe tablosunu yalnız geri dönüşü pahalı kararlara uygula (veri modeli, dış kütüphane/API, dosya formatı, eşzamanlılık modeli). Her karar için tam ADR yazmak bürokrasi. Plan kalitesine etkisi için ölçüm bulunamadı. |
| 0.4 Spike | **İsteğe bağlı yap; iskelete kat** | ExecPlan rehberi "significant unknowns" için prototip/toy implementation milestone'ları ve kütüphaneleri birbirinden bağımsız sınayan spike'lar öneriyor. Terfi veya atılma ölçütü de açıkça yazılmalı.\[11\] Çoğu risk (kütüphane davranışı, veri formatı, performans) ilk aşamadaki uçtan uca iskelette zaten sınanabilir. Ayrı ve atılacak spike'ı yalnız iskelette sınanamayan ya da iskeleti belirleyen varsayım için kullan. Yapay zekâ destekli geliştirmede spike'ın etkisine dair kontrollü ölçüm bulunamadı. |
| 0.5a Ana başlıklar (amaç, arayüz, bitti ölçütü, bağımlılık) | **Tut, "bitti"yi çalıştırılabilir yap** | Claude Code belgesi, ajana çalıştırabileceği bir kontrol vermeyi en yüksek kaldıraçlı pratik olarak sunuyor. En faydalı spec'lerin "dosya ve arayüzleri adlandırdığını, kapsam dışını belirttiğini ve uçtan uca doğrulama adımıyla bittiğini" söylüyor.\[1\] ExecPlan de kabulü "insanın doğrulayabileceği davranış" olarak ifade etmeyi istiyor.\[11\] "Bitti" = komut + beklenen çıktı/test. |
| 0.5b Rolling wave | **Tut** | Uzak aşamaları ayrıntılandırmak, henüz öğrenilmemiş bilgiye dayalı ayrıntı üretir. Bu ayrıntılar her keşifte yeniden yazılır. Böckeler (martinfowler.com, 15 Ekim 2025) Spec Kit'le "3-5 puanlık" bir hikâyeyi denediğinde üretilen markdown yığını yüzünden "I never even finished the full implementation" diyor ve özelliği "plain" AI destekli kodlamayla yapabileceğini belirtiyor. Bu, ayrıntının kendisinin bakım maliyeti olduğunu gösteriyor. Uzak başlığa sadece amaç, çıktı arayüzü taslağı ve açık riskleri yaz. |
| 0.5c Walking skeleton | **Tut, merkeze al** | İlk aşama uçtan uca en ince çalışan yol olsun ve en riskli varsayımları bilerek üstlensin. Anthropic'in uzun süreli ajan harness yazısı (Kasım 2025) da işi özellik listesine bölüp oturum başına tek özellik ilerlemenin, "fazla şeyi birden yapma" eğilimini gidermede kritik olduğunu raporluyor.\[12\] Walking skeleton'ın yapay zekâ ortamında ölçülmüş etkisi: ölçüm bulunamadı (gerekçe mühendislik pratiği ve deneyim raporu). |
| 0.5d Pre-mortem + kapsama kontrolü | **Tut, ama ayrı bağlamda** | Pre-mortem'in dayandığı Mitchell, Russo & Pennington (1989) bulgusu sık sık "%30 daha doğru" diye aktarılıyor. Oysa Jason Collins'in ders notlarına göre çalışma üretilen **neden sayısında** yaklaşık %30 artış ölçtü ve "did not assess the quality of the reasons"; Klein'ın HBR 2007'deki "increases the ability to correctly identify reasons for future outcomes by 30%" ifadesi bu yüzden abartılı. Yani "%30 daha iyi risk tespiti" iddiası abartılı. LLM planlarında pre-mortem'e özgü ölçüm bulunamadı. Kapsama kontrolü mekanik ve faydalı: her `[B]` gereksiniminin bir aşamaya ve bir teste bağlanması. Spec Kit `/speckit.analyze` bunu spec, plan ve görevler arasında yapıyor.\[13\]\[14\]\[15\]\[16\] |
| 0.5e İkinci modele eleştirtme | **İsteğe bağlı değil, "yeni bağlamda eleştiri" olarak varsayılan yap; farklı model bonus** | Aynı bağlamda öz-düzeltmenin zayıflığı sağlam biçimde belgelenmiş (Huang vd., ICLR 2024; Stechly vd., arXiv 2402.08115; ikisi de **12 aydan eski**).\[17\]\[18\] Cross-Context Review (arXiv 2603.12123, Mart 2026, tek yazar, hakemsiz) 360 incelemede yeni oturumda incelemeyi F1 %28,6'ya çıkardı; aynı oturumda inceleme %24,6'da kaldı. Aynı oturumda ikinci kez incelemek bir kez incelemeden iyi değildi.\[19\] Mutlak F1 düşük: eleştiri hataların çoğunu yine kaçırıyor. Farklı model mi, aynı model yeni bağlam mı sorusunu plan eleştirisinde doğrudan karşılaştıran çalışma bulunamadı. 2502.19361 (Şubat 2025, **12 aydan eski**) uzun CoT hatalarında modellerin kendi çıktılarını başkalarınınkinden kötü eleştirdiğini raporluyor.\[20\] |
| 0.6 Onaylanınca dosyalara yaz | **Tut** | Claude Code planları varsayılan olarak `~/.claude/plans/` altına yazıyor.\[21\] Resmî Claude Code belgesi ("Explore the .claude directory") bu plan dosyalarının "cleanupPeriodDays or 30 days, whichever is shorter" süresi dolunca silindiğini söylüyor. Planın repo içindeki PLAN.md'de yaşaması doğru. |
| **Eksik: aşama başı yeniden gözden geçirme** | **Ekle** | Değişikliği erkene çekmenin asıl mekanizması bu. Her ana başlığa girerken varsayım tablosu ve sonraki 1-2 aşamanın arayüzü gözden geçirilir. ExecPlan'deki "Surprises & Discoveries" ve "Decision Log" bölümleri aynı işlevi görüyor.\[11\] |
| **Eksik: sapma kuralı** | **Ekle** | Uygulama plandan saparsa ajan durup planı güncellemeyi önerir, sessizce doğaçlama yapmaz. Claude Code belgesi aynı konuda iki kez düzeltme yaptıysan bağlamı temizleyip daha iyi bir istemle baştan başlamayı öneriyor.\[1\] |

## 3. Önerilen son planlama akışı

Her adımda **A** = ajan, **K** = kullanıcı. `(K-atla)` = küçük projede atlanabilir.

1. **Girdi hazırlığı.** K: belgeleri `docs/arastirma/genel/` altına koyar, her belgenin başına tarih ve kaynak yazar. A: yapmaz.
2. **Anlama + soru turu (plan modunda, Opus).** A: belgeleri okur. Tek bir çıktı üretir: amaç (1 paragraf), kapsam dışı, gereksinimler (her biri `[B: dosya#bölüm]` / `[Ö]` / `[V]` etiketli), ölçülebilir başarı ölçütleri. Belgeyle çelişen veya belgeyi eskimiş bulduğu noktaları "Çelişki/Eskime" listesinde gerekçesiyle ayrıca sunar. Sonra **en fazla ~5-7 yüksek etkili soru** sorar: yalnız cevabı mimariyi, dış arayüzü veya veri modelini değiştirecek olanları. K: cevaplar ya da "sen varsay" der.
3. **Kararlar + varsayım/risk tablosu.** A: geri dönüşü pahalı 2-5 kararı (alternatif, ölçüt, gerekçe) ve varsayımları (etki × belirsizlik) çıkarır. Her yüksek riskli varsayım için "nasıl ve hangi aşamada sınanacak" sütununu doldurur. K: onaylar. `(K-atla)`: 1-2 günlük projede kararları tek satırlık notlarla yaz, tablo kurma.
4. **Plan taslağı.** A:
   - Aşama 1 = walking skeleton: en ince uçtan uca çalışan yol + yüksek riskli varsayımların sınanması.
   - Aşamaların her biri için amaç, dışa açık arayüz (yalnız aşama sınırını geçenler), "bitti" = çalıştırılabilir komut/test, bağımlılık.
   - Sadece Aşama 1 adımlara bölünür. Uzak aşamalar 2-3 satırda kalır.
   - İskelette sınanamayan bir risk varsa ayrı spike önerir (süre sınırı, atma/terfi ölçütü).
5. **Bağımsız eleştiri.** A (yeni oturum veya Codex, plan yazılmış halde, üretim konuşması olmadan): pre-mortem ("proje Aşama 6'da çöktü; en olası 5 neden?"), gereksinim kapsama kontrolü (her `[B]` → aşama → test), `[V]` maddelerinin gözden geçirilmesi. K: bulguları ana oturuma taşır, kabul veya ret eder. `(K-atla)`: çok küçük projede tek bir "bu planın en zayıf 3 noktası" sorusuna indir, ama yine yeni oturumda.
6. **Dosyalara yazma.** A: PLAN.md, KARARLAR.md (K-001…), varsayım tablosu (PLAN.md içinde). K: commit.
7. **Aşama başı kontrol noktası (her ana başlıkta tekrarlanır).** A: varsayım tablosunu günceller (doğrulandı/çürüdü). Önceki aşamadan öğrenilenleri ("Sürprizler") okur. Bu aşamayı 3-8 adıma böler. Donmuş arayüzde değişiklik gerekiyorsa bunu karar kaydı önerisi olarak getirir. K: onaylar. Ek araştırma gerekiyorsa `docs/arastirma/asama-N/`.
8. **Uygulama döngüsü.** A: adım başına küçük diff, test, commit. Plandan sapma gerekirse durur ve PLAN.md değişikliğini önerir. K: adım veya aşama sonunda gözden geçirir.

**Ayrıntı ve büyüklük önerisi** (ölçüm bulunamadı; deneyim ve belge tavsiyelerinden türetilmiş başlangıç değerleri):
- Adım = tek commit'lik, tek testle doğrulanabilen değişiklik; bir oturumda bitmeli.
- Ana başlık = 3-8 adım ve kendi başına gösterilebilir bir çıktı.
- 12 ana başlık tek kişilik proje için fazla olabilir. Aşama 3'ten sonrası büyük olasılıkla yeniden şekillenecek, bu yüzden onları kaba bırak.
- Kısa oturumların gerekçesi: McMillan (arXiv 2605.10039, Mayıs 2026) Claude Code'da bir oturumda üretilen her ek fonksiyonla kurala uyum olasılığının yaklaşık %5,6 düştüğünü (OR = 0,944) ölçtü. Bu bulgu analiz sırasında keşfedilmiş, önceden tasarlanmış değil.\[22\]

**Arayüzleri baştan tanımlama:** Sadece aşama sınırını geçen ve donacak arayüzleri (fonksiyon imzası, veri şeması, dosya formatı, CLI) Aşama 1'de ve her aşama başında bir sonraki aşama için tanımla. Uzak aşamaların iç soyutlamalarını baştan tanımlamak erken soyutlamadır. Bunun belirtileri: tek bir implementasyonu olan arayüzler/ABC'ler, "ileride lazım olur" parametreleri, henüz verisi görülmemiş şemalar. Arayüzün değişikliği azalttığına dair yapay zekâya özgü ölçüm bulunamadı. Garg'ın (InfoQ, Eylül 2026) çalışmasında HLD arayüzleri ve LLD invariant'ları gözden geçirmeyi "sözleşmeye bağlı" hale getirdi, ama hata bulmayı artırmadı.\[23\]

## 4. AGENTS.md planlama kuralı taslağı

```markdown
## Planlama (ilkeler ve kontrol noktaları)

Amaç: planın geç değil erken değişmesi. Bu bir rehber, prosedür değil.
Bir adımı atlarsan ya da farklı yol izlersen bunu gerekçesiyle tek satırda söyle.

### İlkeler
- Araştırma belgeleri girdi, emir değil. Eksik, eskimiş veya hatalı olabilirler.
  Daha iyi bir yol görürsen öner; belgeyle çelişiyorsa açıkça "çelişki" de.
- Kaynağı görünür tut: her gereksinim ve kararın yanına
  [B: dosya#bölüm] = belgeden, [Ö] = senin önerin, [V] = varsayım yaz.
- Belirsizlik varsa: cevabı mimariyi / dış arayüzü / veri modelini
  değiştirecekse sor; değilse makul varsayımı [V] olarak yaz ve ilerle.
  Soruları tek turda topla (genelde ≤7).
- En riskli varsayımı en erken sına: Aşama 1 = en ince uçtan uca
  çalışan iskelet (walking skeleton) ve yüksek riskli [V]'lerin testi.
- Yakını ayrıntılı, uzağı kaba planla. Uzak aşama = amaç + çıktı arayüzü + açık riskler.
- "Bitti" çalıştırılabilir olsun: komut / test + beklenen sonuç.
- Yalnız aşama sınırını geçen arayüzleri tanımla; tek kullanımlık soyutlama kurma.

### Kontrol noktaları (kullanıcı onayı bekle)
1. Anlama özeti + sorular + Çelişki/Eskime listesi.
2. Plan taslağı (PLAN.md biçiminde) + kararlar + varsayım tablosu.
3. Her ana aşamaya girerken: varsayımları güncelle (doğrulandı / çürüdü),
   "Sürprizler"i oku, aşamayı 3-8 adıma böl, etkilenen sonraki aşamaları işaretle.

### Eleştiri
- Planı yazdığın oturumda kendi planını onaylama. Plan bitince kullanıcıya
  yeni oturumda / diğer ajanda yapılacak eleştiri istemini öner
  (pre-mortem: "proje başarısız oldu, en olası 5 neden?" + her [B] → aşama → test).

### Değişiklik
- Uygulama plandan sapıyorsa dur; sessizce doğaçlama yapma.
  PLAN.md değişikliğini ve etkisini (hangi aşama / donmuş arayüz) öner.
- Donmuş arayüzü değiştirmek = KARARLAR.md'ye yeni K-kaydı (eskisini silme).
- Küçük değişiklikler (adım sırası, adım bölme) karar kaydı gerektirmez;
  PLAN.md'deki "Sürprizler" satırı yeter.

### Ölçek
- Tek cümlede tarif edilebilen iş için plan yapma, doğrudan yap.
- Küçük projede (≤ ~3 aşama) karar tablosu ve ayrı spike gerekmez.
```

(~40 satır. Dosya genelinde kısalık önemli: Claude Code belgesi "şişkin CLAUDE.md dosyaları Claude'un asıl talimatlarını görmezden gelmesine yol açar" diyor ve her satır için "bu satırı silmek hata yaptırır mı?" sorusunu öneriyor.)\[1\]

## 5. PLAN.md şablon önerisi

```markdown
# PLAN — <proje adı>
Son güncelleme: YYYY-AA-GG · Şu anki aşama: N · Kurallar: AGENTS.md#Planlama

## Amaç
<2-3 cümle: kullanıcı bittiğinde ne yapabilecek, nasıl görülecek>
Kapsam dışı: <madde madde>

## Başarı ölçütleri
| # | Ölçüt (ölçülebilir) | Doğrulama komutu/testi | Kaynak |
|---|---|---|---|
| S1 | ... | `pytest tests/e2e/test_x.py` | [B: genel/a.md#3] |

## Gereksinimler (kısa)
| # | Gereksinim | Kaynak | Aşama | Test |
|---|---|---|---|---|
| G1 | ... | [B: ...] / [Ö] / [V] | 2 | test_... |

## Çelişki / Eskime notları
| Belge iddiası | Ajanın görüşü | Gerekçe | Karar |
|---|---|---|---|

## Varsayımlar ve riskler
| # | Varsayım | Risk (Y/O/D) | Nasıl sınanacak | Aşama | Durum |
|---|---|---|---|---|---|
| V1 | ... | Y | iskelette gerçek veriyle | 1 | açık / doğrulandı / çürüdü → K-00x |

## Aşamalar
| # | Aşama | Amaç | Dışa açık arayüz (girdi → çıktı) | Bitti = | Bağımlı | Durum |
|---|---|---|---|---|---|---|
| 1 | Walking skeleton | uçtan uca en ince yol + V1,V3 | `cli run <dosya>` → `out.json` | e2e test geçer | — | devam |
| 2 | ... | ... | ... | ... | 1 | kaba |
| … | (uzak aşamalar 1 satır; ayrıntı aşama başında) | | | | | |

## Şu anki aşama: N — <ad>
Aşama başı kontrol: [ ] varsayımlar güncellendi [ ] sürprizler okundu [ ] arayüz değişikliği yok / K-kaydı açıldı

| Adım | Açıklama | Durum | Test | Commit |
|---|---|---|---|---|
| N.1 | ... | bitti | test_... ✓ | abc123 |
| N.2 | ... | sırada | | |

## Sürprizler ve keşifler
- YYYY-AA-GG · <gözlem> · kanıt: <test çıktısı/komut> · etki: <aşama/varsayım>

## Donmuş arayüzler
| Aşama | Arayüz | Test | Dondurulma |
|---|---|---|---|
```

(Doldurulmuş hali 12 aşamayla yaklaşık 80-130 satır. Uzak aşamalar tek satırda tutulursa 150'yi aşmaz. "Sürprizler" ve "Çelişki" bölümleri ExecPlan'ın "Surprises & Discoveries" ve "Decision Log" fikrinin hafif hali. Kalıcı kararlar KARARLAR.md'de kalır.)

## 6. Detaylar ve araç karşılaştırması (araştırma soruları 1, 7, 8, 10, 13)

**Ölçülmüş olanlar (soru 1):**
- Garg (InfoQ, 10 Eylül 2026; GAISS 2026'da kabul edilmiş ön çalışma, küçük örneklem):\[23\] Kolay tek-fonksiyon görevlerde doğrudan kod %59, önce akıl yürütme %95, önce spec %92 başarı verdi. Spec ile akıl yürütme arasındaki fark anlamlı değildi. Karmaşık bankacılık görevinde spec'i ayrı yönetici artefakt olarak yazıp sonra ayrı adımda üretmek geçme oranını yaklaşık ikiye katladı. Zayıf model spec disiplininden ~21 puan, güçlü model ~2 puan kazandı.\[24\] Çıkarım: plan/spec'in değeri zor ve çok kısıtlı işlerde, planı ayrı artefakt ve yeni üretim adımı olarak kullandığında ortaya çıkıyor. Opus ile planlayıp daha hafif modelle uygulamak ("opusplan") bu ayrımla uyumlu.\[25\]
- Gloaguen vd. (arXiv 2602.11988, Şubat/Haziran 2026, ETH Zürih): LLM'in ürettiği bağlam dosyaları çözüm oranını SWE-bench'te ortalama %0,5, CTXbench'te %2 düşürdü (anlamlı değil). Maliyeti %20-23 artırdı.\[22\] Geliştiricinin yazdığı dosyalar ortalama %2,4 iyileştirdi (p=%21, anlamlı değil). Öneri: insan yazımı dosyalar yalnız README'de olmayan, ajana özgü talimatları (standart dışı kurallar, fonksiyonel olmayan gereksinimler) içermeli.\[26\] Talimatların ajanlarca "iyi takip edildiğini", ama repo genel bakışlarının faydasız olduğunu da raporladılar.\[27\]
- traceSDD (arXiv 2606.30689, Haziran 2026, tek yazar, hakemsiz, yazar kendi aracını test ediyor): Her satırda gereksinim kimliği atıfını zorunlu kılmak doğruluğu değiştirmedi (tüm koşullarda %100 test geçme). Belirlenimciliği düşürdü (Claude LSS 0,745 → 0,535). Otomatik halüsinasyon tespitini ise yalnız bu koşul sağladı (~%86-88; diğer koşullarda %0). Yazarın adlandırdığı ödünleşim: "citation annotations trade determinism for verifiability".\[28\] Senin etiket fikrin için çıkarım: etiketi **plan düzeyinde** (gereksinim ve karar satırında) tut, kod satırı düzeyine indirme. Plan düzeyinde maliyeti düşük, izlenebilirlik kazancı yüksek.

**Belgeden gereksinim çıkarmadaki hatalar (soru 7):**
- Ortadaki bilgiyi kaçırma riski "Lost in the Middle" ile belgeli (12 aydan eski; yeni modellerde büyüklüğü doğrulanmadı).\[5\]
- Desteksiz iddia ve belgeye aşırı bağlılık için ajan planlamasına özgü ölçüm bulunamadı.
- Böckeler (martinfowler.com, 15 Ekim 2025) bunu açıkça yazıyor: "Even with all of these files and templates and prompts and workflows and checklists, I frequently saw the agent ultimately not follow all the instructions."
- Her iki hatayı birlikte azaltan pratik çözüm: `[B: dosya#bölüm]` ile kaynağı zorunlu kılmak (desteksiz iddia görünür olur) + ayrı "Çelişki/Eskime" listesi (ajan belgeyi sorgulamaya teşvik edilir ama bunu açıkça yapar) + kapsama kontrolü (atlanan gereksinim görünür olur).

**Soru sormak mı, varsaymak mı (soru 8):**
- Kanıt, ajanın **seçerek** sormasının en iyisi olduğunu gösteriyor. "Ask or Assume?" çalışmasında belirsizliğe duyarlı düzen soru sormadığı 156 görevde de %76,92 çözdü, yani gereksiz sormadı.\[7\]
- Pratik denge: tek tur, mimariyi değiştirecek sorular, gerisi `[V]`.
- Claude Code belgesi büyük özellikler için "AskUserQuestion ile beni ayrıntılı mülakat et" yaklaşımını öneriyor, ama "bariz soruları sorma, zor kısımları kaz" diyor.\[1\]
- Kiro'nun Quick Plan'ı da soruları başta toplayıp sonra faz kapısı olmadan üretiyor.\[29\]

**Araç karşılaştırması (soru 10) — tek kişilik projede neyi al:**

| Araç | İşe yarayan parça | Fazla seremoni |
|---|---|---|
| Claude Code plan modu | Salt okuma keşif, Ctrl+G ile planı düzenleme, "tek cümlelik diff'te plan yapma" kuralı, doğrulama alt-ajanı\[1\] | — (hafif) |
| Codex plan modu + PLANS.md/ExecPlan | Gözlenebilir kabul, Progress / Surprises / Decision Log, prototip milestone'ları\[11\] | Tam ExecPlan'ın "kendi kendine yeten, acemi okur" gereksinimi tek kişilik projede şişkinlik yaratır |
| GitHub Spec Kit | `[NEEDS CLARIFICATION]`, `/speckit.clarify`, `/speckit.analyze` (kapsama/tutarlılık), constitution fikri | Özellik başına çok sayıda dosya ve branch; Böckeler 3-5 puanlık bir hikâyede uygulamayı bitiremedi |
| Kiro | EARS ile test edilebilir kabul kriteri dili, Quick Plan (sorular başta, kapısız üretim) | Küçük bir hata için 4 "user story" ve toplam 16 kabul kriteri; Böckeler: "like using a sledgehammer to crack a nut" |
| Cursor Plan Mode | Netleştirici sorular + düzenlenebilir markdown plan; "yanlış yönde gittiyse geri al ve planı düzelt" tavsiyesi\[30\]\[31\] | — |
| BMAD v6 | Ölçeğe uyarlanan izler (Quick Flow ↔ tam yöntem), iş büyüyünce yükseltme fikri\[32\]\[33\] | Çok rollü ajan persona'ları ve PRD/mimari/UX zinciri tek kişilik projede ağır |

**Kısıtlamadan kaçınma (soru 13):**
- İlke/kontrol noktası yaz: "en riskli varsayımı erken sına", "kaynağı etiketle", "sapınca dur". Bunlar muhakemeyi yönlendirir.
- Zorunlu adım olarak yazma: her projede spike, her kararda ADR, her aşamada pre-mortem, sabit soru sayısı. Bunlar küçük işte ajanı yavaşlatır ve Gloaguen'in gözlediği "gereksiz gereksinim görevi zorlaştırır" etkisini üretir.\[34\]
- "Asla/Her zaman" kurallarını yalnız gerçekten değişmez olanlara ayır (donmuş arayüz, commit disiplini). Kesin garanti istediklerini (testler geçmeden commit yok gibi) kural dosyası yerine hook ile uygula. Claude Code belgesi CLAUDE.md talimatlarının "tavsiye niteliğinde", hook'ların "deterministik" olduğunu vurguluyor.\[1\]
- Tercihim: **rehber + zorunlu kontrol noktaları**. Katı prosedür, ajanın muhakemesini kullanmak istemenle çelişir. Tamamen serbest bırakmak ise planın erken kırılmasını sağlamaz. Kontrol noktaları, değişikliği erkene çeken tek yapısal mekanizma.

## 7. Doğrulanamayanlar ve kendin denemen gerekenler

**Doğrulanmadı / ölçüm bulunamadı:**
- Walking skeleton, rolling wave, spike ve pre-mortem'in **LLM ajanlı** projelerde plan değişikliğini azalttığına dair kontrollü ölçüm bulunamadı. Gerekçeler mühendislik pratiği ve deneyim raporları.
- Plan eleştirisinde farklı model ile aynı model yeni bağlam arasında doğrudan karşılaştırma bulunamadı. CCR çalışması tek yazarlı ve hakemsiz, hataları yapay olarak enjekte ediyor.
- Böckeler'in "ajan tüm talimatları izlemedi" cümlesi orijinal makalede doğrulandı (martinfowler.com, 15 Ekim 2025); ancak bu nitel bir gözlem, ölçüm değil.
- Claude Code planlarının 30 günde silindiği resmî belgede doğrulandı; `plansDirectory` ayarının adı ve davranışı ise doğrulanmadı.
- ExecPlan makalesi (Aaron Friel, OpenAI Cookbook) 7 Ekim 2025 tarihli görünüyor; tarih Cookbook sayfasında değil ikincil listelerde görüldü. İçerik `gpt-5.2-codex` modelini önerecek şekilde güncellenmiş.
- Adım ve aşama büyüklüğü önerileri (3-8 adım, ≤7 soru) ölçüme değil türetilmiş sezgiye dayanıyor.

**Kendin dene (2-3 projede, basit ölçümle):**
1. **Plan değişim oranı:** Her aşama başında PLAN.md'de kaç aşama satırının değiştiğini ve bunların kaçının `[V]` kaynaklı olduğunu say. `[V]`'ler baskınsa soru turunu güçlendir; `[B]` kaynaklıysa belge kalitesine bak.
2. **Eleştiri A/B:** Aynı plan için (a) aynı oturumda "planını eleştir", (b) yeni Claude oturumu, (c) Codex. Yakalanan ve sonradan gerçekten sorun çıkan maddeleri say.
3. **Soru bütçesi:** Bir projede ≤3, diğerinde ≤7 soru. Aşama 1 sonunda çürüyen varsayım sayısını karşılaştır.
4. **Kural uyumu:** AGENTS.md kuralını ekledikten sonra ajanın etiketleri ve kontrol noktalarını gerçekten uygulayıp uygulamadığını ilk 3 oturumda gözle. Uygulamıyorsa önce dosyayı kısalt, sonra tek satıra "ÖNEMLİ" ekle (Claude Code belgesinin önerisi).\[1\]
5. **Codex uyumu:** Codex'te aynı AGENTS.md ile plan modunun soru sorma davranışını gözle. Codex ExecPlan rehberi uygulama sırasında "belirsizlikleri özerk çöz" diyor; bu, planlama aşamasındaki "sor" ilkenle çatışabilir.\[11\]

## 8. Kaynak dökümü (tarih ve güvenilirlik)

| Kaynak | Tür | Tarih | 12 aydan eski mi? |
|---|---|---|---|
| Claude Code Docs — Best practices (code.claude.com) | Resmî belge | Eylül 2026'da erişildi (v2.1.28x dönemi) | Hayır |
| OpenAI Codex — Best practices (developers.openai.com/codex) | Resmî belge | 2026'da erişildi | Hayır |
| OpenAI Cookbook — Using PLANS.md for multi-hour problem solving (Aaron Friel) | Resmî rehber | 7 Ekim 2025 (ikincil listelerden); içerik gpt-5.2-codex'e göre güncel | Hayır (sınırda) |
| GitHub Spec Kit README, spec-driven.md, quickstart | Resmî belge/repo | 2026 (specify → … → converge sürümü) | Hayır |
| Kiro Docs — Requirements-First, Quick Plan/Quick Spec | Resmî belge | 2026'da erişildi | Hayır |
| Cursor Docs — Plan Mode; Cursor blog — agent best practices | Resmî belge | 2026'da erişildi (Plan Mode Ekim 2025'te duyuruldu)\[35\] | Hayır |
| BMAD-METHOD v6 (repo aynaları, mintlify belge aynası) | Resmî olmayan ayna / topluluk | 2025-2026 | Karışık; resmî sayfa doğrudan açılmadı |
| Böckeler, "Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl" (martinfowler.com) | Uzman deneyim raporu | Ekim 2025 | Hayır (sınırda) |
| Garg, "When Spec-Driven Development Pays Off" (InfoQ) | Ön çalışma raporu | 10 Eylül 2026 | Hayır |
| Gloaguen vd., arXiv 2602.11988 | Ön baskı (ICLR 2026 çalıştayı) | Şubat 2026, v2 Haziran 2026 | Hayır |
| McMillan, arXiv 2605.10039 | Ön baskı | Mayıs 2026 | Hayır |
| Panda, traceSDD, arXiv 2606.30689 | Ön baskı, hakemsiz | 28 Haziran 2026 | Hayır |
| Edwards & Schuster, "Ask or Assume?", arXiv 2603.26233 | Ön baskı | Mart 2026, v2 Haziran 2026 | Hayır |
| AMBIG-SWE, arXiv 2502.13069 | Hakemli (ICLR 2026) | v1 Şubat 2025 | **Evet** |
| Cross-Context Review, arXiv 2603.12123 | Ön baskı, tek yazar | Mart 2026 | Hayır |
| Huang vd., "LLMs Cannot Self-Correct Reasoning Yet" | Hakemli (ICLR 2024) | 2023-2024 | **Evet** |
| Stechly vd., arXiv 2402.08115 | Ön baskı | Şubat 2024 | **Evet** |
| arXiv 2502.19361 (uzun CoT hata tespiti) | Ön baskı | Şubat 2025 | **Evet** |
| Liu vd., "Lost in the Middle" (TACL) | Hakemli | 2023/2024 | **Evet** |
| Anthropic Engineering — Effective harnesses for long-running agents | Resmî mühendislik yazısı | Kasım 2025 | Hayır |
| Mitchell, Russo & Pennington (1989); Klein, HBR (2007); J. Collins'in değerlendirmesi | Psikoloji / yönetim | 1989 / 2007\[36\] | Yapay zekâ kaynağı değil |
| METR, deneyimli geliştirici RCT (bağlam için; raporda kullanılmadı) | Ölçüm | Temmuz 2025\[37\]\[38\] | **Evet** |

## Sources

1. <https://code.claude.com/docs/en/best-practices>
2. [Best practices](https://developers.openai.com/codex/learn/best-practices)
3. [Spec-Driven Development: Deep Dive](https://hazar-nazari.medium.com/spec-driven-development-deep-dive-c01e597e92bf)
4. [Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl](https://daniliants.com/insights/understanding-spec-driven-development-kiro-spec-kit-and-tessl/)
5. [Lost in the Middle: How Language Models Use Long Contexts Nelson F. Liu1∗](https://cs.stanford.edu/~nfliu/papers/lost-in-the-middle.arxiv2023.pdf)
6. [Lost in the Middle: How Language Models Use Long Contexts](https://direct.mit.edu/tacl/article/doi/10.1162/tacl_a_00638/119630/Lost-in-the-Middle-How-Language-Models-Use-Long)
7. [Ask or Assume? Uncertainty-Aware Clarification-Seeking in Coding Agents](https://arxiv.org/html/2603.26233v2)
8. [Accepted at ICLR 2026 AMBIG-SWE: INTERACTIVE AGENTS TO OVERCOME](https://arxiv.org/pdf/2502.13069)
9. [spec-kit/spec-driven.md at main · github/spec-kit](https://github.com/github/spec-kit/blob/main/spec-driven.md)
10. [Overview](https://zread.ai/github/spec-kit)
11. [openai-cookbook/articles/codex\_exec\_plans.md at main · openai/openai-cookbook](https://github.com/openai/openai-cookbook/blob/main/articles/codex_exec_plans.md)
12. [Engineering at Anthropic](https://anthropic.com/engineering/effective-harnesses-for-long-running-agents)
13. [Spec-Driven Development with spec-kit](https://matsen.fhcrc.org/general/2026/02/10/spec-kit-walkthrough.html)
14. [Spec-Driven Development Quickstart](https://github.github.com/spec-kit/quickstart.html)
15. [Using Speckit for Spec-driven Development](https://shreyashupare.medium.com/using-speckit-for-spec-driven-development-18059c0e86e8)
16. [What's The Deal With GitHub Spec Kit](https://den.dev/blog/github-spec-kit/)
17. [On the Self-Verification Limitations of Large Language Models on Reasoning and Planning Tasks](https://arxiv.org/pdf/2402.08115)
18. [LARGE LANGUAGE MODELS CANNOT SELF-CORRECT ...](https://proceedings.iclr.cc/paper_files/paper/2024/file/8b4add8b0aa8749d80a34ca5d941c355-Paper-Conference.pdf)
19. <https://arxiv.org/pdf/2603.12123>
20. [Can Large Language Models Detect Errors in Long Chain-of-Thought Reasoning?](https://arxiv.org/pdf/2502.19361)
21. [Claude Code Planning Mode: How to Use Claude Plan Mode — Munder Difflin Blog](https://munderdiffl.in/blog/how-to-use-claude-code-plan-mode/)
22. <https://arxiv.org/pdf/2605.10039>
23. [When Spec-Driven Development Pays off](https://www.infoq.com/articles/when-spec-driven-development-pays-off/)
24. [When Spec-Driven Development Pays Off](https://daily.dev/posts/when-spec-driven-development-pays-off-gqx1pymj4)
25. [Claude Code: Best Practices for Developers - SAP Community](https://community.sap.com/t5/artificial-intelligence-blogs-posts/claude-code-best-practices-for-developers/ba-p/14394164)
26. [Evaluating AGENTS.md:Are Repository-Level Context Files Helpful for Coding Agents?](https://arxiv.org/html/2602.11988v2)
27. [Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?](https://arxiv.org/abs/2602.11988)
28. <https://arxiv.org/pdf/2606.30689>
29. [Quick Plan - IDE - Docs - Kiro](https://kiro.dev/docs/specs/quick-plan/)
30. [Plan Mode](https://cursor.com/docs/agent/plan-mode)
31. [Developing Features](https://cursor.com/learn/creating-features)
32. [GitHub - LarryBrin/BMAD-METHOD-V6: Breakthrough Method for Agile Ai Driven Development](https://github.com/LarryBrin/BMAD-METHOD-V6)
33. [Scale-Adaptive Planning - BMad Method](https://www.mintlify.com/bmad-code-org/BMAD-METHOD/concepts/scale-adaptive-planning)
34. [Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?](https://hackernoon.com/evaluating-agentsmd-are-repository-level-context-files-helpful-for-coding-agents)
35. [The Complete Guide to Cursor's Plan Mode](https://hodapress.com/blog/cursor-plan-mode/)
36. [Pre-Mortem: How to Run One, With Template & Example (2026)](https://www.rock.so/blog/pre-mortem)
37. [Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity - METR](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
38. [A randomized trial by METR found that experienced developers completed real coding tasks 19% slower when allowed to use AI tools — yet afterwards, they estimated on average that AI had made them 20% faster. - ScienceBlog.com](https://scienceblog.com/t-a-randomized-trial-by-metr-found-that-experienced-developers-completed-real-coding-tasks-19-slower-when-allowed-to-use-ai-tools-yet-afterwards-they-estimated-on-average-that-ai-had-made-them-20-fast/)
