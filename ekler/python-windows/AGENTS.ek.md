## Python (Windows)

- Python {{PYTHON_SURUMU}}; sanal ortam `.venv` (Git'e girmez). Kabuk: Windows
  PowerShell 5.1.
- Kod değiştiğinde üç denetimi de çalıştır:
  - `.venv\Scripts\python.exe -m pytest -q`
  - `.venv\Scripts\python.exe -m black --check {{KAYNAK}}`
  - `.venv\Scripts\python.exe -m flake8 {{KAYNAK}}`
- `black`'i `--check` olmadan çalıştırma: dosyaları toplu değiştirir ve izin listesinde
  yoktur. Biçim uyarısı çıkarsa dosyayı elle düzelt ya da kullanıcıya sor.
- Ortam değişkeni ya da dış servis isteyen testler, tanım yoksa atlanır. Çıktıdaki
  `skipped` sayısı 0 değilse "bütün testler geçti" deme; neyin neden atlandığını söyle.
- Testler kuralları sınar. "Testler geçti", canlıda doğru çalıştığı anlamına gelmez;
  canlı doğrulama için kullanıcının çalıştıracağı komutu ver.
- `.venv` oluşturma ve paket kurma (`pip install`) dış sisteme gider: komutu ver,
  kullanıcı çalıştırsın.
