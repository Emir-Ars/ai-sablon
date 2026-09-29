# {{PROJE_ADI}}: çalışma talimatları (Claude Code ve Codex için ortak)

Kişisel çalışma kuralları genel dosyalardadır (`~/.claude/CLAUDE.md`,
`~/.codex/AGENTS.md`); burada tekrarlanmaz. Bu dosya yalnız bu projeye özeldir.
Daha özel olduğu için çelişkide bu dosyanın kuralı geçerlidir; çelişkiyi
kullanıcıya söyle. Kalıcı bilgi araçların hafızasında değil, aşağıdaki
dosyalarda durur.

## Belge haritası

Skill'ler ve `.ai/durum.ps1` dosya adlarını bu tablodan okur; adı değiştirirsen
tabloyu da güncelle.

| Rol | Dosya | Git | Kullanım |
|---|---|---|---|
| Kurallar | `AGENTS.md` | Git | Bu dosya; projeye özel kalıcı kurallar. |
| Plan | `PLAN.md` | Git | Amaç, aşamalar, şu anki adımlar, açık kararlar, bilinen sınırlar. Kısa tutulur. |
| Kararlar | `KARARLAR.md` | Git | Kararların gerekçeli kaydı; yalnız eklenir. |
| Günlük | `GUNLUK.md` | Git | Oturum kayıtları; en yeni sonda. |
| Devir notu | `DEVAM.md` | Git dışı | "Şu an" durumu; her seferinde baştan yazılır. |
| Teknik belge | `docs/teknik.md` | Git | Kodun işleyişi. Yoksa kendiliğinden oluşturma; gerekirse kullanıcıya sor. |
| Durum betiği | `.ai/durum.ps1` | Git | Oturum başı durum ve devir notu denetimi (salt okunur). |

## Proje özeti

{{AMAC}}

## Oturum başında

Claude Code bu dosyayı, `PLAN.md` ve `DEVAM.md`'yi yerel `CLAUDE.md` üzerinden
kendiliğinden yükler. Codex `@` ile içe aktarma yapmaz: `PLAN.md` ve `DEVAM.md`'yi
kendin oku. Sonra `git status` ve `git log --oneline -5`. `/basla` (Codex'te
`$basla`) bu adımları yapar. Oturum başı durum çıktısında `UYARI` satırı varsa
ilk cevabında kullanıcıya söyle.

## Kod ve kontrol

- Testler: `{{TEST_KOMUTU}}`
- Biçim denetimi: `{{BICIM_KOMUTU}}`

## Projeye özel kısıtlar ve canlı işler

{{KISITLAR}}

## Git (projeye özel)

Genel Git kuralları geçerlidir. Bu projede ek olarak:

- `DEVAM.md`, `CLAUDE.md`, `CLAUDE.local.md` ve `.claude/settings.local.json`
  commit edilmez (`.gitignore`'dadır).

<!-- EKLER -->

<!-- ai-sablon: {{SABLON_SURUM}} {{TARIH}} -->
