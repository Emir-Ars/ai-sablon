# **"ai-sablon" Kişisel Yapay Zekâ Çalışma Düzeni Şablonunun Eleştirel Değerlendirmesi**

Yazılım mühendisliği ekosisteminde, otonom kodlama ajanlarının (Claude Code, OpenAI Codex) verimliliğini artırmak amacıyla oluşturulan kural setleri, doğru tasarlanmadığında sistemin temel zekâsını ve yürütme kapasitesini felce uğratabilmektedir. Bir yazılım stajyeri tarafından Windows 11 ve PowerShell 5.1 ortamında kullanılmak üzere tasarlanan "ai-sablon" adlı kişisel çalışma düzeni, disiplin ve kontrol sağlama niyetiyle inşa edilmiş olsa da, modern büyük dil modellerinin (LLM) çalışma prensipleriyle temelden çelişen bir mimariye sahiptir.  
Şablonun bağımsız ve eleştirel değerlendirmesi sonucunda, ajansal (agentic) potansiyeli kısıtlayan aşırı mikro yönetim politikalarının, hedeflenenin aksine "bilişsel yük" ve "onay yorgunluğu" yarattığı tespit edilmiştir. Yaklaşık 140 satırlık tekrar eden kural dosyaları, güncel literatürde "İleriye Dönük Bozucu Etki" (Proactive Interference) ve "Bağlam Çürümesi" (Context Rot) olarak adlandırılan performans kayıplarına zemin hazırlamaktadır. Teknik altyapıda ise, OpenAI Codex'in spesifik dosya okuma sınırları (32 KiB) ile PowerShell 5.1'in varsayılan karakter kodlama davranışları (BOM ekleme), aracın sessizce çökmesine veya en kritik proje kurallarını yok saymasına neden olabilecek zafiyetler barındırmaktadır. Yazılımın organik bir şekilde yeniden yapılandırılmasını (refactoring) engelleyen "donmuş kod" yalıtımı, orta vadede aşılamaz bir tasarım ve teknik borç birikimine yol açacaktır. Genel hatlarıyla bu şablon; modellerin zekâsını kısıtlayan, teknik uyumsuzluklar içeren ve acilen esnetilmesi gereken katı bir bürokratik katman işlevi görmektedir.

## **Yönerge Yükü, Otonomi ve Bilişsel Kısıtlamaların Etkileri**

### **Talimat Yükü ve Bağlam Çürümesi (Context Rot)**

Şablonun temelini oluşturan ve CLAUDE.md ile AGENTS.md dosyalarına kopyalanan yaklaşık 140 satırlık yoğun kural seti, modelin "talimat takip etme" (instruction-following) başarısını dramatik ölçüde düşürmektedir. Temmuz 2025'te yayımlanan *Context Rot: How Increasing Input Tokens Impacts LLM Performance* (https://research.trychroma.com/context-rot) adlı Chroma Research araştırması, modellerin bağlamı tekdüze (uniform) işlemediğini kanıtlamaktadır1. Bağlama eklenen her yeni kural (distractor), modelin asıl göreve odaklanmasını zayıflatmakta ve performans log-doğrusal (log-linear) bir çöküş yaşamaktadır1.  
Haziran 2025 tarihli, *Unable to Forget: Proactive Interference Reveals Working Memory Limits in LLMs* (arXiv:2506.08184) başlıklı makale, bu durumu "İleriye Dönük Bozucu Etki" (Proactive Interference) olarak tanımlamaktadır3. Çalışma, uzun kural dizilerinin modelin çalışma belleğini (working memory) doldurduğunu, modelin daha önceki kurallara takılı kalarak mevcut görevin güncel gereksinimlerini "unutamadığını" göstermektedir4. Şablonda yer alan "bilgi uydurma, git add . kullanma, imza atma, bom/utf-8 notlarına uy" gibi birbirinden bağımsız onlarca negatif kısıt (negative constraint), IFBench ve IFEval gibi kıyaslamalarda (benchmark) görüldüğü üzere, modellerin birleşik kısıtlamaları (constraint conjunction) anlamlandırma kapasitesini aşmaktadır6. Qwen, Sonnet veya Haiku gibi modellerin, bu tür yoğun metinlerde bağlamın ortasındaki kuralları gözden kaçırdığı (Lost in the Middle etkisi) açıkça belgelenmiştir8.

### **Mikro Yönetim ve Hız İllüzyonu**

Şablondaki "tek adım at ve dur", "önce plan, sonra onay, sonra kod" kuralı, LLM destekli yazılım geliştirme paradigmasıyla taban tabana zıttır. SWE-bench Verified gibi otonom kodlama kıyaslamaları, ajanların başarılı olabilmesi için çok turlu (multi-turn), uzun ufuklu (long-horizon) durum yönetimini dışarıdan müdahale olmadan sürdürebilmesi gerektiğini vurgular10. Ajanı her adımda durdurmak, modelin o anki kodlama akışını (contextual flow) bozarak her yeniden başlatmada bağlamın tekrar yüklenmesini (re-inference) gerektirir.  
Bunun kullanıcı üzerindeki etkisi, Mayıs 2026'da yayımlanan *Cognitive offloading and the speedup illusion in human-AI interaction* (arXiv:2605.23177) adlı araştırmada net biçimde ortaya konmuştur12. Kullanıcılar, yapay zekâyı her adımda denetlediklerinde işi daha hızlı bitirdiklerine dair bir "hız illüzyonuna" (speedup illusion) kapılmaktadırlar; oysa gerçekte sürekli onay vermek ve plan okumak, toplam geliştirme süresini artırmakta ve geliştiricinin bilişsel yorgunluğunu (cognitive offloading fatigue) derinleştirmektedir12.  
Özellikle Haiku gibi daha zayıf, hızlı ancak kısa bağlamlı modeller; parçalı talimatlara daha az uyum gösterir. Bu modeller uzun sistem komutları yerine bağlama dayalı (in-context) tekil görevlerde başarılıdır6. Yüksek kural yoğunluğu, Haiku sınıfı modellerin ana görevden tamamen saparak yalnızca kuralları tekrarlayan "aşırı hizalanmış" (over-aligned) ve işlevsiz çıktılar üretmesine neden olur.

## **Aşama Yalıtımı Kuralı ve Teknik Borç Sarmalı**

Şablonda tanımlanan "biten aşamanın kodunun donmuş sayılması" ve "yeni aşamanın eski koda yalnızca dış arayüzle (interface) erişebilmesi" stratejisi, modern yazılım mühendisliğinde tehlikeli bir anti-desendir (anti-pattern). Bu yaklaşım, yazılımın organik evrimini engelleyerek kalıcı ve derin bir teknik borç (technical debt) yaratır.  
Haziran 2026'da ACM TOSEM'de yayımlanan *Faster Code, Deeper Debt? A Multivocal Literature Review on Technical Debt and Its Early Signs in LLM-Assisted Software Development* (arXiv:2606.14796) başlıklı kapsamlı literatür taraması, LLM'lerin geleneksel tasarım ve kod borçlarını (code and design debt) katlayarak artırdığını kanıtlamaktadır15. Yapay zekâ tarafından üretilen kodlar genellikle halüsinatif referanslar, eksik soyutlamalar ve tutarsız mantık akışları içerir15. Şablonun öngördüğü şekliyle bu kodu "dondurmak", LLM'nin ürettiği ilk ve muhtemelen kusurlu tasarımın kalıcı hale gelmesi demektir.  
Yazılım mühendisliğindeki *Açık-Kapalı İlkesi (Open-Closed Principle)* ve *Semantik Versiyonlama (SemVer)* gibi pratikler, API kararlılığını savunsa da, bu kurallar sağlam, insan tarafından test edilmiş ve olgunlaşmış modüller için geçerlidir17. Geliştirme aşamasındaki bir projede (özellikle bir stajyerin öğrenme projesinde) ilk denemede kusursuz arayüzlerin tasarlanması mümkün değildir. Dondurulmuş, hatalı veya eksik bir kod modülüne yeni aşamada dışarıdan bağlanmaya çalışmak; ajanı sürekli geçici çözümler (workarounds), gereksiz sarmalayıcılar (wrappers) ve kod kopyalama (copy-paste) davranışlarına itecektir15. Bu durum, projenin sürdürülebilirliğini kısa sürede yok edecektir.

## **Teknik Doğruluk ve Araç Çatışmaları**

Bu bölümde şablonun kuralları, araçların (Claude Code ve OpenAI Codex) resmî belgelenmiş davranışları, Windows 11 ortamının getirdiği kısıtlamalar ve PowerShell 5.1 riskleri üzerinden teknik bir süzgeçten geçirilmektedir.

### **Claude Code: İçe Aktarma, Hafıza ve Çatışan Kurallar**

Şablon, CLAUDE.md üzerinden @AGENTS.md, @PLAN.md, @DEVAM.md gibi dosyaların içe aktarılmasını (import) ve hafıza limitlerinin korunmasını öngörmektedir. Ancak Claude Code dokümantasyonuna göre (Ocak-Nisan 2026 belgeleri), yaygın olarak bilinen "200 satır sınırı" efsanesi CLAUDE.md için değil, yalnızca Claude'un kendi oluşturduğu MEMORY.md (Auto Memory) dosyası için geçerlidir18. CLAUDE.md dosyası ne kadar uzun olursa olsun oturum başlangıcında belleğe *tamamen* yüklenir. @import sözdizimi 4 derinliğe kadar çalışsa da20, bu işlem oturum açılışında tüm dosyaların metinlerinin birleştirilerek bağlama yığılmasıyla sonuçlanır; dolayısıyla token maliyeti veya bağlam ekonomisi açısından hiçbir fayda sağlamaz, aksine "Context Rot" etkisini şiddetlendirir18.  
Ayrıca şablonun doğal dille "imza atma" (Co-Authored-By) veya "hafızayı kullanma" demesi araç sınırlarıyla doğrudan çatışır. Claude Code, bu tür temel davranışlar için CLAUDE.md içindeki tavsiye niteliğindeki (advisory) metinleri sık sık göz ardı eder. Mutlak denetim, deterministik olan .claude/settings.json ile sağlanır22. Otomatik hafızanın kapanması için doğal dil emri yerine settings.json içinde "autoMemoryEnabled": false24 ve imzanın kapatılması için "attribution": { "commit": "", "pr": "" } ayarı mutlak olarak kullanılmalıdır26.

### **OpenAI Codex: 32 KiB Felaketi ve Hiyerarşi**

Şablonun en büyük teknik kırılım noktası Codex'in çoklu AGENTS.md işleme mekanizmasında yatmaktadır. Şablon, \~140 satırlık genel kuralı hem global (\~/.codex/AGENTS.md) hem de projeye özel dizinlerde kullanmayı önermektedir.  
Ancak OpenAI Codex (v0.155 vb.), dizin ağacındaki AGENTS.md dosyalarını kökten uca okurken project\_doc\_max\_bytes adlı varsayılan 32 KiB boyut sınırını uygular29. Codex hiyerarşisi şu şekildedir: Global dizin \-\> Proje Kök Dizini \-\> Çalışma Dizini (CWD) altındaki dosyalar30. Okuma yukarıdan aşağıya yapıldığı için, eğer kök dizindeki \~140 satırlık şablon dosyaları bu limiti doldurursa, Codex 32 KiB eşiğine ulaştığında okumayı durdurur. Bunun yıkıcı sonucu şudur: Çalışma dizinine en yakın olan, yani o anki görev için *en spesifik ve en hayati olan* yerel proje kuralları (örneğin spesifik bir modülün derleme kuralı) 32 KiB sınırına takıldığı için sessizce çöpe atılır30. Model, bu sessiz silinme (silent truncation) nedeniyle yerel bağlamdan tamamen bihaber çalışacaktır.

### **Windows 11 ve PowerShell 5.1 Riskleri: BOM (Bayt Sırası İşareti) Problemi**

Şablon, durum.ps1 kancasını (hook) ve /devir gibi becerileri (skills) kullanmaktadır. Ancak Windows 11 üzerinde PowerShell 5.1, Out-File cmdlet'i, yönlendirme operatörü (\>) veya \-Encoding utf8 kullanıldığında dosyanın en başına 3 baytlık görünmez bir Bayt Sırası İşareti (BOM \- Byte Order Mark, \\xEF\\xBB\\xBF) yerleştirir32.  
Claude Code ve Codex'in çapraz platform JSON ve Markdown ayrıştırıcıları (örneğin Python'un tomllib kütüphanesi veya Node.js fs modülleri), BOM barındıran bu dosyaları okurken fatal (kritik) hata verir veya BOM karakterini dosyanın ilk satırındaki bir string'in parçası sanarak çöker33. SessionStart kancası, durum.ps1 çalıştırıp stdout üzerinden bağlama JSON veya düz metin enjekte ettiğinde35, PS 5.1'in fırlattığı UTF-16LE veya BOM'lu UTF-8 metni Claude Code'un kanca okuyucusunu bozar34. Bu durum, PowerShell 5.1 ortamında betiklerin doğrudan .NET sınıfları (\[System.IO.File\]::WriteAllText) kullanılarak BOM'suz UTF-8 üretmeye zorlanmasını gerektirir38.

### **SKILL.md Dosyalarının Çapraz Uyumluluğu**

Aynı SKILL.md dosyasını hem Claude Code hem de Codex'te çalıştırmak sanıldığı kadar pratik değildir. Codex, \~/.agents/skills veya \~/.codex/skills dizinlerindeki becerileri okurken, belgenin en üstünde name, description, version gibi anahtarları barındıran katı bir YAML frontmatter bloğu (metadata) bekler40. Claude Code ise yetenekler için daha çok plugins mimarisi, MCP sunucuları veya komut CLI argümanları kullanır40. YAML tabanlı bir formatı her iki aracın da kusursuz bir şekilde eşzamanlı olarak yerel yürütme (native execution) için kullanabileceğine dair resmi bir standart (agentskills.io girişimi dışında) tam olarak oturmamıştır40.

## **Proje Uygunluğu ve Mimari Karar Bakım Yükü**

Şablonun dayattığı DEVAM.md, PLAN.md, KARARLAR.md ve GUNLUK.md gibi 4 ayrı belgeyi her oturumda (session) veya devir teslimde güncel tutma zorunluluğu, projelerin doğasına göre büyük verimsizlikler yaratır.

### **Proje Türüne Göre Uygunluk Değerlendirmesi**

| Proje Türü | Uygunluk | Değerlendirme ve Mimari Etki |
| :---- | :---- | :---- |
| **Kodsuz Belge / Wiki Projesi** | **Yüksek** | Belgelerin doğası gereği statik olması, izlenebilirlik gereksinimi ve kod çalıştırılmaması nedeniyle ADR (KARARLAR.md) ve günlük (GUNLUK.md) mantığı bu türde mükemmel çalışır. |
| **Tek Kişilik Öğrenme Projesi** | **Orta** | Stajyerin disiplin kazanması için PLAN.md yararlıdır. Ancak otonomi kısıtlaması ("tek adım at"), öğrenme deneyimini bir daktilo memurluğuna dönüştürebilir. Bakım yükü öğrenciyi hızla yoracaktır13. |
| **Küçük Web Uygulaması / Prototip** | **Düşük** | Çeviklik (Agility) ve hızlı refactor esastır. React veya Vue gibi modern çerçevelerde kod dondurulamaz; şablonun hantallığı iterasyon hızını sıfıra indirir. |
| **Büyük Monorepo / Ekip Projesi** | **Çok Düşük** | Monorepolarda tek bir DEVAM.md tutmak, sürüm kontrol sisteminin (Git) doğasına aykırıdır. Ayrıca Codex'in 32 KiB sınırı büyük projelerde her halükarda aşılır ve sistem çöker30. |
| **Veri Bilimi / ML Betikleri** | **Kritik Düşük** | Veri bilimi deneysel (exploratory) ilerler. "Önce planla, onayla, tek satır kod yaz" kuralı Jupyter Notebook veya veri temizleme akışlarını imkânsız hale getirir. |

### **Bakım Yükü ve Alternatif Yöntemler (Spec Kit, BMAD, ADR)**

Yazılım mimarisinde, Architectural Decision Records (ADR \- Mimari Karar Kayıtları) gelecekteki bilgi kaybını (context rot) önlemek, kararların neden (why) alındığını belgelemek için endüstri standardıdır44. Şablonun KARARLAR.md dosyası bu standardın ilkel bir kopyasıdır. Ancak ADR'ler yalnızca mimari dönüm noktalarında yazılır; şablondaki gibi her ince aşamada AI tarafından otomatik olarak "günlük" veya "devir" notu tutulması, projenin metadata çöplüğüne dönmesine yol açar46.  
Modelin her oturumda bu 4 dosyayı güncelleyip tekrar okuması hem ciddi bir token maliyeti (bağlam maliyeti) oluşturur, hem de modelin asıl kod yerine sürekli dokümantasyonla uğraşmasına sebep olur. Oysa *GitHub Spec Kit* veya *BMAD-METHOD* (Background, Mission, Action, Deliverables) gibi modern yaklaşımlar, Spesifikasyon Odaklı Geliştirmeyi (Spec-Driven Development) savunur48. Bu yöntemlerde sistem, parçalanmış devir notları tutmak yerine tek, kapsamlı bir özellik spesifikasyonunu (feature spec) merkeze alır ve yapay zekâ bu hedefe yönelik otonom olarak (plan \-\> görevler \-\> uygulama) çalışır48. Benzer şekilde *Aider* kodlama ajanı, projenin standartlarını tek bir .aider.conventions.md dosyasında tutarak bağlamı sadeleştirir51. Bu şablon ise, gereksiz belge ayrımıyla hem API maliyetini şişirmekte hem de araçların yerleşik özelliklerini (örneğin Claude'un kendi bellek yönetimi) etkisiz bırakmaktadır.

## **Güvenlik, Dayanıklılık ve İzin Atlatma (Bypass) Riskleri**

Şablonda bulunan "izin listesi (allow/deny list)" (örn. git add ., push \--force, Read(./.env) komutlarının engellenmesi) gerçek ve mutlak bir güvenlik sağlamaz. Bu kural tabanlı (rule-based) yaklaşım, yeni nesil istem enjeksiyonu (prompt injection) saldırılarına karşı son derece kırılgandır.

### **Comment and Control Saldırısı ve Kural Aşımı**

Nisan 2026'da siber güvenlik uzmanı Aonan Guan tarafından yayımlanan *"Comment and Control: Prompt Injection to Credential Theft in Claude Code"* adlı araştırma, LLM ajanlarının kural tabanlı izinlerini nasıl kolayca aştığını kanıtlamıştır52. Saldırgan, açık kaynaklı bir projenin GitHub Issues veya Pull Request sayfasına görünmez HTML yorumları veya özel komutlar gizler52. Otonom ajan (Claude Code veya Copilot) bu veriyi okuduğunda, komut istemi enjeksiyonu tetiklenir ve ajan, orijinal kuralları (deny list) unutarak saldırganın komutlarını (örneğin .env dosyasını okuyup başka bir GitHub yorumuna veya commit mesajına sızdırmak) çalıştırır52.  
Şablonun .claude/settings.json içindeki deny kuralları, modelin kendi kararına bırakılan "ask/deny" değerlendirmesinden ibaret olduğu için bu tür varyasyonlu (zincirleme bash komutları, değişken atamaları) saldırılarla kolayca atlatılabilir (bypass)53.  
Bunun tek çözümü, kuralların üzerine işletim sistemi düzeyinde (kernel-level) izolasyon getiren Sandbox teknolojisidir. Claude Code için /sandbox mode auto-allow özelliğinin aktif edilmesi ("sandbox": { "enabled": true, "mode": "auto-allow" }), izinsiz dosya okuma ve ağ isteklerini Bubblewrap proxy teknolojisi ile çekirdek düzeyinde engeller56. Kural tabanlı korumanın sınırları vardır; gerçek güvenlik ancak Sandbox ortamıyla sağlanır56.

### **Kurulum Betiği Riskleri**

Şablondaki kur.ps1 betiğinin doğrudan kullanıcı ayar dosyalarına (User Profile Configuration) müdahale etmesi, kurumsal politikalara veya yerel Windows ExecutionPolicy (Yürütme Politikası) kurallarına çarpabilir60. Kullanıcı ortamına kontrolsüz müdahale, bağımlılıkları veya mevcut Git ayarlarını kalıcı olarak bozma riski taşır.

## **Bulgular Tablosu ve Optimizasyon Önerileri**

Aşağıdaki tablo, tespit edilen zafiyetlerin kritikliğini ve çözüm yöntemlerini adres/tarih bağlamı ile birlikte özetlemektedir:

| Bulgu ve Tespit | Etkilenen Parça | Önem | Kanıt ve Kaynak Özeti | Öneri |
| :---- | :---- | :---- | :---- | :---- |
| **PowerShell 5.1 BOM Çıktı Hatası** | durum.ps1, kur.ps1, SKILL.md çıktısı | Kritik | PowerShell 5.1'in Out-File komutu varsayılan UTF-16 veya BOM'lu UTF-8 üreterek JSON ayrıştırıcıları (tomllib) çökertir (StackOverflow 2024, Crapkit changelog)32. | Out-File yerine \[System.IO.File\]::WriteAllText() ile mutlak BOM'suz UTF-8 (New-Object System.Text.UTF8Encoding \$False) kullanılmalıdır38. |
| **32 KiB Kesinti Felaketi** | AGENTS.md, Kök Dizini Kuralları | Kritik | Codex AGENTS.md dosyalarını kökten uca okurken 32 KiB (project\_doc\_max\_bytes) sınırına ulaşırsa en alttaki spesifik çalışma dizini dosyalarını sessizce siler (Unwait AI, Prpm.dev)29. | \~140 satırlık kurallar alt dizinlere asla kopyalanmamalı, sadece \~/.codex/AGENTS.md (global) içinde bırakılmalıdır30. |
| **Tasarım ve Teknik Borç** | Aşama Yalıtımı (Donmuş Kod) | Yüksek | LLM kodu doğal olarak tutarsızlıklar ve tasarım hataları içerir. Refactor'u engellemek kod çürümesini ve teknik borcu geri dönülemez şekilde hızlandırır (ACM TOSEM Haziran 2026\)15. | "Kod donmuştur" kuralı iptal edilmeli, modelin regresyon testlerinden geçen yeniden yapılandırmalarına (refactor) olanak tanınmalıdır. |
| **İstem Enjeksiyonu ile İzin Atlatma** | settings.json İzinleri | Yüksek | GitHub Issue/PR üzerinden gelen veri, ajana komut enjekte ederek (Comment & Control) deny kurallarını aşabilir ve ortam değişkenlerini sızdırabilir (Aonan Guan, Nisan 2026\)52. | Güvenlik yalnızca "deny" listesine bırakılmamalı, OS çekirdeği tabanlı "sandbox": { "enabled": true } devreye alınmalıdır56. |
| **Bağlam Çürümesi ve Talimat Yükü** | CLAUDE.md, Belgeler (PLAN, DEVAM vb.) | Yüksek | 140 satırlık yönerge yoğunluğu, "Ortada Kaybolma" (Lost in the Middle) ve "İleriye Dönük Bozucu Etki" (Proactive Interference) ile model akıl yürütmesini zayıflatır (ICML Haziran 2025, Chroma Temmuz 2025\)1. | Belgeler 4 ayrı dosyadan çıkartılıp BMAD (Background, Mission, Action, Deliverable) veya Spec Kit tarzı tek bir özellik belgesine indirilmelidir48. |
| **Hız İllüzyonu (Bilişsel Yük)** | "Tek adım at ve dur" Kuralı | Orta | Ajanın sürekli durdurulup onay beklenmesi işi yavaşlatır, geliştiriciyi "onay yorgunluğuna" sokar ve hatalı komutların onaylanmasına neden olur (Yu et al., CogSci Mayıs 2026\)12. | Otonomi artırılmalı; "her adım" yerine "yalnızca modül tamamlandığında veya dış sistem çağrısında dur" şeklinde gevşetilmelidir. |
| **Doğal Dil ve Araç Ayarı Çatışması** | CLAUDE.md Genel Kuralları | Düşük | İmza (Co-Authored-By) eklememe ve otomatik hafıza kısıtları doğal dille söylendiğinde model tarafından ihlal edilebilir (Blog yazıları)26. | İmza ve bellek kısıtlamaları CLAUDE.md içinden silinip deterministik olarak settings.json içine attribution ve autoMemoryEnabled olarak eklenmelidir25. |

## **Kurallar Üzerine Öneriler (Kaldır, Gevşet, Ekle)**

Şablonun katı çerçevesini esneterek verimliliği artırmak ve tespit edilen hataları gidermek için uygulanması gereken yapısal değişiklikler aşağıda sıralanmıştır.

### **Kaldırılması Gereken Kurallar**

* **Yerel \~140 Satırlık Kopyalar:** OpenAI Codex'in 32 KiB sınırı nedeniyle alt dizinlerdeki yerel AGENTS.md ve CLAUDE.md dosyalarındaki uzun kural tekrarları kaldırılmalıdır. Bu kurallar sadece tek bir global dosyada yaşatılmalıdır.  
* **Aşama Yalıtımı (Donmuş Kod):** Teknik borç makalesinde de15 kanıtlandığı üzere, esnek olmayan kod yapıları çürümeye mahkumdur. Refactor yapılabilmesi adına kodun sürekli "donmuş" kalması uygulaması tamamen terk edilmelidir.  
* **4 Ayrı Durum Dosyası (PLAN, KARARLAR, DEVAM, GUNLUK):** Sürekli güncellenen 4 dosya, yapay zekânın tokenlerini tüketir ve bağlamı gereksiz bilgilerle doldurur1. Bunlar ADR44 ve Spec-driven formatlarıyla birleştirilerek tek veya iki dosyaya indirilmelidir.  
* **Doğal Dille Yazılmış Ayar Emirleri:** Otomatik hafıza kullanımı ve Git imza ayarlarının metin dosyalarından kaldırılması gerekir; çünkü dil modelleri deterministik ayarları çiğnemeye eğilimlidir.

### **Gevşetilmesi Gereken Kurallar**

* **Tek Adım At ve Dur:** Otonom görevlerde başarı için ajanın geniş ufuklu (long-horizon) hareket alanına ihtiyacı vardır11. Kural, "Yalnızca kritik mimari değişikliklerden veya canlı veritabanı işlemlerinden önce onay al" şeklinde gevşetilmelidir.  
* **Commit Öncesi Aşırı Onay:** Hem dosya listesi, hem mesaj hem de açık onay istemek "onay yorgunluğuna" (permission fatigue) neden olup güvenliği düşürür63. Ajana daha fazla güven tahsis edilmeli, salt inceleme (review) moduna geçilmelidir.

### **Eklenmesi Gereken Kurallar (Gerekçeli)**

* **settings.json Deterministik Konfigürasyonları:** Doğal dil yerine aracın ayar dosyası üzerinden kesin komutlar verilmelidir: "attribution": { "commit": "", "pr": "" } (imza atılmasını engeller) ve "autoMemoryEnabled": false (kontrolsüz hafıza oluşumunu durdurur)25.  
* **Güvenlik İçin Çekirdek Seviyesi Sandbox:** İstem enjeksiyonlarına52 karşı kuralcı listeler işe yaramaz. Güvenliği OS düzeyinde sağlamak için "sandbox": { "enabled": true, "mode": "auto-allow" } devreye alınmalıdır56.  
* **BOM Önleyici .NET Yapısı:** PowerShell ortamında dosya oluşturulurken (örn. durum.ps1) klasik Out-File yerine \[System.IO.File\]::WriteAllText(\$path, \$content, (New-Object System.Text.UTF8Encoding \$False)) eklenmelidir38.

## **Doğrulanamayan Konular ve Bireysel Test İhtiyaçları**

Literatürdeki ve belgelerdeki verilere rağmen, tam olarak öngörülemeyen ve kullanıcının (Windows 11, PowerShell 5.1) kendi donanımında bizzat test etmesi gereken bazı entegrasyon sınırları şunlardır:

> 1. **SessionStart Kancası (Hook) Gecikme Süresi (Timeout):** Windows ortamında PowerShell ve Bash için süreç başlatma (forking) süreleri, Unix ortamlarına göre çok daha uzundur (90 ms vs 2 ms)37. Claude Code'un kancalar için katı bir 10 saniye zaman aşımı limiti bulunmaktadır37. durum.ps1 betiğinin Git tarihini karşılaştırma ve dosyaları okuma süresinin bu 10 saniyelik limiti aşıp aşmadığı yerel olarak kronometreyle test edilmelidir.  
> 2. **YAML/JSON ve Becerilerin Çapraz Ayrışımı:** Aynı SKILL.md formatının (YAML frontmatter zorunluluğu40) hem Claude Code hem de OpenAI Codex tarafından ayrıştırma (parsing) hatalarına yol açmadan, tam bir ikili uyumla çalışıp çalışmadığı bizzat her iki araçta CLI logları kontrol edilerek test edilmelidir42.  
> 3. **PowerShell Çıktı Kodlamasının (Encoding) Modeli Etkilemesi:** Her ne kadar BOM'un JSON ayrıştırıcılarını bozduğu bilinse de33, Claude Code'un standart çıktı (stdout) metnini okurken en başa yapışan bu görünmez karakterleri bağlam içinde nasıl izole ettiği kesin değildir. Olası gizli karakterlerin (surrogate pairs) modelin halüsinasyon yapmasına neden olup olmadığı test edilmelidir37.

#### **Alıntılanan çalışmalar**

> 1. Context Rot: How Increasing Input Tokens Impacts LLM Performance, [https://www.trychroma.com/research/context-rot](https://www.trychroma.com/research/context-rot)  
> 2. LLM Context Rot \- Cobus Greyling \- Medium, [https://cobusgreyling.medium.com/llm-context-rot-28a6d0399655](https://cobusgreyling.medium.com/llm-context-rot-28a6d0399655)  
> 3. Proactive Interference Reveals Working Memory Limits in LLMs, [https://arxiv.org/html/2506.08184v3](https://arxiv.org/html/2506.08184v3)  
> 4. Proactive Interference Reveals Working Memory Limits in LLMs, [https://arxiv.org/pdf/2506.08184](https://arxiv.org/pdf/2506.08184)  
> 5. Unable to Forget: Proactive Interference Reveals Working Memory, [https://arxiv.org/abs/2506.08184](https://arxiv.org/abs/2506.08184)  
> 6. Instruction-Following Benchmarks: IFEval Is Saturated, IFBench, [https://zeroshotmind.com/blog/llm-eval-instruction-following](https://zeroshotmind.com/blog/llm-eval-instruction-following)  
> 7. The Instruction Gap: LLMs get lost in Following Instruction \- arXiv, [https://arxiv.org/pdf/2601.03269](https://arxiv.org/pdf/2601.03269)  
> 8. Lost in the Middle: How Language Models Use Long Contexts \- arXiv, [https://arxiv.org/abs/2307.03172](https://arxiv.org/abs/2307.03172)  
> 9. Enhancing Language Models' Ability to Reason Over Long Contexts, [https://arxiv.org/html/2412.10079v1](https://arxiv.org/html/2412.10079v1)  
> 10. SWE-EVO: Benchmarking Coding Agents in Long-Horizon Software, [https://arxiv.org/html/2512.18470v6](https://arxiv.org/html/2512.18470v6)  
> 11. SWE-Marathon: Can Agents Autonomously Complete Ultra-Long, [https://arxiv.org/html/2606.07682v1](https://arxiv.org/html/2606.07682v1)  
> 12. Cognitive offloading and the speedup illusion in human-AI interaction, [https://arxiv.org/html/2605.23177v1](https://arxiv.org/html/2605.23177v1)  
> 13. (PDF) Cognitive offloading and the speedup illusion in human-AI, [https://www.researchgate.net/publication/405221595\_Cognitive\_offloading\_and\_the\_speedup\_illusion\_in\_human-AI\_interaction](https://www.researchgate.net/publication/405221595_Cognitive_offloading_and_the_speedup_illusion_in_human-AI_interaction)  
> 14. A Benchmark for Long-Context Agentic Instruction Following \- arXiv, [https://arxiv.org/pdf/2607.25398](https://arxiv.org/pdf/2607.25398)  
> 15. (PDF) Faster Code, Deeper Debt? A Multivocal Literature Review on, [https://www.researchgate.net/publication/407116955\_Faster\_Code\_Deeper\_Debt\_A\_Multivocal\_Literature\_Review\_on\_Technical\_Debt\_and\_Its\_Early\_Signs\_in\_LLM-Assisted\_Software\_Development](https://www.researchgate.net/publication/407116955_Faster_Code_Deeper_Debt_A_Multivocal_Literature_Review_on_Technical_Debt_and_Its_Early_Signs_in_LLM-Assisted_Software_Development)  
> 16. Faster Code, Deeper Debt? A Multivocal Literature Review ... \- arXiv, [https://arxiv.org/html/2606.14796v1](https://arxiv.org/html/2606.14796v1)  
> 17. (PDF) DRAFT-ing Architectural Design Decisions using LLMs, [https://www.researchgate.net/publication/390749435\_DRAFT-ing\_Architectural\_Design\_Decisions\_using\_LLMs](https://www.researchgate.net/publication/390749435_DRAFT-ing_Architectural_Design_Decisions_using_LLMs)  
> 18. CLAUDE.md Best Practices: What the Evidence Supports (2026), [https://www.alexdunlop.com/writing/claude-md-best-practices](https://www.alexdunlop.com/writing/claude-md-best-practices)  
> 19. How Claude Code Memory Actually Works \- Mem0, [https://mem0.ai/blog/how-memory-works-in-claude-code](https://mem0.ai/blog/how-memory-works-in-claude-code)  
> 20. CLAUDE.md vs AGENTS.md: It's the Loader, Not the File, [https://www.alexdunlop.com/writing/claude-md-vs-agents-md](https://www.alexdunlop.com/writing/claude-md-vs-agents-md)  
> 21. Claude Code Adds Support for AGENTS.md Project Instructions, [https://www.progressiverobot.com/2026/09/18/agents-md-claude-code-project-instructions/](https://www.progressiverobot.com/2026/09/18/agents-md-claude-code-project-instructions/)  
> 22. Claude Code Hooks: Rules That Always Apply \- Kevin Welter, [https://kevinwelter.com/en/blog/claude-code-hooks](https://kevinwelter.com/en/blog/claude-code-hooks)  
> 23. Claude Code settings.json, hooks, and permissions: a practical guide, [https://claudefolio.com/guides/claude-code-settings-hooks-permissions](https://claudefolio.com/guides/claude-code-settings-hooks-permissions)  
> 24. Claude Code settings.json: Copy-Paste Templates for env, model, [https://blog.vincentqiao.com/en/posts/claude-code-settings-misc/](https://blog.vincentqiao.com/en/posts/claude-code-settings-misc/)  
> 25. Settings \- claudelint, [https://claudelint.com/api/schemas/settings](https://claudelint.com/api/schemas/settings)  
> 26. The Complete Guide to CLAUDE.md — Make Claude Code Truly, [https://medium.com/@n913239/the-complete-guide-to-claude-md-make-claude-code-truly-understand-your-project-d9d026b808f1](https://medium.com/@n913239/the-complete-guide-to-claude-md-make-claude-code-truly-understand-your-project-d9d026b808f1)  
> 27. Claude Code Settings Reference (Complete Config Guide), [https://claudefa.st/blog/guide/settings-reference](https://claudefa.st/blog/guide/settings-reference)  
> 28. \[2.1.257+\] Claude Code injects "Co-Authored-By" reminders into, [https://www.reddit.com/r/ClaudeAI/comments/1w5yaxn/21257\_claude\_code\_injects\_coauthoredby\_reminders/](https://www.reddit.com/r/ClaudeAI/comments/1w5yaxn/21257_claude_code_injects_coauthoredby_reminders/)  
> 29. Custom instructions with AGENTS.md \- ChatGPT Learn, [https://learn.chatgpt.com/docs/agent-configuration/agents-md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)  
> 30. Codex and AGENTS.md: every file from root down, and a 32 KiB cutoff, [https://unwait.ai/blog/codex-agents-md](https://unwait.ai/blog/codex-agents-md)  
> 31. CLAUDE.md, AGENTS.md & Copilot Instructions: Configure Every AI, [https://www.deployhq.com/blog/ai-coding-config-files-guide](https://www.deployhq.com/blog/ai-coding-config-files-guide)  
> 32. PowerShell 5.1, Output to a text file with Out-File / Set-Content and utf8, [https://stackoverflow.com/questions/77987322/powershell-5-1-output-to-a-text-file-with-out-file-set-content-and-utf8](https://stackoverflow.com/questions/77987322/powershell-5-1-output-to-a-text-file-with-out-file-set-content-and-utf8)  
> 33. crapkit Changelog \- Safety, [https://data.safetycli.com/packages/pypi/crapkit/changelog](https://data.safetycli.com/packages/pypi/crapkit/changelog)  
> 34. Build Your Own HEARTH \- Steppe Integrations, [https://steppeintegrations.com/articles/build-your-own-hearth/](https://steppeintegrations.com/articles/build-your-own-hearth/)  
> 35. Inject Context into Claude Code with Hooks \- HookStack, [https://www.hookstack.app/guides/inject-context-claude-code-hooks](https://www.hookstack.app/guides/inject-context-claude-code-hooks)  
> 36. Hooks architecture \- Claude-Mem, [https://docs.claude-mem.ai/hooks-architecture](https://docs.claude-mem.ai/hooks-architecture)  
> 37. planning-with-files/CHANGELOG.md at master \- GitHub, [https://github.com/OthmanAdi/planning-with-files/blob/master/CHANGELOG.md](https://github.com/OthmanAdi/planning-with-files/blob/master/CHANGELOG.md)  
> 38. Write-Output with no BOM \- powershell \- Stack Overflow, [https://stackoverflow.com/questions/65191663/write-output-with-no-bom](https://stackoverflow.com/questions/65191663/write-output-with-no-bom)  
> 39. Using PowerShell to write a file in UTF-8 without the BOM, [https://stackoverflow.com/questions/5596982/using-powershell-to-write-a-file-in-utf-8-without-the-bom](https://stackoverflow.com/questions/5596982/using-powershell-to-write-a-file-in-utf-8-without-the-bom)  
> 40. Agent Markdown Files: The Complete Guide to SKILL.md \- explainx.ai, [https://explainx.ai/blog/agent-markdown-files-complete-guide-2026](https://explainx.ai/blog/agent-markdown-files-complete-guide-2026)  
> 41. Agent Skills Explained: What They Are, What They Aren't, and How, [https://dev.to/loc\_carrre\_0d798813c662/agent-skills-explained-what-they-are-what-they-arent-and-how-to-use-them-bf9](https://dev.to/loc_carrre_0d798813c662/agent-skills-explained-what-they-are-what-they-arent-and-how-to-use-them-bf9)  
> 42. Agents.md best practices \- GitHub Gist, [https://gist.github.com/0xfauzi/7c8f65572930a21efa62623557d83f6e](https://gist.github.com/0xfauzi/7c8f65572930a21efa62623557d83f6e)  
> 43. claude-codex-settings/CLAUDE.md at main \- GitHub, [https://github.com/fcakyon/claude-codex-settings/blob/main/CLAUDE.md](https://github.com/fcakyon/claude-codex-settings/blob/main/CLAUDE.md)  
> 44. Architecture decision record (ADR) \- GitHub, [https://github.com/architecture-decision-record/architecture-decision-record](https://github.com/architecture-decision-record/architecture-decision-record)  
> 45. Architecture Decision Records (ADR): Documenting Your Project's, [https://dev.to/wallacefreitas/architecture-decision-records-adr-documenting-your-projects-decisions-5ac8](https://dev.to/wallacefreitas/architecture-decision-records-adr-documenting-your-projects-decisions-5ac8)  
> 46. Agents Drafting Architecture Decision Records \- Deska, [https://deska.dev/blog/agent-writes-adr](https://deska.dev/blog/agent-writes-adr)  
> 47. Building an Architecture Decision Record Writer Agent \- Medium, [https://piethein.medium.com/building-an-architecture-decision-record-writer-agent-a74f8f739271](https://piethein.medium.com/building-an-architecture-decision-record-writer-agent-a74f8f739271)  
> 48. awesome-claude-code-and-skills/readme.md at main \- GitHub, [https://github.com/GetBindu/awesome-claude-code-and-skills/blob/main/readme.md](https://github.com/GetBindu/awesome-claude-code-and-skills/blob/main/readme.md)  
> 49. The BMAD Method Explained: Multi-Agent AI Agile \- CodeMySpec, [https://codemyspec.com/blog/bmad-method-explained](https://codemyspec.com/blog/bmad-method-explained)  
> 50. Building Effective AI Coding Agents for the Terminal \- arXiv, [https://arxiv.org/html/2603.05344v3](https://arxiv.org/html/2603.05344v3)  
> 51. Command Reference \- Rafter, [https://docs.rafter.so/guides/agent-security/reference](https://docs.rafter.so/guides/agent-security/reference)  
> 52. Comment and Control: Prompt Injection to Credential Theft in, [https://oddguan.com/blog/comment-and-control-prompt-injection-credential-theft-claude-code-gemini-cli-github-copilot/](https://oddguan.com/blog/comment-and-control-prompt-injection-credential-theft-claude-code-gemini-cli-github-copilot/)  
> 53. When the Guardrails Slip: The Case for Hook-Based Governance, [https://www.endorlabs.com/learn/when-the-guardrails-slip-the-case-for-hook-based-governance-across-agent-platforms](https://www.endorlabs.com/learn/when-the-guardrails-slip-the-case-for-hook-based-governance-across-agent-platforms)  
> 54. Blogs | Aonan Guan, [https://oddguan.com/blog/](https://oddguan.com/blog/)  
> 55. Critical Flaws in Anthropic, Google, and OpenAI's Coding Agents, [https://novee.security/blog/critical-flaws-in-anthropic-google-and-openais-coding-agents/](https://novee.security/blog/critical-flaws-in-anthropic-google-and-openais-coding-agents/)  
> 56. Claude Code Sandbox Guide: Setup, Config & Security (2026), [https://claudefa.st/blog/guide/sandboxing-guide](https://claudefa.st/blog/guide/sandboxing-guide)  
> 57. How /sandbox Works \- Claude Code Camp, [https://www.claudecodecamp.com/p/claude-code-sandboxing-how-sandbox-works-and-what-it-doesn-t-protect](https://www.claudecodecamp.com/p/claude-code-sandboxing-how-sandbox-works-and-what-it-doesn-t-protect)  
> 58. Claude 12 — Sandboxing \- Medium, [https://medium.com/@abhishekjainindore24/claude-12-sandboxing-8f281455d8d4](https://medium.com/@abhishekjainindore24/claude-12-sandboxing-8f281455d8d4)  
> 59. How to Sandbox Claude Code: Docker, VMs & Container ... \- MintMCP, [https://www.mintmcp.com/blog/sandbox-claude-code](https://www.mintmcp.com/blog/sandbox-claude-code)  
> 60. Diff \- cassandra \- Git repositories on apache, [https://apache.googlesource.com/cassandra/+/4c94ef20d3562ab8f0a922945d78464d6c475d98%5E2..4c94ef20d3562ab8f0a922945d78464d6c475d98/](https://apache.googlesource.com/cassandra/+/4c94ef20d3562ab8f0a922945d78464d6c475d98%5E2..4c94ef20d3562ab8f0a922945d78464d6c475d98/)  
> 61. about\_Execution\_Policies \- PowerShell \- Microsoft Learn, [https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about\_execution\_policies?view=powershell-7.6](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.6)  
> 62. Using AGENTS.md to Teach Codex Project Conventions \- Educative.io, [https://www.educative.io/courses/mastering-openai-codex-for-agentic-coding/agents-md-teaching-codex-your-codebase](https://www.educative.io/courses/mastering-openai-codex-for-agentic-coding/agents-md-teaching-codex-your-codebase)  
> 63. Permission Fatigue Is a Security Risk — Improve It in Claude Code, [https://spin.atomicobject.com/permission-fatigue-claude-code/](https://spin.atomicobject.com/permission-fatigue-claude-code/)  
> 64. How do you handle overlapping Codex skills in larger skill catalogs?, [https://community.openai.com/t/how-do-you-handle-overlapping-codex-skills-in-larger-skill-catalogs/1383626](https://community.openai.com/t/how-do-you-handle-overlapping-codex-skills-in-larger-skill-catalogs/1383626)