# {{PROJE_ADI}}: plan

Son güncelleme: {{TARIH}}

## Amaç

İlk fikir (araştırmadan önce): {{AMAC}}

Kesin amaç planlamadan sonra buraya yazılır.

## Kapsam ve yapılmayacaklar

Araştırma ve planlamadan sonra yazılır.

## Başarı ölçütleri

Proje ne zaman başarılı sayılır; 3-5 ölçülebilir madde, her biri doğrulanabilir.
Planlamada yazılır.

| # | Ölçüt | Nasıl doğrulanır (komut / test) | Kaynak |
|---|---|---|---|

## Aşamalar

| # | Aşama | Bitti = | Durum | Etiket |
|---|---|---|---|---|
| 0 | Araştırma ve plan | Plan onaylandı, `PLAN.md`'ye yazıldı | Sürüyor | – |

Biten aşama tek satıra indirilir; ayrıntısı `GUNLUK.md` ve `KARARLAR.md`'dedir.
Etiket: aşama bitince atılan Git etiketi (`asama-1`); biten aşamanın dışa açık arayüzü
ve testleri donmuştur. Plan modunda hazırlanan plan araç klasöründe kalır ve diğer araç
göremez; onaylanınca ana başlıklar buraya, üzerinde çalışılan başlığın adımları aşağıdaki
tabloya yazılır.

## Şu anki aşamanın adımları

| Adım | İş | Durum | Test | Commit |
|---|---|---|---|---|
| 0.1 | Araştırma sonuçlarını `docs/arastirma/genel/` klasörüne koy | Bekliyor | – | – |
| 0.2 | Plan modunda anlama özeti: gereksinimler, başarı ölçütleri, çelişkiler, sorular | Bekliyor | – | – |
| 0.3 | Plan taslağı, kararlar ve varsayımlar; onay ve dosyalara yazma | Bekliyor | – | – |

Durum: Bekliyor · Sürüyor · Bitti · Bloke. Test sütununa adımı kanıtlayan test
dosyası yazılır (kodsuz adımda `–`). Adım bitince Commit sütununa kısa hash yazılır.

## Varsayımlar ve riskler

Her ana başlığın başında gözden geçirilir. Kaynak: `[B]` belge, `[Ö]` öneri, `[V]` varsayım.
Risk: Y (yüksek) / O / D. Durum: açık / doğrulandı / çürüdü → K-NNN.

| # | Varsayım | Risk | Nasıl sınanır | Aşama | Durum |
|---|---|---|---|---|---|

## Sürprizler

Beklenmedik bulgular; ana başlık başında okunur. Biçim: `- yyyy-MM-dd · gözlem · etki`.

## Açık kararlar

Biçim: `- [ ] konu: seçenekler, tarih`. Karar verilince buradan silinir ve
`KARARLAR.md`'ye yazılır.

## Bilinen sınırlar ve bakım

Canlıda ya da testte görülen sınırlar ve bakım işleri. Şimdilik yok.

## Yaklaşan takvim

Tarihli işler. Şimdilik yok.

---

Geçmiş: `GUNLUK.md`. Kararların gerekçeleri: `KARARLAR.md`.
