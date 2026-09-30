# yeni-proje soruları

Soruları tek mesajda, numaralı sor. Köşeli parantez varsayılan cevaptır; kullanıcı
boş bırakırsa o kullanılır. Varsayılanı olmayan sorularda boş cevap "henüz
belirlenmedi" olur ve `PLAN.md`'nin "Açık kararlar" bölümüne
`- [ ] <konu>: belirlenmedi, <tarih>` satırı eklenir.

| # | Soru | Varsayılan | Doldurduğu alan (dosya) |
|---|---|---|---|
| 1 | Proje adı? | [klasör adı] | `{{PROJE_ADI}}` (betik doldurur; `-ProjeAdi`) |
| 2 | Proje ne yapacak, kim kullanacak? Yapılmayacak şeyler var mı? | – | `{{AMAC}}` (`AGENTS.md` Proje özeti, `PLAN.md` Amaç); `{{KAPSAM}}` (`PLAN.md`) |
| 3 | Tür ve ekler? | [yalnız çekirdek] | `-Ekler` (ek adları `ekler\` klasöründen listelenir) |
| 4 | Test komutu? | – | `{{TEST_KOMUTU}}` (`AGENTS.md`) |
| 5 | Biçim denetimi komutu? | – | `{{BICIM_KOMUTU}}` (`AGENTS.md`) |
| 6 | Projeye özel kısıtlar? (canlı işler, veri, gizli bilgi, dokunulmayacak dosyalar) | – | `{{KISITLAR}}` (`AGENTS.md`) |
| 7 | İlk aşama ve ilk adım ne? | – | `{{ILK_ASAMA}}` (`PLAN.md`); `{{ILK_ADIM}}` (`PLAN.md`, `DEVAM.md`) |

## Ek soruları

Seçilen ekin `EK.md` dosyasındaki "Sorular" bölümünü oku ve o soruları listeye
ekle. Örneğin `python-windows` ekinde: kaynak klasörleri [app tests] →
`{{KAYNAK}}`, Python sürümü → `{{PYTHON_SURUMU}}` (`AGENTS.md`, ek bölümü).

## Kurallar

- Ek seçildiyse soru 4 ve 5'i sorma: ek komutları kendi bölümünde verir. `AGENTS.md`'de
  `{{TEST_KOMUTU}}` ve `{{BICIM_KOMUTU}}` yerine "Aşağıdaki ek bölümüne bak." yaz.
- Soru 2'de kullanıcı yapılmayacakları söylemediyse `{{KAPSAM}}` yerine "Kapsam ve
  yapılmayacaklar henüz belirlenmedi." yaz ve Plan'a açık karar ekle.
- Sürüm ve ek listesini bu dosyadan değil, gerçek klasörlerden al; bu dosya eskir.
- Cevabı uydurma; kullanıcı söylemediyse "henüz belirlenmedi".
- Cevaplarda gizli bilgi (şifre, anahtar) çıkarsa dosyaya yazma; kullanıcıya uyar.
