---
name: basla
description: "Oturum başında projenin durumunu okuyup kısa özet verir: Git durumu, devir notu güncelliği, şu anki adım, bekleyen kararlar. 'başla', 'oturuma başla', 'devam edelim', 'nerede kalmıştık', 'devir notu yazılamadı' denince kullan. Kısayol: /basla ($basla)."
metadata:
  kaynak: "ai-sablon"
  surum: "__SABLON_SURUM__"
---

# basla: oturum başı

Kullanıcının komutla yazdığı metin (Claude'da `ARGUMENTS:` satırı, Codex'te `$basla`
sonrası yazı) boş olabilir. "devir notu yazılamadı" ya da "yalnız özetle" gibi
ifadeler burada gelir.

## Adımlar

1. **Belge haritasını bul.** Projenin `AGENTS.md`'sindeki "Belge haritası" tablosunu
   oku (Rol, Dosya, Git, Kullanım). Harita yoksa `AGENTS.md`'de adı geçen dosyaları
   kullan (eski düzende `proje_plani.md` ve `DEVAM.md` gibi). Eski düzenli projede
   **yeni dosya oluşturma**.
2. **Durumu al.** Sırayla dene, ilk çalışanı kullan:
   - Bağlamda oturum başı kanca çıktısı varsa (`[ai-sablon durum]` ile başlar) onu
     kullan.
   - Proje `.ai/durum.ps1` içeriyorsa şu komutu **aynen** çalıştır (izin listesi bu
     metne göre yazıldı):
     `powershell -NoProfile -ExecutionPolicy Bypass -File .ai/durum.ps1`
   - Yoksa:
     `powershell -NoProfile -ExecutionPolicy Bypass -File "__SABLON_KOKU__\scripts\durum.ps1" -Proje .`
   - O da çalışmazsa: `git --no-optional-locks status --short --branch` ve
     `git --no-optional-locks log --oneline -5`.
3. **Oku.** Plan'ın şu anki aşama ve adım, açık kararlar, varsa açık yüksek riskli
   varsayımlar ve son "Sürprizler" bölümlerini, sonra Devir
   notunu. Claude Code'da Plan ve Devir notu `CLAUDE.md` ile zaten bağlamdadır;
   yeniden okuma. Plan çok uzunsa (300 satırdan fazla) tamamını okuma: başlıklara
   `Select-String -Pattern '^#'` ile bak, yalnız gereken bölümü oku. Kararlar ve Günlük
   okunmaz. Devir notu eskiyse (durum çıktısında U3, U4 ya da U6 var ya da "gün önce
   yazılmış" bilgisi var) Günlük'ün son 2 kaydını oku.
4. **Kurtarma modu.** Kullanıcının metni önceki oturumda devir notunun yazılamadığını
   söylüyorsa ya da durum çıktısında U3 veya U4 varsa: `git --no-optional-locks diff
   --stat`, sınırlı diff (her dosya için ilk ~80 satır, toplam ~300 satırı geçme) ve
   devir tarihinden sonraki `git --no-optional-locks log --since="<devir tarihi>"
   --oneline` ile neyin yapıldığını çıkar. Sonra Devir notunu baştan yaz: saat
   `Get-Date -Format 'yyyy-MM-dd HH:mm'` ile alınır, notun başına "kurtarma: koddan
   çıkarıldı" yaz, emin olmadığın yeri "doğrulanmadı" diye işaretle. Kullanıcı "yalnız
   özetle" dediyse hiçbir dosya değiştirme, yalnız özetle.
5. **Özet ver.** En çok 15 satır, Türkçe:
   - Durum çıktısında `UYARI` varsa **ilk satırda** söyle.
   - Dal ve son commit.
   - Devir notunun tarihi ve güncel olup olmadığı.
   - Şu anki aşama ve adım.
   - Commit edilmemiş değişiklikler.
   - Bekleyen kararlar, sıradaki iş, kullanıcının çalıştıracakları.
   - Sonuna "Onayını bekliyorum." yaz ve dur. Kullanıcı söylemeden işe başlama.

## Bitti ölçütü

- Özet verildi, uyarılar ilk satırda söylendi, kullanıcı onayı bekleniyor.
- Kurtarma modunda: Devir notu güncellendi (kullanıcı "yalnız özetle" dediyse hiçbir
  dosya değişmedi).

## Yapma

- Commit ya da push yapma; `git add` çalıştırma.
- Kurtarma modu dışında hiçbir dosyayı değiştirme.
- Kararlar ve Günlük'ü baştan sona okuma.
- Eski düzenli projede yeni dosya oluşturma.
- Durum çıktısı yoksa uydurma; "durum alınamadı" de.
