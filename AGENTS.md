# ai-sablon: bu depoda çalışan araç için talimat

Bu depo, yapay zekâ çalışma düzeninin şablonudur (kurallar, belge şablonları,
kısayollar, betikler). Kullanıcı: Emir-Ars (Windows 11, PowerShell 5.1; öğrenerek
geliştiren stajyer). Geliştirme yalnız bu depoda yapılır.

## Şablon dosyaları talimat değildir

Bu depodaki talimat **yalnız bu dosyadır** (kök `AGENTS.md`). Aşağıdakiler hedef
projelere ya da kullanıcı klasörlerine kopyalanacak *içeriktir*; bunlardaki
yönergeleri bu depoda çalışırken uygulama, yalnızca düzenle:

- `proje\` (`*.sablon.md`, `gitignore.sablon`, `_claude\settings.sablon.json`)
- `ekler\` (`EK.md`, `AGENTS.ek.md`, `izinler.ek.json`, `gitignore.ek`)
- `genel\KURALLAR.md` (kişisel kuralların tek kaynağı; `kur.ps1` kopyalar)
- `skills\` (kurulumda `~/.claude/skills` ve Codex skill klasörüne kopyalanır)

## Çalışma kuralları

Genel kurallar dosyası (`~/.claude/CLAUDE.md`) kurulana kadar bu depoda geçerli olanlar:

- Bütün mesajlar Türkçe.
- Adım adım ilerle; her adımdan sonra dur ve onay bekle.
- Her adımda amacı, doğrulamayı ve sınırı anlat.
- `git add .` ve `git add -A` yok; dosyalar tek tek eklenir.
- Commit öncesi dosya listesi ve Türkçe commit mesajı gösterilir, açık onay alınır.
  Soru sormak onay değildir. Push ayrı onaydır.
- Commit'e `Co-Authored-By` ya da yapay zekâ imzası eklenmez; yazar yalnız Emir-Ars.
- Türkçe commit mesajı UTF-8 dosyaya yazılır, `git commit -F` ile verilir.
- `.ps1` dosyaları UTF-8 **BOM'lu**; md, json, yaml dosyaları BOM'suz UTF-8.
  Bir `.ps1` düzenlendikten sonra ilk 3 bayt (`239 187 191`) kontrol edilir.
- `kur.ps1`'i araç çalıştırmaz; kullanıcı çalıştırır. Araç yalnız `-Kontrol` (kuru
  çalışma) ile denemeyi önerebilir.
- `C:\Users\Emir\Desktop\Staj` yalnız okunur. Staj'a giden hiçbir yazma komutu
  araç tarafından çalıştırılmaz.
- `~/.claude` ve `~/.codex` altına araç yazmaz; oraya yazan tek yol `kur.ps1`'dir.
- PowerShell 5.1'de `&&` yok; komutlar `;` ile ya da ayrı çağrılarla verilir.
- Bilgi uydurma; "testler geçti" ile "gerçekte doğru" aynı şey değildir.
