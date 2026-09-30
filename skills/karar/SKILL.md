---
name: karar
description: "Kullanıcının verdiği kararı gerekçesiyle Kararlar belgesine yazar; Plan'daki açık kararı ve devir notundaki bekleyeni düzeltir. 'karar', 'karar verdim', 'şunu seçtik', 'bundan sonra şöyle yapacağız' denince kullan. Kısayol: /karar metin ($karar). Commit yapmaz."
metadata:
  kaynak: "ai-sablon"
  surum: "__SABLON_SURUM__"
---

# karar: kararı kayda geçir

Kullanıcının komutla yazdığı metin (Claude'da `ARGUMENTS:` satırı, Codex'te `$karar`
sonrası yazı) kararın kendisidir.

## Adımlar

1. **Belge haritasını bul.** Projenin `AGENTS.md`'sindeki "Belge haritası" tablosundan
   Kararlar, Plan ve Devir notu dosyalarını oku. Harita yoksa `AGENTS.md`'de adı geçen
   dosyaları kullan (eski düzen). Eski düzenli projede **yeni dosya oluşturma**.
2. **Metni al.** Metin boşsa "Hangi kararı kaydedeyim?" diye sor ve dur. Gerekçe
   (neden) yoksa bir kez sor; söylemezse "Gerekçe: belirtilmedi" yaz. Gerekçeyi ya da
   seçenekleri uydurma.
3. **Eski karar ara.** Kararlar ve Plan dosyalarında konunun anahtar sözcüklerini ara:
   `Select-String -Path <dosya> -Pattern '<sözcük>' -Encoding UTF8`. Çelişen ya da
   yerine geçilen bir karar varsa kullanıcıya söyle: hangi kayıt (K-NNN) ve nasıl.
4. **Yaz ve göster.**
   - Kullanıcının söylediği açıksa doğrudan yaz ve yazdığını göster.
   - Sözünden çıkarım yapman gerekiyorsa (seçenekler, etki gibi) önce taslağı göster
     ve onay al.
   - Numara: Kararlar dosyasındaki en büyük `## K-(\d+)` sayısı + 1, hiç yoksa K-001:
     `(Select-String -Path <Kararlar> -Pattern '^## K-(\d+)' -Encoding UTF8 |
     ForEach-Object { [int]$_.Matches[0].Groups[1].Value } |
     Measure-Object -Maximum).Maximum`
   - Tarih kabuktan: `Get-Date -Format 'yyyy-MM-dd'`.
   - Kayıt biçimi Kararlar dosyasının başında yazılıdır (Durum, Karar, Gerekçe,
     Seçenekler, Etki, Kaynak). Kaynak satırına kullanıcı, tarih ve araç adını ("Claude Code" ya da "Codex",
     model adı değil) yaz.
   - Yeni karar eskisinin yerine geçiyorsa eski kaydın **yalnız** `Durum` satırını
     `yerine geçildi → K-NNN` yap; başka satırına dokunma.
5. **Diğer belgeleri düzelt.**
   - Plan'da bu kararla kapanan açık karar satırını (`- [ ] …`) sil; kararın etkilediği
     adım ya da aşama satırını güncelle.
   - Devir notunda "Bekleyen kararlar" kısmını düzelt.
   - Güncellenen her belgeyi mesajda bir cümleyle söyle.
6. **Eski düzenli proje.** Haritada Kararlar dosyası yoksa (Staj'da `proje_plani.md`
   Bölüm 8 gibi) projenin kendi karar tablosuna ya da bölümüne, onun biçimiyle yaz.
   `KARARLAR.md` oluşturma.

## Bitti ölçütü

- Kayıt yazıldı ve gösterildi (çıkarım varsa taslak onay bekliyor).
- Numara doğru; yerine geçilen kaydın yalnız `Durum`'u değişti.
- Plan ve Devir notu tutarlı; güncellenen belgeler söylendi.

## Yapma

- Commit ya da push yapma; `git add` çalıştırma.
- Eski kaydın `Durum` dışındaki satırlarını değiştirme.
- Gerekçe, seçenek ya da etki uydurma.
- Kullanıcı söylemediği bir kararı kaydetme.
- Eski düzenli projede yeni dosya oluşturma.
