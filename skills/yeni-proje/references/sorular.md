# yeni-proje soruları

Kurulumda yalnız iki soru sorulur; proje araştırmadan önce kurulur. Amaç, kapsam,
kısıtlar, teknoloji ve ek seçimi araştırma sonrası planlamada belirlenir (projenin
`AGENTS.md`'sindeki "Planlama ve araştırma" bölümü).

Soruları tek mesajda, numaralı sor. Köşeli parantez varsayılan cevaptır.

| # | Soru | Varsayılan | Doldurduğu alan (dosya) |
|---|---|---|---|
| 1 | Proje adı? | [klasör adı] | `{{PROJE_ADI}}` (betik doldurur; `-ProjeAdi`) |
| 2 | Kafandaki ilk fikir ne? (1-3 cümle; araştırmaya başlarken yazdığın düşünce) | – | `{{AMAC}}` (`AGENTS.md` Proje özeti, `PLAN.md` Amaç) |

## Kurallar

- Başka soru sorma: ek, test komutu, kısıtlar ve ilk adım planlamada belirlenir.
- Soru 2 boşsa `{{AMAC}}` yerine "henüz yazılmadı" yaz.
- İlk fikri kullanıcının sözleriyle yaz; genişletme, yorum ekleme.
- Cevaplarda gizli bilgi (şifre, anahtar) çıkarsa dosyaya yazma; kullanıcıya uyar.
