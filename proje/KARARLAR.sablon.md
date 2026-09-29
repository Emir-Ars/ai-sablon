# {{PROJE_ADI}}: kararlar

Yalnız eklenir. Eski bir kayıtta yalnız `Durum` satırı değişir (yerine geçen karar
yazıldığında). Yeni numara: son `K-NNN` + 1. Gerekçe kullanıcının söylediğidir;
söylemediyse uydurulmaz, sorulur.

Kayıt biçimi:

```
## K-NNN · yyyy-MM-dd · Başlık
- Durum: geçerli   (geçerli | yerine geçildi → K-NNN)
- Karar: …
- Gerekçe: … (kullanıcının söylediği)
- Seçenekler: A (seçildi); B (neden değil)
- Etki: PLAN adımı, dosyalar
- Kaynak: kullanıcı, tarih, araç
```

---
