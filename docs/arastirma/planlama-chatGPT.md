1. **Sonuç:** Taslak yöntem genel olarak mantıklı; özellikle gereksinim ve varsayım kontrolü, risk odaklı deneyler, ana hat ve ayrıntılara dayalı plan unsurları uygun. Ancak bazı adımlar daha esnek kurgulanmalı. Örneğin, **ön-ölüm analizi** (pre-mortem) ve “rolling wave” (ayrıntıları yakın dönemde, uzaktakileri yüksek seviyede tutmak) planlama iyi birer pratik. Ayrıca **spike’lar** (kısa, zaman sınırlı deneyler) yüksek riskli varsayımlarda *kesinlikle* faydalı. Plan şablonuna başarı ölçütleri, arayüz tanımları ve kabul kriterleri açıkça eklenmeli (Arbisoft’a göre iyi plan; hedef, kapsam, varsayımlar, bağımlılıklar, test kanıtları, riskler ve değişiklik mekanizmalarını içerir). Özetle: metodunuz doğru yönde ancak **açıklama-bilgi toplama** adımı netleştirilmeli, plan esnekliği artırılmalı ve ajanın şeffaf geribildirim sağlaması teşvik edilmeli.

2. **Taslak yöntemin eleştirisi:**

| Adım                | Tut/Değiştir/Çıkar/İsteğe bağlı | Gerekçe ve kaynak                                                                                                                             |
|---------------------|-------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| 0.1 Araştırmayı klasöre koy | İsteğe bağlı (basit standart) | Literatürde özellikle vurgulanmasa da, kaynak belgeleri organize tutmak faydalı; ancak bu teknik bir detaydır, ağır bir prosedür değil.   |
| 0.2 Anlama özeti            | Tut                           | Belgelerden gereksinim ve başarı ölçütlerinin çıkarılması iyi bir uygulama. Bunlar plan başarısını doğrudan etkiler; sonuçlara şeffaflık katar (kapsam ve hedef netliği önemli).   |
| 0.3 Kararlar ve riskler     | Tut (kullan)                  | Karar kayıtları (ADR) belirme fikri doğru; kararların gerekçesi ve alternatifler yazılı tutulmalı. Bu, ileride kafa karışıklığını önler. Yine de basit proje için sade tutulabilir. |
| 0.4 Keşif denemeleri (spike) | Tut                           | Yüksek riskli varsayımlar için kısa deneyler yapmak (spike) önerilmiş ve olumlu etki raporlanmış. Gereksiz ise (küçük proje veya bilindik teknoloji) atlanabilir.         |
| 0.5 Plan taslağı            | Değiştir/Detaylandır         | Ana hatlara “amaç, arayüz/girdi-çıktı, bitiş ölçütü, bağımlılık” eklemek doğru; ancak ayrıca kabul kriterleri ve test stratejisi açık tanımlanmalı. “Rolling wave” planlama (yakın işler detaylı, uzak işler genel) ve walking skeleton uygulamak faydalı. Ön-ölüm analizi iyi bir ek; planın ertelenebilecek son halini kontrol etmek gerek. Planı ikinci bir modelle (Codex gibi) eleştirmek şeffaflığı artırabilir (çapraz kontrol faydalı). |
| 0.6 Onayland\u0131ktan sonra dosyalara yazma | Tut                           | Plan onayı sonrasında dokümante etmek mantıklı. Ancak planlama sürecinde de ara commit’lerle güncel tutmak önerilir (Arbisoft’a göre erken kanıt ve değişiklik görünür olmalı). |

3. **Önerilen planlama akışı (numaralı):**  
1. **Bilgi derleme:** Araştırma belgelerini gözden geçir, gereksinimler, varsayımlar ve kısıtlar listesini oluştur. Her gereksinimi kaynağıyla not et. Başarı ölçütleri/ kabul kriterlerini açıkla. Belirsizlik varsa kullanıcıya sor (“Bu gereksinim doğru mu?” vs).  
2. **Kararlar ve riskler:** Projede önemli teknik seçenekleri belirle; alternatifleri ve seçim gerekçelerini dokümante et. Temel varsayımları ve bunların risk düzeyini bir tabloda tut (ör. basit varsayım defteri gibi). Kritiklik seviyesi yüksek olan her varsayım için küçük bir **spike** deneyi planla (xp pratiklerinde olumlu sonuçlar verdi). Spike’lar sonuçlandığında karar kaydına (ADR) ekle.  
3. **Plan taslağı:** Projeyi ana modüller veya özelliklere ayır (her bir için “amaç, girdi/çıktı arayüzü, tamamlanma ölçütü, bağımlılıklar” tanımla). Yakın aşamaları ayrıntılı, uzak aşamaları daha kaba tut (“rolling wave” prensibi). İlk aşamada uçtan uca çalışan bir skeleton (minimal işlevsellik) oluştur. Planın kapsamına ön-ölüm analizi ile potansiyel başarısızlık senaryolarını ekle. Gerektiğinde planı yeniden gözden geçir veya ihtiyaç duyarsan “ikinci görüş” için başka bir modelden eleştiri al (çoklu değerlendirme plan kalitesini artırır).  
4. **Gözden Geçirme ve Onay:** Hazırlanan planı kullanıcıyla birlikte incele. Gerekli düzeltmeleri yap. Onay alınca planı PLAN.md’ye yaz. KARARLAR.md’ye yeni alınmış kararları kaydet. DEVAM.md’ye devir notlarını ekle.  
5. **Uygulama:** Planı aşama aşama uygula. Her küçük adımı tamamladıkça commit yap. Bir aşama tamamlandığında (arayüz ve testleri sabitlendiyse), artık “donmuş” kabul edilir. Proje küçükse, adımlardan bazıları (ör. kapsamlı walking skeleton, ek model eleştirisi) isteğe bağlı atlanabilir.

4. **AGENTS.md’deki kural taslağı (Türkçe, ilkeler):**  
- Ajan her oturumda güncel plan kurallarını okur ve izler. Amaç: her kararın dayanağını açıklayan şeffaf bir plan üretmektir.  
- **Belgelere referans:** Yeni bir gereksinim sunarken bunların kaynakları belirtilmelidir (“Belgeden alındı” veya “ajanın önerisi” notu ekle). Böylece hangi bilginin nereden geldiği net olur.  
- **Gereksinim kontrolü:** Plan maddelerini oluştururken eldeki belgelerle uyuşmazlık varsa gerekçesiyle belirt. (Zayıf veya çelişen bir belge bilgisi fark edildiyse uyar, alternatif öner.)  
- **Kısıtlama ve arayüz belirleme:** Plan her ana başlık için girdi/çıktı arayüzünü, kabul kriterlerini ve başarı ölçütlerini açıklar. Erken soyutlamaya kaçmadan, bağlantıların ve bağımlılıkların net olduğundan emin ol.  
- **Sorular ve belirsizlik:** Belirsiz bir konu varsa önce ajanın kullanıcıdan bilgi istemesi tercih edilir. Gereksiz yere soruyu pas geçmek yerine, “Bu konuda daha fazla bilgiye ihtiyacım var” denilebilir. (Yanlış varsayımdan kaçınmak için açıklama iste.)  
- **Esneklik:** “Zorunlu adım” değil, **kontrol noktası** yaklaşımı kullan. Örneğin: “Plan onaylanmadan kod yazmaya geçme” yerine “Bu plan ele alındı mı? Aksi halde risk olacak” gibi bir uyarı koy. Gerektiğinde ajan, durumu değerlendirip düşük riskli adımları atlayabilir.  
- **Dokümantasyon:** Her önemli karar, varsayım veya taslak öneri KARARLAR.md’de kayıtlıdır. Riske dair notlar PLAN.md veya ilgili yerde belirtilir. Ama bu yazılı talimatlar muhakemeyi engellemez; ajanın anahtarı “neden?” sorusudur, yazılı kuralları şeffaflık için hatırlatıcı kabul eder.  

5. **PLAN.md şablon önerisi (Markdown):**  
```markdown
# PLAN.md - [Proje Adı]

## Aşamalar
| Aşama | Açıklama               | Durum      | Test  | Commit  |
|-------|------------------------|------------|-------|---------|
| 1     | [Aşama1 Adı]           | (Beklemede/Devam)| [Test Durum] | [commit id] |
| 2     | [Aşama2 Adı]           | ...        | ...   | ...     |
| ...   | ...                    | ...        | ...   | ...     |

## 1. [Aşama1 Adı] - [Kısa Açıklama]
### Amaç  
[Aşama 1'in genel amacı ve işletim hedefi.]

### Girdi/Çıktı Arayüzü  
- **Girdi:** … (örn. API çağrısı formatı)  
- **Çıktı:** … (örn. dönen veri, dosya, kullanıcı arabirimi)  

### Tamamlanma Ölçütleri (Test, Kabul)  
- Bu aşamada, aşağıdaki şartlar sağlandığında “bitti” kabul edilir:  
  - [x] Kabul Testi geçiyor (örn. `test_X` yeşil)  
  - [ ] [Diğer kriter]  

### Adımlar  
1. **[Adım 1.1]** - Yapılacak iş (örneğin: `moduleA`’da `FonksiyonX`’i yaz).  
2. **[Adım 1.2]** - …  
3. …  

### Bağımlılıklar  
- [ ] Başka modül veya servis hazır olmadan bu aşamaya başlayamazsın (örn. **Aşama 0** tamamlanmalı).  
- [ ] Gereksinim: **kütüphaneX** kurulu olmalı.  

### Riskler/Kararlar  
- **Karar K-001:** Bu aşamada **tek bir ThreadSafe veri yapısı** kullanılacak (performans ve güvenlik için).  
- **Varsayım:** Dış API’nin 2025 sonuna kadar değişmeyeceği kabul edildi.  

## 2. [Aşama2 Adı] - ...

*(Her aşama için yukarıdaki alt bölümleri yinele)*

```

6. **Doğrulanamayan varsayımlar / Denemem gerekenler:**  
- Spesifik **ölçüm verileri** bulamadım (örneğin “%x daha az değişiklik” gibi). Bu nedenle planlama yöntemlerimizin etkinliğini ancak zamanla kendi projelerimizde görerek değerlendireceğiz. (“Ölçüm bulunamadı.”)  
- **Spike ve walking skeleton** yöntemlerinin yapay zeka destekli projelerde ne kadar etkili olduğu belirsiz; bunları küçük denemelerle görmek gerekiyor. (“Doğrulanmadı” durumda.)  
- İkinci bir modelin (örneğin Codex vs. Claude) plan eleştirisinin somut faydasını test etmek gerek. Ne zaman fayda sağladığını gözlemleyeceğim.  
- **Soru sayısı dengesi:** Ajana ne kadar soru sormak optimal, ölçülememiş. Çok fazla soru müşteri iş yükünü artırır; az soru yanlış anlamaya sebep olabilir. En iyi soruları belirlemek deneyim işidir.  
- Cursor, BMAD gibi araçların spesifik işlevsel çıkarımlarını kendi projemde denemem ve gözlemlemem gerekecek; literatürde tek kişilik kullanım örnekleri kısıtlı.

7. **Kaynakça (URL + erişim/tarih):**  
- Martin Fowler, *“Architecture Decision Record”*, 24 Mar 2026.  
- Arbisoft, *“What a Good Custom Software Project Plan Looks Like…”*, 5 Ağu 2026.  
- Agile Alliance (Wikipedia), *“Agile software development”* (Rolling Wave yaklaşımı), Erişim 2026. (Bkz. Wikipedia).  
- J. van der Aalsvoort, *“Walking Skeletons in Software Architecture”*, 3 Mar 2025.  
- D. Brown (Autotrader Eng.), *“Extreme Programming in practice…”*, 6 Ağu 2026.  
- Wikipedia, *“Pre-mortem”*, (11 Ağu 2026 düzenlenmiş).  
- E. Martonosi vd., *“When Planning Fails Despite Correct Execution: On Epistemic Calibration for LLM-Based Multi-Agent Systems”*, arXiv, 22 May 2026.  
- Adobe AI-Geliştirme Kılavuzları (Mysticat, Planlama), Erişim 2024.  

