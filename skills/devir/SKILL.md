---
name: devir
description: "Oturumu kapatmadan ya da araç değiştirmeden önce devir notunu baştan yazar ve günlüğe kısa kayıt ekler. 'devir', 'devir notunu güncelle', 'oturumu bitir', 'araç değiştireceğim', 'limit doluyor' denince kullan. Kısayol: /devir ($devir). Commit yapmaz."
metadata:
  kaynak: "ai-sablon"
  surum: "__SABLON_SURUM__"
---

# devir: oturum sonu ya da araç geçişi

Kullanıcının komutla yazdığı metin (Claude'da `ARGUMENTS:` satırı, Codex'te `$devir`
sonrası yazı) boş olabilir; varsa devir notuna eklenecek bir uyarıdır.

## Adımlar

1. **Belge haritasını bul.** Projenin `AGENTS.md`'sindeki "Belge haritası" tablosundan
   Plan, Kararlar, Günlük ve Devir notu dosyalarının adlarını oku. Harita yoksa
   `AGENTS.md`'de adı geçen dosyaları kullan (Staj gibi eski düzende `proje_plani.md`
   ve `DEVAM.md`). Eski düzenli projede **yeni dosya oluşturma**.
2. **Durumu topla.** `git --no-optional-locks status --porcelain`,
   `git --no-optional-locks log --oneline -5`, `git --no-optional-locks diff --stat`.
3. **Kaydedilmemişleri işle.** Bu oturumda verilen ama Kararlar ve Plan'a yazılmamış
   karar var mı? Bitmiş ama Plan'a işlenmemiş adım var mı? Varsa devir notundan önce
   ilgili belgeye yaz (karar için `karar` skill'inin adımlarını izle). Emin değilsen
   kullanıcıya sor, tahmin etme.
4. **Saati al.** `Get-Date -Format 'yyyy-MM-dd HH:mm'`. Saati kendin tahmin etme.
5. **Devir notunu baştan yaz** (yama yapma). Başlıklar:
   - Projenin `AGENTS.md`'si Devir notu için kendi başlıklarını tanımlıyorsa (Staj'da
     olduğu gibi) onları kullan; not zaten başka bir tarih biçimi kullanıyorsa o
     biçimi koru.
   - Tanımlamıyorsa şu iskeleti kullan: `Son güncelleme: yyyy-MM-dd HH:mm · Yazan:
     <Claude Code ya da Codex>`, `Son commit: <hash> · Dal · Push`, sonra başlıklar:
     Şu an, Commit edilmemiş değişiklikler, Bekleyen kararlar, Sıradaki iş,
     Kullanıcının çalıştıracakları (komut, çıktıda neye bakılır), Riskler.
   - Kullanıcının komutla yazdığı metin varsa "Riskler" altına ekle.
   - Emin olmadığın bilgiyi "doğrulanmadı" diye işaretle.
6. **60 satır sınırı.** Yeni not 60 satırı aşarsa: biten işi Günlük'e, kararı
   Kararlar'a, kalıcı bilgiyi Plan'a taşıyarak kısalt. Haritada bu belgeler yoksa
   (eski düzen) kısaltma; "devir notu N satır, sınırı aşıyor" diye söyle ve ne
   yapılacağını sor.
7. **Günlük.** Haritada Günlük varsa sonuna 3-5 satırlık kayıt ekle (Günlük'ün kendi
   kayıt biçimini kullan; saat adım 4'ten; araç adı olarak model adını değil "Claude
   Code" ya da "Codex" yaz). Haritada Günlük yoksa bu
   adımı atla.
8. **Rapor ver.** Hangi belgeler güncellendi, Devir notunun yeni "Son güncelleme"
   saati, commit edilmemiş dosyaların listesi. Kullanıcıya şunu söyle: yeni araçta
   yeni sohbet aç ve `/basla` (Codex'te `$basla`) yaz.

## Bitti ölçütü

- Devir notu baştan yazıldı, "Son güncelleme" saati adım 4'ten.
- Not 60 satırı aşmıyor ya da aşıyorsa kullanıcıya söylendi.
- Günlük'e kayıt eklendi (haritada varsa).
- Güncellenen belgeler raporda listelendi.

## Yapma

- Commit ya da push yapma; `git add` çalıştırma. Commit gerekiyorsa kullanıcıya
  söyle.
- Devir notunu yamalama; baştan yaz.
- Saati ya da bilgiyi tahminle yazma.
- Eski düzenli projede yeni dosya oluşturma; Günlük yoksa atla.
- Kararlar ya da Plan'ı devir notu bahanesiyle yeniden yazma.
