# **Yapay Zekâ Destekli Yazılım Geliştirmede Kanıta Dayalı Planlama ve Ajan Yönlendirme Stratejileri**

## **1\. Kısa Hüküm**

Kullanıcı tarafından sunulan taslak planlama yöntemi, yazılım mühendisliği ilkeleri açısından sağlam bir temele oturmakla birlikte, büyük dil modellerinin (LLM) yapısal sınırları ve ajan entropisi (agentic entropy) riskleri göz önüne alındığında bazı stratejik zafiyetler barındırmaktadır. Taslak, belgelendirmede güçlü bir başlangıç sunarken, ajanların bağlamsal erime (lost-in-the-middle) ve kendi kendini düzeltme (self-correction) konusundaki belgelenmiş yetersizliklerini hesaba katmamaktadır. Yöntemin iyileştirilmesi için en kritik üç değişiklik şunlardır: Birincisi, ajanın kendi ürettiği planı ikinci bir modele eleştirtmek yerine, yürütülebilir dış geri bildirimlere (çalışan iskelet ve keşif denemeleri) ağırlık verilmelidir; zira büyük dil modelleri dış gerçeklik (derleyici veya test sonuçları) olmadan salt muhakeme yoluyla hatalarını düzeltemezler. İkincisi, araştırma belgelerinden çıkarım yapılırken ajanın halüsinasyonlarını veya belgedeki eskimiş bilgileri ayırt edebilmesi için kesin bir "köken izlenebilirliği" (provenance tagging) kuralı getirilmelidir. Üçüncüsü, "mimari kaymayı" (architectural drift) engellemek adına, uzak hedeflerin kaba bırakıldığı yuvarlanan dalga (rolling wave) planlaması daha agresif bir şekilde benimsenmeli ve ajanın yalnızca üzerinde çalıştığı başlığın arayüz sınırlarına odaklanması sağlanmalıdır.

## **2\. Taslak Yöntemin Adım Adım Eleştirisi**

Aşağıdaki tablo, sunulan planlama sırasının bilimsel literatür ve büyük dil modellerinin kognitif mimarisi ışığında kanıta dayalı bir değerlendirmesini sunmaktadır.

| Adım | Karar (Tut / Değiştir / Çıkar / İsteğe Bağlı) | Gerekçe ve Kanıt Temeli |
| :---- | :---- | :---- |
| **0.1 Araştırmayı klasöre koy.** | **Tut** | Bağlam penceresini beslemek için hiyerarşik dosya düzeni zorunludur. Şartname Yönelimli Geliştirme (Spec-Driven Development) ve BMad gibi modern yaklaşımlar, araştırmanın merkezi bir havuzda tutulmasını standart kabul eder1. |
| **0.2 Anlama özeti, kısıtlar ve sorular.** | **Değiştir (Geliştir)** | Modellerin "ortada kaybolma" (lost-in-the-middle) sorununu aşmak için bu adımda **Köken İzlenebilirliği (Provenance)** kuralı işletilmelidir3. Çıkarımlar açıkça etiketlenmeli, ajan soruları ise yalnızca kritik mimari belirsizlikler için en fazla 2-3 adetle sınırlandırılarak "istem yorgunluğu" (prompt fatigue) önlenmelidir5. |
| **0.3 Kararlar ve riskler (Alternatif, ölçüt).** | **Tut** | Mimari kaymayı (architectural drift) önlemek için Mimari Karar Kayıtları (ADR) kullanımı, otonom ajanların rotada kalmasını sağlayan en etkili araçtır6. |
| **0.4 Keşif denemeleri (Spike).** | **İsteğe Bağlı (Kritikse Yap)** | Sadece bilinmeyen teknolojiler veya doğrulanmamış entegrasyonlar için kullanılmalıdır. Büyük dil modellerinin dış dünya geri bildirimi almadan muhakeme yapamaması nedeniyle, kod yazıp hata mesajını görmek en iyi risk analizidir8. |
| **0.5 Plan taslağı (Yuvarlanan dalga, ön-ölüm, 2\. modele eleştiri).** | **Değiştir** | İkinci bir modele planı eleştirtmek (multi-agent debate) salt metin üzerinde yapıldığında jeton israfıdır; modeller dış doğrulama olmadan muhakeme hatalarını kendi kendilerine çözemezler8. "Ön-ölüm" analizi spesifik teknik risklere (Tigers) daraltılmalı12, arayüz sınırları kesinlikle korunmalıdır. |
| **0.6 Onaylanınca dosyalara yazma.** | **Tut** | Ajanın, planlama modundan (plan mode) çıkmadan ve uygulamaya geçmeden önce insan onayı alması, yapay zekâ destekli sistemlerde felaket hatalarını önleyen ve şeffaflığı sağlayan standart bir güvenlik yaklaşımıdır13. |

## **3\. Literatür Sentezi ve İleri Düzey Planlama Kuramı**

Yapay zekâ otonom kodlama ajanlarının yazılım geliştirme süreçlerine entegrasyonu, yazılım mühendisliği disiplinini derinden dönüştürmektedir. Bu dönüşümün merkezinde, deterministik olmayan (her çalıştırıldığında farklı sonuç verebilen) çıktıların, deterministik (kesin kurallara dayalı) sistemlere nasıl uyarlanacağı sorunu yatmaktadır. Bu bağlamda, kullanıcının araştırma soruları dört ana eksende (Planın Kalitesi, Riski Erken Görmek, Belgeden Plana Geçişte Otonomi ve Mimari Kaymayı Yönetmek) ele alınarak kapsamlı bir sentez sunulmuştur.

### **3.1. Planın Kalitesi, Kararlılığı ve Şartname Yönelimli Geliştirme**

Yazılım geliştirme süreçlerinde yapay zekâ asistanlarının kullanımı arttıkça, salt istem (prompt) odaklı yaklaşımların yerini Şartname Yönelimli Geliştirme (Spec-Driven Development \- SDD) metodolojilerine bıraktığı gözlemlenmektedir. Geleneksel Çevik (Agile) yöntemler, insan hızına ve insan hesap verebilirliğine göre tasarlandığından, çalışan yazılımı belgelendirmenin önünde tutar1. Ancak kod üretim hızının insan inceleme hızını aştığı yapay zekâ çağında, bu yaklaşım sürdürülebilir değildir. Araştırmalar, açık kaynaklı yapay zekâ ajan çerçevelerindeki test çabalarının %70'inin deterministik altyapılara odaklandığını, en değişken ve riskli kısım olan büyük dil modeli bileşenlerinin ise yalnızca %1 oranında test kapsamına sahip olduğunu göstermektedir14. Bu durum bir ihmalden ziyade, ortada test edilebilecek kesin bir şartnamenin (sözleşmenin) olmamasından kaynaklanır.  
SDD, GitHub Spec Kit ve BMad (Breakthrough Method for Agentic Development) gibi çerçeveler aracılığıyla bu sorunu çözer. Bu yaklaşımlarda kod geçici bir çıktı (temporal), spesifikasyonlar ve belgeler ise kalıcı gerçeklik kaynağı (source of truth) olarak kabul edilir2. İyi bir yazılım planının ajanlar için ne içermesi gerektiği incelendiğinde, başarı ölçütü, kabul kriteri ve özellikle arayüz tanımının kritik olduğu görülmektedir. Arayüz tanımlarının baştan yapılması, LLM'lerin "yerel optimizasyon" yapma eğilimine karşı bir güvenlik duvarı işlevi görür. Ajanlar, kısıtlı bağlam pencereleri nedeniyle genellikle üzerinde çalıştıkları modül için en şık ve yerel olarak doğru kodu yazarlar, ancak bu kod sistemin genel mimarisiyle veya diğer modüllerle uyumsuz olabilir7. Arayüzlerin ve girdi/çıktı sözleşmelerinin erken tanımlanması, sonraki aşamalar için bir sözleşme yaratarak, sonradan ortaya çıkabilecek mimari uyuşmazlıkları engeller.  
Planın ayrıntı düzeyi (task granularity), model performansını doğrudan etkileyen bir diğer önemli parametredir. Deneysel çalışmalar, görev karmaşıklığı arttıkça ve ajanlardan tek seferde büyük bir sistem tasarlamaları istendiğinde, modellerin kod üretme kalitesinde ve başarı oranlarında (pass rate) ciddi düşüşler yaşandığını ortaya koymaktadır16. CodePlan gibi yaklaşımlar, depo (repository) düzeyindeki büyük görevleri çok adımlı bağımlılık zincirlerine bölerek çözmeyi önerir19. Tek kişilik bir projede yapay zekâ destekli geliştirme yapılırken, uzak hedeflerin (örneğin projenin 8\. veya 9\. aşamasının) aşırı ayrıntılandırılması kesinlikle zararlıdır. Uzak gelecekteki görevlerin detaylandırılması, hem bağlam penceresini gereksiz yere doldurarak modelin dikkatini dağıtır hem de erken soyutlama (premature abstraction) riskini doğurur. Yuvarlanan dalga planlaması (rolling wave planning), mevcut aşamanın test edilebilir en küçük adımlara, sonraki aşamaların ise yalnızca kaba amaçlara indirgendiği bir yapı sunarak bu sorunu verimli bir şekilde çözer.

### **3.2. Riski Erken Görmek ve Dil Modellerinde Kendi Kendini Düzeltme Yanılgısı**

Riskli varsayımları erken sınamak, yapay zekâ destekli geliştirmede yalnızca bir iyi pratik değil, sistemin çökmesini engelleyen yapısal bir zorunluluktur. Keşif denemeleri (spike) ve çalışan iskelet (walking skeleton) pratikleri, otonom ajanların ürettiği kodu en kısa sürede dış dünyanın (derleyici, test ortamı, harici API'ler) gerçekliğiyle yüzleştirir. Ajanlar, halüsinasyon yoluyla ürettikleri ancak sözdizimsel olarak kusursuz görünen kodlara aşırı güven duyma eğilimindedir. Hatalar ancak kod çalıştırıldığında ve bir hata izi (stack trace) üretildiğinde ajanın dikkatini çekebilir9.  
Kullanıcının taslak yönteminde yer alan "planı ikinci bir modele (örneğin Codex'e) eleştirtme" adımı, literatürdeki son bulgular ışığında ciddi bir kavramsal hata barındırmaktadır. Kapsamlı ampirik araştırmalar, büyük dil modellerinin dış bir geri bildirim olmaksızın kendi muhakemelerindeki hataları kendi kendilerine düzeltemediklerini kesin olarak kanıtlamıştır8. Derinlemesine analizler, modellerin "kendi kendini düzeltme" (intrinsic self-correction) girişimlerinin çoğunlukla performansı artırmadığını, aksine doğru cevaplardan saparak performansı düşürdüğünü göstermektedir10. Bir modelin kendi ürettiği planı eleştirmesi veya birden fazla ajanın kendi aralarında tartışması (multi-agent debate), eğer ortada yürütülebilir bir kod, derleyici hatası veya "kahin etiketi" (oracle label) yoksa, basit çoğunluk oylamasından daha iyi bir sonuç vermemektedir11. Bu nedenle, ajanın ürettiği planı başka bir ajana eleştirtmek yerine, o planın en riskli parçasını hemen koda döküp derleyiciye veya test ortamına sunmak, riskleri erken görmek açısından tek geçerli yöntemdir.  
Ön-ölüm (pre-mortem) analizi ise, ajanların zayıf yönlerini dengelemek için kullanılabilecek stratejik bir tekniktir. Ön-ölüm analizi, projenin en baştan başarısız olduğunu varsayarak geriye dönük hata nedenlerini bulmayı hedefler22. Ancak, ajana sadece "bir ön-ölüm analizi yap" denildiğinde, model genellikle "zaman yetersizliği", "iletişim eksikliği" gibi genelgeçer ve eyleme dönüştürülemeyen riskler üretir24. Ajanın gerçekten içgörülü bir ön-ölüm analizi yapabilmesi için riskler sınıflandırılmalıdır. Psikolojik araştırmalara dayanan sınıflandırmaya göre riskler; gerçek ve yıkıcı "Kaplanlar" (Tigers), düşük olasılıklı anksiyete kaynağı "Kâğıttan Kaplanlar" (Paper Tigers) ve kimsenin konuşmak istemediği gizli "Filler" (Elephants) olarak ayrılır12. Ajanın planlama aşamasında yalnızca projeyi durdurabilecek kapasitedeki 2-3 spesifik "Kaplan" riskine odaklanması, halüsinasyonları filtreleyerek uygulanabilir bir risk analizi sunar.

### **3.3. Belgeye Sadakat, Otonomi ve Ortada Kaybolma Olgusu**

Ajanın sağlanan araştırma belgelerine sıkı sıkıya bağlı kalması ile kendi inisiyatifini kullanması arasındaki denge, otonom yazılım mühendisliğinin en kırılgan noktalarından biridir. Ajanlar uzun araştırma belgelerini işlerken, literatürde "ortada kaybolma" (lost-in-the-middle) olarak bilinen bir bilişsel zafiyet sergilerler. Kapsamlı analizler, büyük dil modellerinin geniş bağlam pencerelerinde (long contexts) yer alan verileri işlerken, bağlamın en başındaki ve en sonundaki bilgileri yüksek doğrulukla hatırladıklarını, ancak belgenin ortasında yer alan kritik bilgileri büyük oranda göz ardı ettiklerini göstermektedir3. Çok turlu konuşmalarda ve parçalanmış bilgi kümelerinde bu zafiyet daha da derinleşir ve ajan, önceki kısıtları unutarak sistemin bütünlüğünü bozacak iddialar üretebilir28.  
Buna karşın, belgeye aşırı sadakat de eşit derecede tehlikelidir. Ajan, sağlanan araştırma belgelerindeki eskimiş kütüphane sürümlerini, hatalı varsayımları veya verimsiz mimari tasarımları sorgulamadan plana dahil edebilir. Bu iki sorunu aynı anda çözmek için "köken izlenebilirliği" (provenance) veya köken farkındalıklı karar denetimi (provenance-aware decision auditing) teknikleri uygulanmalıdır4. Köken izlenebilirliği, ajanın ürettiği her iddianın, gereksinimin veya kararın kaynağının açıkça etiketlenmesini şart koşar. Ajan, dışarıdan aldığı bilgileri \[Kaynak: docs/arastirma/genel/auth.md\] formatında etiketlerken, belgedeki bir eksikliği kendi bilgisiyle doldurduğunda veya belgedeki bir yanlışa daha iyi bir alternatif sunduğunda bunu \[Ajan Önerisi: Güvenlik riski nedeniyle JWT yerine oturum çerezi kullanılması\] şeklinde şeffafça bildirmek zorundadır. Bu yöntem, ajanın zımni varsayımlar yapmasını engeller, halüsinasyonların kökenini açığa çıkarır ve insana (geliştiriciye) hangi kararların belgelere, hangilerinin ajanın muhakemesine dayandığını denetleme imkânı verir.  
Ajanın planlama sırasında soru sorması ile varsayım yaparak ilerlemesi arasındaki denge de verimlilik açısından kritiktir. Yüksek düzeyde etkileşim gerektiren çerçeveler, sürekli onay isteyen mekanizmalarıyla "istem yorgunluğu" (prompt fatigue) yaratabilir5. Pratik denge; ajanın düşük riskli veya standart mühendislik kararlarında açıkça etiketlenmiş varsayımlar (\[Varsayım\]) yaparak ilerlemesi, veri modeli, dış arayüz entegrasyonları, kimlik doğrulama veya güvenlik gibi geri alınması zor ve yüksek riskli konularda ise kesin alternatifler sunarak daraltılmış sorular sormasıdır.

### **3.4. Değişiklik Yönetimi, Ajan Entropisi ve Çerçeve Analizleri**

Planların proje ilerledikçe değişmesi kaçınılmazdır; ancak bu değişikliğin yönetilmemesi, literatürde "ajan entropisi" (agentic entropy) olarak tanımlanan yapısal bozulumlara yol açar. Ajan entropisi, otonom güncellemelerin zamanla mimari niyetten sapması sürecidir ve geride "ajanik teknik borç" (agentic technical debt) ile kod tabanında karmaşık bir yama ağı bırakır7. Ajanlar, bağlam kısıtlamaları nedeniyle genellikle yerel optimizasyon yapar ve "kitaplık" (textbook) çözümler uygularlar; bu durum, sistemin genel güvenlik ve mimari kısıtlamalarını ihlal eden fragmanların birikmesine neden olur7. Daha da kötüsü, ajan entropisi derinleştikçe, insan geliştiricinin sistemi anlama kapasitesi düşer ve bu duruma "bilişsel borç" (cognitive debt) adı verilir7.  
Bilişsel borcu ve mimari kaymayı önlemenin en etkili yolu, KARARLAR.md veya benzeri bir dosya üzerinden Mimari Karar Kaydı (Architecture Decision Record \- ADR) mekanizmasını işletmektir6. Plan değiştiğinde veya yeni bir bilgi ortaya çıktığında, ajanın değişikliği doğrudan uygulaması yerine, arka plandaki nedeni, reddedilen alternatifleri ve seçilen yolun gerekçesini belgelemesi sağlanır. Bu yaklaşım, sadece insanın sistemi anlamasını sağlamakla kalmaz, aynı zamanda ajanın gelecekteki oturumlarda aynı hatalı yolları tekrar denemesini engeller.  
Bu süreçte AGENTS.md, PLAN.md ve .cursorrules gibi kalıcı yapılandırma belgelerinin, kod değiştikçe eskiyerek güncelliğini yitirmesi de önemli bir sorundur. Buna literatürde "bağlam çürümesi" (context rot) adı verilir. Araştırmalar, açık kaynaklı projelerdeki yapay zekâ yapılandırma dosyalarının yaklaşık %23'ünün güncelliğini yitirmiş ölü kod veya mimari referanslar barındırdığını göstermektedir31. Bağlam çürümesini önlemek için, biten her aşamanın sonunda ajanın mevcut kodu inceleyerek PLAN.md dosyasındaki kaba başlıkları detaylandırması ve planın doğruluğunu sistemin o anki (HEAD) durumuyla eşitlemesi gerekir.  
Benzer araçların planlama yaklaşımları karşılaştırıldığında, tek kişilik projeler için optimum stratejinin hibrit bir yapı olduğu görülmektedir.

| Çerçeve / Araç | Temel Yaklaşım | Tek Kişilik Proje (Python/VS Code) İçin Etkisi |
| :---- | :---- | :---- |
| **BMad (Breakthrough Method)** | Dokümanları merkez alan ağır spesifikasyon ve çoklu ajan iş akışı2. | Kavramsal olarak (hikayelere bölme) mükemmeldir ancak çok sayıda belge üretimi ve yüksek jeton tüketimi, tek kişilik projede aşırı bürokrasi (ceremony) yaratır2. |
| **GitHub Spec Kit** | Şartnameden plana ve görevlere doğru katı hiyerarşik yapı (spec → plan → tasks)15. | Arayüz sınırlarını belirlemede faydalıdır, ancak küçük görevlerde fazla katıdır. Temel ilkeleri alınmalıdır. |
| **Kiro Spec Mode** | Girdi, çıktı ve modül davranışlarını derleyici gibi doğrulayan spesifikasyon kipi34. | Kesin arayüz sözleşmeleri (interface contracts) tanımlamak için idealdir. "Arayüzleri baştan tanımla" kuralı bu araçtan ilham alır. |
| **Claude Code Plan Mode** | Hızlı geri bildirim döngüleri, terminal üzerinden doğrudan keşif (explore) ve plan onayı mekanizması13. | Ajanla etkileşimli, düşük bürokrasili ve anında müdahale edilebilir bir planlama sunar. Taslak yöntemin merkezinde tutulmalıdır. |

Kapsamlı bir inceleme, tüm mimarinin yapay zekâ tarafından en başta oluşturulduğu (Big Design Up Front) modellerin, bağlam zehirlenmesine ve geri alınamaz yapısal hatalara yol açtığını kanıtlamaktadır. Bunun yerine, Claude Code'un plan modunda uygulandığı gibi, belirsizliğin yüksek olduğu yerlerde planlama yapılması, basit görevlerde ise doğrudan uygulamaya geçilmesi önerilmektedir13.

## **4\. Önerilen Son Planlama Akışı**

Taslak akışın ampirik bulgular ışığında güncellenmiş ve tek kişilik projeler için gereksiz bürokrasiden arındırılmış son hali aşağıda numaralandırılmıştır. Belirtilen adımların tamamı geliştiricinin kullandığı terminal (Claude Code) ve editör ortamında uygulanabilir.

> 1. **Araştırma ve Bağlam Beslemesi (İnsan):** İnsan geliştirici, deep research ile topladığı belgeleri docs/arastirma/genel/ içerisine koyar. Bu yapı, ajanın okuyacağı referans havuzunu oluşturur.  
> 2. **Bağlam Analizi ve Köken Etiketlemesi (Ajan):** Ajan belgeleri tarayarak gereksinimleri, dış arayüzleri ve başarı ölçütlerini çıkarır. Bu adımda ajan, her bir maddeyi zorunlu olarak etiketler:  
   * Belgeden gelen veriler için \[Kaynak\].  
   * Eskimiş bilgiye veya eksik belgelere karşı sunduğu mimari düzeltmeler için \[Ajan Önerisi\].  
> 3. **Ön-Ölüm ve Yüksek Risk Analizi (Ajan):** Ajan, projeyi tehlikeye atabilecek en olası 2 veya 3 spesifik "Kaplan" riskini (kütüphane uyumsuzluğu, hız darboğazı, güvenlik kısıtı) listeler. Ajan, yalnızca bu yüksek riskler veya veri modeli kararları için insana daraltılmış (seçenekli) bir soru sorar.  
> 4. **Keşif Denemesi (Spike) Kararı (İnsan):** (Küçük veya standart projelerde atlanabilir). Eğer ajanın belirttiği risk yüksekse ve salt metinsel olarak çözülemiyorsa, insan ajandan "Bana 10 dakikada bu veritabanı bağlantısının çalıştığını kanıtlayan bir spike kodu yaz" komutu verir. Gelen hata kodları ajanı düzeltir.  
> 5. **Yuvarlanan Dalga Plan Taslağının Çıkarılması (Ajan):** Ajan PLAN.md dosyasını oluşturur. Proje ana başlıklara bölünür. Ajan *yalnızca Aşama 1'i* alt adımlara (1.1, 1.2), dosya isimlerine ve arayüz sözleşmelerine kadar detaylandırır. Uzak aşamalar (Aşama 2, 3...) sadece "Amaç" ve "Bitti Ölçütü" cümlesi olarak kaba bırakılır.  
> 6. **Mimari Karar Kaydı (Ajan):** Planlama sırasında alınan kritik teknoloji yığını veya altyapı kararları KARARLAR.md dosyasına kısa bir formata (Alternatif, Karar, Gerekçe) yazılarak mühürlenir.  
> 7. **Uygulama ve Donma (İnsan & Ajan):** İnsan planı onaylar. Ajan Aşama 1.1'i kodlamaya başlar. Bir ana başlığın tüm alt adımları bitip testleri geçtiğinde, o aşamanın dışarıya açık arayüzleri "donmuş" (frozen) kabul edilir. Ajan planlama moduna döner, Aşama 2'yi ince ince detaylandırır ve plan güncellenir.

## **5\. AGENTS.md Planlama Kuralı Taslağı**

Yapay zekâ ajanları, uzun ve karmaşık talimat setleri karşısında yönergelere uyma (instruction following) kapasitelerini yitirirler5. Bu nedenle AGENTS.md dosyası, ajanı algoritmik olarak kısıtlayan bir emir zinciri değil, onun bağımsız muhakemesini yapılandıran, duruma göre adım atlamasına izin veren kısa bir anayasa olmalıdır.

# **AJAN KURALLARI VE DAVRANIŞ İLKELERİ (AGENTS.md)**

Sen yetkin bir yazılım mühendisi ajansın. Amacımız kaliteli, kararlı ve "ajan entropisine" yenik düşmeyen yazılımlar üretmektir. Belgeleri körü körüne kopyalama; eleştirel bir gözle incele ve daha iyi bir pratik görüyorsan bunu savun.

## **PLANLAMA İLKELERİ VE KONTROL NOKTALARI**

> 1. **Köken İzlenebilirliği (Provenance Tagging):** Planı ve gereksinimleri çıkarırken şeffaf ol.  
   * Belgeden aldığın kesin bilgilerin sonuna \[Kaynak: dosya-adi.md\] ekle.  
   * Belgelerdeki eskimiş veya hatalı bilgileri düzeltmek için kendi tecrübenle sunduğun pratikler için \[Ajan Önerisi\] etiketini ve gerekçeni yaz.  
   * Bilginin eksik olduğu yerlerde yaptığın kabulleri \[Varsayım\] olarak belirt.  
> 2. **Yuvarlanan Dalga Planlaması (Rolling Wave):**PLAN.md dosyasını oluştururken tüm sistemi baştan ince ince tasarlama. Sadece hemen kodlamaya başlayacağımız *mevcut ana aşamayı* alt görevlere (arayüz, girdi/çıktı sözleşmesi seviyesinde) böl. Gelecekteki aşamaları yalnızca "Amaç" ve "Kabul Kriteri" olarak kaba bırak.  
> 3. **Ön-Ölüm Analizi (Pre-mortem) ve Daraltılmış Sorular:** Planı sunarken soyut tehlikeler (örn. bütçe, zaman) üretme. Yalnızca projeyi durdurabilecek en olası 2 spesifik mimari/teknik riski (Tigers) belirle. Sadece bu riskler veya mimari kayma yaratabilecek konularda bana kesin alternatifler sunarak soru sor. Önemsiz konularda \[Varsayım\] yaparak ilerle (İstem yorgunluğu yaratma).  
> 4. **Arayüz Sözleşmeleri:** Mevcut aşamanın adımlarını planlarken önce dışarıya açılan arayüzleri tanımla. Bir modül bitip testleri geçtiğinde, onu "donmuş" kabul et ve bir sonraki aşamada geriye dönüp mimarisini bozmaktan kaçın.

## **DEĞİŞİKLİK YÖNETİMİ**

Plan veya varsayımlar uygulama sırasında çökerse (örn. kütüphane farklı çalışıyorsa), bu değişikliği bana bildir ve onaylanınca KARARLAR.md dosyasına kısa bir ADR (Karar Kaydı) olarak ekle. Ardından PLAN.md'yi eşzamanlı olarak güncelle (Bağlam çürümesine izin verme).

## **6\. PLAN.md Şablon Önerisi**

Ajanın ve kullanıcının hızla okuyup güncelleyebileceği, gereksiz bürokrasiden arındırılmış, Markdown tablolarına dayalı şablon. Uzunluğu yaklaşık 100-150 satır bandında tutulmalı, sadece mevcut aşamanın detaylarını barındırmalıdır.

# **PROJE PLANI**

**Proje Amacı:** \[Bir veya iki cümlelik ana hedef\] **Ana Başarı Ölçütü:** \[Sistemin ne zaman tamamlanmış sayılacağına dair somut metrik/kriter\]

## **AŞAMALAR (Yuvarlanan Dalga Görünümü)**

| Aşama | Başlık | Durum | Bitti Ölçütü (Kabul Kriteri) | Bağımlılıklar |
| :---- | :---- | :---- | :---- | :---- |
| 1 | Veri Çıkarım Altyapısı | 🟢 Aktif | PDF dosyaları okunup JSON çıktısı veriliyor. | \- |
| 2 | LLM Entegrasyonu | ⚪ Bekliyor | JSON verisi LLM'e gönderilip yapılandırılmış yanıt alınıyor. | Aşama 1 |
| 3 | CLI Arayüzü | ⚪ Bekliyor | Komut satırından parametre alınarak süreç başlatılabiliyor. | Aşama 2 |

## **🟢 MEVCUT AŞAMA DETAYI: Aşama 1 \- Veri Çıkarım Altyapısı**

**Kaynak Belgeler:** docs/arastirma/genel/parser.md**Arayüz Sözleşmesi:** def parse\_pdf(file\_path: str) \-\> dict:**Spesifik Riskler:** PyPDF2 kütüphanesinin tabloları okurken veriyi bozması (Tigers riski).

### **Adımlar Tablosu**

| Adım | İş Paketi / Bileşen | Durum | Test | Commit | Köken / Not |
| :---- | :---- | :---- | :---- | :---- | :---- |
| 1.1 | PyMuPDF kütüphanesinin projeye dahil edilmesi | ✅ Bitti | \[x\] | feat: setup pymupdf | \[Ajan Önerisi: PyPDF2 yerine PyMuPDF tablo okumada daha kararlı\] |
| 1.2 | parse\_pdf arayüzünün oluşturulması ve hata yakalama | 🚧 Sürüyor | \[ \] | \- | \[Kaynak: parser.md\] |
| 1.3 | Çıktının JSON formatına doğrulanarak (Pydantic) çevrilmesi | ⚪ Bekliyor | \[ \] | \- | \[Varsayım: Veri bütünlüğü için doğrulama gerekiyor\] |

*(Not: Mevcut aşama tamamen bittiğinde, "Aktif" etiketi Aşama 2'ye kaydırılır. Ajan, planlama modunda Aşama 2'yi detaylandırır. Biten aşamanın detayları arşive kaldırılır veya silinir.)*

## **7\. Doğrulanamayanlar ve Kendim Denemem Gerekenler**

Bu analiz güncel hakemli araştırmalara, ön baskılara (pre-prints) ve büyük dil modellerinin yapısal kısıtlarına dayanarak oluşturulmuş olsa da, bazı spesifik iş akışları kişisel projelerde (özellikle Windows 11 / VS Code ortamında) pratik doğrulama gerektirmektedir.  
Birinci belirsizlik alanı, Claude Code ve OpenAI Codex arasında yapılan model geçişlerinin projeye etkisidir. Literatür, salt muhakeme odaklı modellerin (Opus) planlama aşamasında kullanılıp, uygulamanın (execution) daha hızlı modellere devredilmesinin teorik olarak verimli olduğunu göstermektedir. Ancak, iki farklı otonom ajan (veya model arayüzü) arasında geçiş yaparken, DEVAM.md gibi manuel bağlam taşıma dosyalarının yaşatacağı jeton (token) kaybı ve bağlam erozyonu tam olarak ölçülmemiştir. Opus'un zihnindeki bağlamsal yapıların, özet bir metin dosyası üzerinden Codex'e ne kadar kayıpsız aktarılabileceği, pratikte deneyimlenmesi gereken bir sürtünme (friction) noktasıdır.  
İkinci belirsizlik alanı, "Ortada Kaybolma" (lost-in-the-middle) olgusunun tek kişilik projelerdeki fiziksel eşiğiyle ilgilidir. Araştırmalar, belgeler uzadıkça modelin performanstan ödün verdiğini kesin olarak kanıtlamış olsa da3, docs/arastirma/genel/ klasörünün maksimum kaç sayfaya veya kaç jetona kadar verimli çalışacağı, modele özgü dikkat mekanizmalarına (attention mechanism) bağlıdır. Projelerinizde toplanan araştırma belgelerinin bağlam penceresini boğmaması için ampirik denemelerle bir üst sınır (örneğin 10.000 veya 30.000 jeton) belirlemeniz faydalı olacaktır.  
Son olarak, AGENTS.md dosyasındaki "Köken Etiketleme" (Provenance Tagging) kuralının ajanın davranışlarını ne kadar istikrarlı bir şekilde şekillendireceği, ajanın anlık sürümlerine göre değişkenlik gösterebilir. Sistemin serbest metin üretirken her seferinde \[Ajan Önerisi\] veya \[Kaynak\] etiketlerini kullanmaya ne kadar sadık kaldığı, özellikle uzun oturumlarda bizzat test edilmeli ve kurala uyum zayıfladığında ajan uyarılmalıdır.  
*This is for informational purposes only. For medical advice or diagnosis, consult a professional.*

#### **Alıntılanan çalışmalar**

> 1. Spec-Driven Development for Agentic Software Engineering \- arXiv, [https://arxiv.org/html/2609.00252v1](https://arxiv.org/html/2609.00252v1)  
> 2. What Is the BMAD Method? Agent-Driven AI Development Guide, [https://www.augmentcode.com/guides/bmad-method-ai-development](https://www.augmentcode.com/guides/bmad-method-ai-development)  
> 3. Lost in the Middle: How Language Models Use Long Contexts \- arXiv, [https://arxiv.org/abs/2307.03172](https://arxiv.org/abs/2307.03172)  
> 4. Provenance-Aware Decision Auditing for LLM Agents, [https://agentpatterns.ai/security/provenance-aware-decision-auditing/](https://agentpatterns.ai/security/provenance-aware-decision-auditing/)  
> 5. A Framework, Evaluation, Mitigation of Coding Agent Failures \- arXiv, [https://arxiv.org/pdf/2606.19380](https://arxiv.org/pdf/2606.19380)  
> 6. A Lean and Spec-Driven AI-Assisted Software Development ... \- arXiv, [https://arxiv.org/pdf/2609.24348](https://arxiv.org/pdf/2609.24348)  
> 7. Beyond the 'Diff': Addressing Agentic Entropy in Agentic Software, [https://arxiv.org/html/2604.16323v2](https://arxiv.org/html/2604.16323v2)  
> 8. Large Language Models Cannot Self-Correct Reasoning Yet \- arXiv, [https://arxiv.org/html/2310.01798v2](https://arxiv.org/html/2310.01798v2)  
> 9. SR-Eval: Evaluating LLMs on Code Generation under Stepwise, [https://arxiv.org/html/2509.18808v2](https://arxiv.org/html/2509.18808v2)  
> 10. Large Language Models Cannot Self-Correct Reasoning Yet, [https://openreview.net/forum?id=IkmD3fKBPQ](https://openreview.net/forum?id=IkmD3fKBPQ)  
> 11. LLMs Lack Intrinsic Self-Correction in Reasoning \- Emergent Mind, [https://www.emergentmind.com/papers/2310.01798](https://www.emergentmind.com/papers/2310.01798)  
> 12. Pre-Mortem Guide \- borghei/Claude-Skills \- GitHub, [https://github.com/borghei/Claude-Skills/blob/main/project-management/discovery/pre-mortem/references/pre-mortem-guide.md](https://github.com/borghei/Claude-Skills/blob/main/project-management/discovery/pre-mortem/references/pre-mortem-guide.md)  
> 13. Claude Code Plan Mode: When to Plan, When to Build ... \- AgentGrid, [https://agentgrid.sh/stories/claude-code-plan-mode](https://agentgrid.sh/stories/claude-code-plan-mode)  
> 14. Spec-Driven Development Is the Missing Layer for Deterministic, [https://medium.com/@technologuy/spec-driven-development-is-the-missing-layer-for-deterministic-evals-in-llm-powered-apps-2bcb45ec45f0](https://medium.com/@technologuy/spec-driven-development-is-the-missing-layer-for-deterministic-evals-in-llm-powered-apps-2bcb45ec45f0)  
> 15. spec-kit/AGENTS.md at main \- GitHub, [https://github.com/github/spec-kit/blob/main/AGENTS.md](https://github.com/github/spec-kit/blob/main/AGENTS.md)  
> 16. Leveraging Large Language Models for Automated Reproduction of, [https://arxiv.org/html/2509.21074v3](https://arxiv.org/html/2509.21074v3)  
> 17. Unlocking the Power of Graph Neural Networks—A Systematic, [https://www.sciopen.com/article/10.32604/cmes.2026.080382](https://www.sciopen.com/article/10.32604/cmes.2026.080382)  
> 18. OEMA: ontology-enhanced multi-agent collaboration framework for, [https://academic.oup.com/jamiaopen/article/9/3/ooag049/8678312](https://academic.oup.com/jamiaopen/article/9/3/ooag049/8678312)  
> 19. (PDF) CodePlan: Repository-Level Coding using LLMs and Planning, [https://www.researchgate.net/publication/382231473\_CodePlan\_Repository-Level\_Coding\_using\_LLMs\_and\_Planning](https://www.researchgate.net/publication/382231473_CodePlan_Repository-Level_Coding_using_LLMs_and_Planning)  
> 20. Large Language Models Cannot Self-Correct Reasoning Yet \- arXiv, [https://arxiv.org/abs/2310.01798](https://arxiv.org/abs/2310.01798)  
> 21. Learning to Check: Enhancing Self-Correction Capabilities in Large, [https://arxiv.org/html/2402.13035v3](https://arxiv.org/html/2402.13035v3)  
> 22. The Pre-Mortem. A proven strategy for project success | Bootcamp, [https://medium.com/design-bootcamp/the-pre-mortem-5313a4138012](https://medium.com/design-bootcamp/the-pre-mortem-5313a4138012)  
> 23. Pre-Mortems in Project Management: A Practical Guide for Teams, [https://maddevs.io/blog/mastering-project-pre-mortems-guide/](https://maddevs.io/blog/mastering-project-pre-mortems-guide/)  
> 24. How to Run a Pre-Mortem Before You Launch an AI Project, [https://sagnikbhattacharya.com/blog/pre-mortem-ai-project](https://sagnikbhattacharya.com/blog/pre-mortem-ai-project)  
> 25. How premortem prompts make Claude stop agreeing with you, [https://medium.com/devsecops-ai/how-premortem-prompts-make-claude-stop-agreeing-with-you-d48488ffcb4d](https://medium.com/devsecops-ai/how-premortem-prompts-make-claude-stop-agreeing-with-you-d48488ffcb4d)  
> 26. LLM-based Triplet Extraction from Financial Reports \- arXiv, [https://arxiv.org/html/2602.11886v1](https://arxiv.org/html/2602.11886v1)  
> 27. What Works for 'Lost-in-the-Middle' in LLMs? A Study on GM-Extract, [https://arxiv.org/html/2511.13900v1](https://arxiv.org/html/2511.13900v1)  
> 28. LLMs Get Lost In Multi-Turn Conversation \- arXiv, [https://arxiv.org/pdf/2505.06120](https://arxiv.org/pdf/2505.06120)  
> 29. Lost in the Middle: How Language Models Use Long Contexts, [https://cs.stanford.edu/\~nfliu/papers/lost-in-the-middle.arxiv2023.pdf](https://cs.stanford.edu/~nfliu/papers/lost-in-the-middle.arxiv2023.pdf)  
> 30. Data Provenance: Benefits, Use Cases and Tools | Acceldata, [https://www.acceldata.io/blog/data-provenance](https://www.acceldata.io/blog/data-provenance)  
> 31. Context Rot in AI-Assisted Software Development \- arXiv, [https://arxiv.org/html/2606.09090v1](https://arxiv.org/html/2606.09090v1)  
> 32. What is BMAD-METHOD™? A Simple Guide to the Future of AI, [https://medium.com/@visrow/what-is-bmad-method-a-simple-guide-to-the-future-of-ai-driven-development-412274f91419](https://medium.com/@visrow/what-is-bmad-method-a-simple-guide-to-the-future-of-ai-driven-development-412274f91419)  
> 33. Spec Kit Documentation \- GitHub Pages, [https://github.github.com/spec-kit/](https://github.github.com/spec-kit/)  
> 34. How Kiro's Spec Mode Hints at the Future of Software Engineering, [https://medium.com/@arslan70/how-kiros-spec-mode-hints-at-the-future-of-software-engineering-240bb3091ed3](https://medium.com/@arslan70/how-kiros-spec-mode-hints-at-the-future-of-software-engineering-240bb3091ed3)  
> 35. 10 Claude Code Best Practices for Agentic Coding: A 2026 Guide, [https://www.openhands.dev/blog/claude-code-best-practices-agentic-coding](https://www.openhands.dev/blog/claude-code-best-practices-agentic-coding)