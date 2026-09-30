---
name: yeni-proje
description: "Yeni ya da boş bir klasörde ai-sablon çalışma düzenini kurar: proje adını ve ilk fikri sorar, belgeleri kopyalar, araştırma klasörünü açar. Yalnız kullanıcı elle çağırınca çalışır: /yeni-proje ($yeni-proje). Şablon deposunda, ev klasöründe, Masaüstü kökünde ve Staj'da çalıştırma."
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
4. **Soruları sor.** `references/sorular.md` dosyasını oku ve yalnız oradaki iki soruyu
   (proje adı, ilk fikir) **tek mesajda** sor. Ek, test komutu, kısıtlar ve ilk adım
   sorulmaz: proje araştırmadan önce kurulur, bunlar planlamada belirlenir.
5. **Özet göster ve onay al.** Oluşacak dosya listesini (yeni ve atlanacak dosyalar)
   göster. Onay gelmeden kopyalama.
6. **Kopyala.**
   `powershell -NoProfile -ExecutionPolicy Bypass -File "__SABLON_KOKU__\scripts\yeni-proje.ps1" -Hedef . -ProjeAdi "<ad>" -Arac <Claude ya da Codex>`
   Betik dosyaları kopyalar, `.sablon`, `_claude` ve `_githooks` adlarını dönüştürür,
   `{{PROJE_ADI}}`, `{{TARIH}}`, `{{TARIH_SAAT}}`, `{{SABLON_SURUM}}` ve
   `{{SABLON_KOKU}}` alanlarını doldurur, boş `docs\arastirma\genel\` klasörünü açar;
   var olan hiçbir dosyanın üzerine yazmaz. Raporu kullanıcıya göster.
7. **Alanları doldur.** Kalan `{{AMAC}}` alanını ilk fikirle doldur (kullanıcının
   sözleriyle; genişletme). Sonra:
   - `KARARLAR.md`'ye K-001 "Çalışma düzeni: ai-sablon" kaydı.
   - `GUNLUK.md`'ye ilk kayıt (kurulum). Saat: `Get-Date -Format 'yyyy-MM-dd HH:mm'`;
     araç adı "Claude Code" ya da "Codex" (model adı değil).
8. **Doğrula.** Hedef klasörde:
   - Ağaç doğru mu: `AGENTS.md`, `CLAUDE.md`, `PLAN.md`, `KARARLAR.md`, `GUNLUK.md`,
     `DEVAM.md`, `.gitignore`, `.gitattributes`, `.claude\settings.json`,
     `.ai\durum.ps1`, `.githooks\commit-msg` ve `docs\arastirma\genel\` klasörü.
   - Kalan yer tutucu yok mu: `Select-String -Path (Get-ChildItem -Recurse -File -Force
     -Exclude *.ps1 | ForEach-Object FullName) -Pattern '\{\{'` boş dönmeli.
   - `.claude\settings.json` `ConvertFrom-Json` ile ayrışıyor mu.
   - `.ai\durum.ps1` ilk 3 bayt `239 187 191` mi (BOM).
   - `.gitignore` içinde `DEVAM.md` ve `CLAUDE.md` var mı.
   - `powershell -NoProfile -ExecutionPolicy Bypass -File .ai/durum.ps1` uyarısız
     çalışıyor mu.
9. **Bitir.** Sonuçları söyle ve dur. Git'e dokunma: `git init`, commit ve push'u
   kullanıcı kendisi yönetir. Kullanıcıya şunları söyle:
   - Git'i kurunca bir kez `git config core.hooksPath .githooks` çalıştırsın (commit
     mesajında yapay zekâ imzası varsa kanca commit'i reddeder).
   - Araştırma sonuçlarını `docs\arastirma\genel\` klasörüne koysun (tam yolu ver).
   - Sonra yeni oturum açsın, güven penceresini kabul etsin ve plan modunda
     "araştırmaya göre projenin planını çıkar" desin (Codex'te önce `$basla`). Plan,
     ana başlıklar ve ek seçimi projenin `AGENTS.md`'sindeki "Planlama ve araştırma"
     kuralına göre yapılır.

## Bitti ölçütü

- Adım 8'deki bütün denetimler geçti ya da geçmeyenler raporlandı.
- Kullanıcıya "yeni oturum aç" yönergesi verildi.

## Yapma

- Var olan dosyanın üzerine yazma; `.claude/settings.json` varsa dokunma.
- Onaysız kopyalama yapma.
- Git'e dokunma: `git init`, `git add`, commit, push ve Git kimliği ayarı yok.
- Şablon deposunda, ev klasöründe, Masaüstü kökünde ya da Staj'da çalışma.
- `.venv` oluşturma, paket kurma; ek kurma (ek planlamada önerilir).
- Plan, amaç ya da kapsam uydurma; kurulumda yalnız ilk fikir yazılır.
