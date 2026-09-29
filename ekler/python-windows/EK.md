# Ek: python-windows

Windows'ta (PowerShell 5.1) `.venv` sanal ortamı olan bir Python projesi için
test, biçim ve izin ayarlarını çekirdek şablona ekler. Bu dosya yalnız
`yeni-proje` skill'i içindir; hedef projeye kopyalanmaz.

## Ne ekler

| Ek dosyası | Hedefte ne olur |
|---|---|
| `AGENTS.ek.md` | İçeriği hedef `AGENTS.md`'de `<!-- EKLER -->` işaretinin **önüne** eklenir; işaret yerinde kalır (başka ek de gelebilir). |
| `izinler.ek.json` | `permissions.allow` girdileri `.claude/settings.json`'a tekrarsız eklenir; diğer anahtarlara dokunulmaz. |
| `gitignore.ek` | Satırlar hedef `.gitignore`'a tekrarsız eklenir. |

## Sorular (`yeni-proje` bunları çekirdek sorulara ekler)

1. Kaynak klasörleri (biçim ve stil denetimi bunlara uygulanır) [varsayılan: `app tests`].
   Boşlukla ayrılmış klasör adları; klasörler henüz yoksa da yazılabilir.
2. Python sürümü (ör. `3.12`). Kullanıcı bilmiyorsa yerelde `py --list` çıktısındaki
   sürümlerden biri önerilebilir; boş cevap "henüz belirlenmedi" olur ve
   `PLAN.md`'ye açık karar olarak yazılır.

## Yer tutucular (araç cevaplardan doldurur)

- `{{KAYNAK}}`: soru 1'in cevabı, `AGENTS.ek.md` içinde iki yerde geçer.
- `{{PYTHON_SURUMU}}`: soru 2'nin cevabı.

## Kullanıcıya önerilecek komutlar (araç çalıştırmaz)

`.venv` oluşturma ve paket kurma çalıştırılmaz, yalnız komut olarak verilir; paket
kurulumu dış sisteme (PyPI) gider. Sürüm bilinmiyorsa `-3.12` yerine ilgili sürümü yaz:

```
py -3.12 -m venv .venv
.venv\Scripts\python.exe -m pip install pytest black flake8
```

Proje bağımlılıkları için ayrıca `requirements.txt` varsa
`.venv\Scripts\python.exe -m pip install -r requirements.txt`.

## Sınırlar

- `black` yalnız `--check` ile izinlidir; dosyaları toplu değiştiren biçimlendirme
  izin listesinde yoktur.
- İzin girdileri `.venv` yolunu hem ters bölü (`\`) hem düz bölü (`/`) ile yazar,
  çünkü komut metni kuralla birebir eşleşmezse izin yine sorulur.
- Test, biçim ve stil komutlarının çalışması için `pytest`, `black`, `flake8`
  `.venv` içinde kurulu olmalıdır.
