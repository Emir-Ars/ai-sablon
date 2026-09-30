# {{PROJE_ADI}}: plan

Son güncelleme: {{TARIH}}

## Amaç

İlk fikir (araştırmadan önce): {{AMAC}}

Kesin amaç planlamadan sonra buraya yazılır.

## Kapsam ve yapılmayacaklar

Araştırma ve planlamadan sonra yazılır.

## Aşamalar

| # | Aşama | Durum | Etiket |
|---|---|---|---|
| 0 | Araştırma ve plan | Sürüyor | – |

Biten aşama tek satıra indirilir; ayrıntısı `GUNLUK.md` ve `KARARLAR.md`'dedir.
Etiket: aşama bitince atılan Git etiketi (`asama-1`); biten aşamanın dışa açık arayüzü
ve testleri donmuştur. Plan modunda hazırlanan plan araç klasöründe kalır ve diğer araç
göremez; onaylanınca ana başlıklar buraya, üzerinde çalışılan başlığın adımları aşağıdaki
tabloya yazılır.

## Şu anki aşamanın adımları

| Adım | İş | Durum | Test | Commit |
|---|---|---|---|---|
| 0.1 | Araştırma sonuçlarını `docs/arastirma/genel/` klasörüne koy | Bekliyor | – | – |
| 0.2 | Plan modunda araştırmaya göre projenin planını çıkar ve onayla | Bekliyor | – | – |

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
