# {{PROJE_ADI}}: plan

Son güncelleme: {{TARIH}}

## Amaç

{{AMAC}}

## Kapsam ve yapılmayacaklar

{{KAPSAM}}

## Aşamalar

| # | Aşama | Durum | Etiket |
|---|---|---|---|
| 1 | {{ILK_ASAMA}} | Sürüyor | – |

Biten aşama tek satıra indirilir; ayrıntısı `GUNLUK.md` ve `KARARLAR.md`'dedir.
Etiket: aşama bitince atılan Git etiketi (`asama-1`); biten aşamanın kodu donmuştur.
Plan modunda hazırlanan plan araç klasöründe kalır ve diğer araç göremez; onaylanınca
aşamalar buraya, ilgili aşamanın adımları aşağıdaki tabloya yazılır.

## Şu anki aşamanın adımları

| Adım | İş | Durum | Test | Commit |
|---|---|---|---|---|
| 1.1 | {{ILK_ADIM}} | Bekliyor | – | – |

Durum: Bekliyor · Sürüyor · Bitti · Bloke. Test sütununa adımı kanıtlayan test
dosyası yazılır (kodsuz adımda `–`). Adım bitince Commit sütununa kısa hash yazılır.

## Açık kararlar

Biçim: `- [ ] konu: seçenekler, tarih`. Karar verilince buradan silinir ve
`KARARLAR.md`'ye yazılır.

## Bilinen sınırlar ve bakım

Canlıda ya da testte görülen sınırlar ve bakım işleri. Şimdilik yok.

## Yaklaşan takvim

Tarihli işler. Şimdilik yok.

---

Geçmiş: `GUNLUK.md`. Kararların gerekçeleri: `KARARLAR.md`.
