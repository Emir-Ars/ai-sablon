---
name: yeni-proje
description: "Yeni ya da boş bir klasörde ai-sablon çalışma düzenini kurar: soru sorar, belgeleri kopyalar ve doldurur. Yalnız kullanıcı elle çağırınca çalışır: /yeni-proje ($yeni-proje). Şablon deposunda, ev klasöründe, Masaüstü kökünde ve Staj'da çalıştırma."
metadata:
  kaynak: "ai-sablon"
  surum: "__SABLON_SURUM__"
  yalniz-elle: "evet"
---

# yeni-proje: projeye çalışma düzeni kur

Kullanıcının komutla yazdığı metin (Claude'da `ARGUMENTS:` satırı, Codex'te
`$yeni-proje` sonrası yazı) proje adı ya da kısa bir not olabilir; boş olabilir.
Bu skill yalnız elle çağrılır. Çalışma klasörü hedef projedir.

## Adımlar

1. **Şablon kökünü doğrula.** `Test-Path "__SABLON_KOKU__\proje\AGENTS.sablon.md"`.
   `False` ise kullanıcıdan şablon deposunun yolunu iste ve dur.
2. **Hedefi onaylat.** Hedef klasör olarak geçerli klasörü göster ve kullanıcıya
   onaylat. Şunlar **reddedilir**: şablon deposunun kendisi (`__SABLON_KOKU__`), ev
   klasörü, Masaüstü kökü, `C:\Users\Emir\Desktop\Staj`. Reddedersen nedenini söyle ve dur.
3. **Envanter al.**
   `powershell -NoProfile -ExecutionPolicy Bypass -File "__SABLON_KOKU__\scripts\yeni-proje.ps1" -Hedef . -Kontrol`
   Çıktı her hedef dosya için YENİ ya da VAR yazar ve `AGENTS.md` içinde ai-sablon
   işareti olup olmadığını söyler. İşareti olmayan bir `AGENTS.md` varsa **mevcut
   projeye ekleme modu**: yalnız eksik dosyalar eklenir, var olan hiçbir dosyanın
   üzerine yazılmaz; `AGENTS.md`'ye Belge haritası ya da ek bölümü eklemeden önce
   kullanıcıdan onay al.
4. **Soruları sor.** `references/sorular.md` dosyasını oku ve soruları **tek mesajda,
   numaralı** sor (klasör adı, amaç, ekler, komutlar, kısıtlar, ilk adım).
   Ek listesini `__SABLON_KOKU__\ekler` altındaki klasörlerden çıkar; seçilen ekin
   `EK.md` dosyasındaki ek soruları da ekle.
5. **Özet göster ve onay al.** Cevaplardan çıkan dosya listesini (yeni ve atlanacak
   dosyalar) ve doldurulacak alanları göster. Boş cevap "henüz belirlenmedi" olur ve
   Plan'ın "Açık kararlar" bölümüne eklenir. Onay gelmeden kopyalama.
6. **Kopyala.**
   `powershell -NoProfile -ExecutionPolicy Bypass -File "__SABLON_KOKU__\scripts\yeni-proje.ps1" -Hedef . -Ekler <ek adları, virgülle> -ProjeAdi "<ad>" -Arac <Claude ya da Codex>`
   Betik dosyaları kopyalar, `.sablon` ve `_claude` adlarını dönüştürür,
   `{{PROJE_ADI}}`, `{{TARIH}}`, `{{TARIH_SAAT}}` ve `{{SABLON_SURUM}}` alanlarını
   doldurur; var olan hiçbir dosyanın üzerine yazmaz; `.gitignore` satırlarını
   tekrarsız ekler; `.claude/settings.json` varsa atlar ve raporlar. Raporu kullanıcıya
   göster.
7. **Alanları doldur.** Kalan `{{…}}` alanlarını cevaplara göre kendin doldur
   (`references/sorular.md` hangi alanın hangi dosyada olduğunu söyler). Sonra:
   - `KARARLAR.md`'ye K-001 "Çalışma düzeni: ai-sablon" kaydı.
   - `GUNLUK.md`'ye ilk kayıt (kurulum). Saat: `Get-Date -Format 'yyyy-MM-dd HH:mm'`;
     araç adı "Claude Code" ya da "Codex" (model adı değil).
8. **Doğrula.** Hedef klasörde:
   - Ağaç doğru mu: `AGENTS.md`, `CLAUDE.md`, `PLAN.md`, `KARARLAR.md`, `GUNLUK.md`,
     `DEVAM.md`, `.gitignore`, `.claude\settings.json`, `.ai\durum.ps1`.
   - Kalan yer tutucu yok mu: `Select-String -Path (Get-ChildItem -Recurse -File -Force
     -Exclude *.ps1 | ForEach-Object FullName) -Pattern '\{\{'` boş dönmeli.
   - `.claude\settings.json` `ConvertFrom-Json` ile ayrışıyor mu.
   - `.ai\durum.ps1` ilk 3 bayt `239 187 191` mi (BOM).
   - `.gitignore` içinde `DEVAM.md` ve `CLAUDE.md` var mı.
   - `powershell -NoProfile -ExecutionPolicy Bypass -File .ai/durum.ps1` uyarısız
     çalışıyor mu.
9. **Bitir.** Sonuçları söyle ve dur. Git'e dokunma: `git init`, commit ve push'u
   kullanıcı kendisi yönetir. Kullanıcıya söyle: yeni oturum aç, güven penceresini
   kabul et; Codex'te `$basla`.

## Bitti ölçütü

- Adım 8'deki bütün denetimler geçti ya da geçmeyenler raporlandı.
- Kullanıcıya "yeni oturum aç" yönergesi verildi.

## Yapma

- Var olan dosyanın üzerine yazma; `.claude/settings.json` varsa dokunma.
- Onaysız kopyalama yapma.
- Git'e dokunma: `git init`, `git add`, commit, push ve Git kimliği ayarı yok.
- Şablon deposunda, ev klasöründe, Masaüstü kökünde ya da Staj'da çalışma.
- `.venv` oluşturma, paket kurma (ek bunu komut olarak önerir).
- Cevabı olmayan alanı uydurma; "henüz belirlenmedi" yaz ve Plan'a açık karar ekle.
