# {{PROJE_ADI}}: günlük

Biten adım ve kararların kaydı; en yeni sonda. Yalnız eklenir, eski kayıt düzeltilmez.
Kayıt adım bitince, commit önerisiyle birlikte yazılır.

Kayıt biçimi (köşeli parantezli satırlar yalnız gerekiyorsa yazılır):

```
## yyyy-MM-dd HH:mm · <Claude Code ya da Codex> · Aşama/Adım
- Yapılan: …
- [Sorun → çözüm: belirti (hata mesajı birebir) → sebep → çözüm]
- [Vazgeçilen: denenen yol → neden bırakıldı]
- Karar: K-NNN ya da yok
- Sonraki: …
```

Commit hash'i yazılmaz: kayıt adımın commit'iyle birlikte girer (`git log -- GUNLUK.md`).
Benzer bir hatada önce bu dosyada hata mesajı aranır.

---
