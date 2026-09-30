# yeni-proje.ps1: bir klasöre ai-sablon çalışma düzenini kurar (belgeler, ayar, durum betiği).
# Var olan hiçbir dosyanın üzerine YAZMAZ. .gitignore satırları ve ek bölümleri yalnız eklenir.
#   -Hedef     kurulacak klasör (varsayılan: geçerli klasör)
#   -Ekler     ek adları, virgülle (ör. python-windows); ekler\ altındaki klasör adlarıdır
#   -ProjeAdi  {{PROJE_ADI}} değeri (varsayılan: klasör adı)
#   -Arac      Claude ya da Codex; yalnız "sonraki adım" yönergesini seçer
#   -Kontrol   hiçbir şey yazmadan envanter çıkarır (YENİ ya da VAR)
param(
    [string]$Hedef = '.',
    [string[]]$Ekler = @(),
    [string]$ProjeAdi = '',
    [string]$Arac = '',
    [switch]$Kontrol
)

# Git'in stderr'i hata sayılmasın diye 'Continue'; hatalar Hata() ile elle verilir.
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }
$script:Utf8 = New-Object System.Text.UTF8Encoding($false)
$script:Inv = [System.Globalization.CultureInfo]::InvariantCulture

function Hata([string]$Mesaj) {
    Write-Output ('HATA: ' + $Mesaj)
    exit 1
}

function SurumBul([string]$Kok) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return 'bilinmiyor' }
    $h = & git --no-optional-locks -C $Kok rev-parse --short HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $h) { return 'commitsiz' }
    $d = & git --no-optional-locks -C $Kok status --porcelain 2>$null
    if ($d) { return "$h-degismis" }
    return "$h"
}

# ReadAllText BOM'u kendisi atlar; satır sonlarına dokunmaz.
function MetinOku([string]$Yol) { return [System.IO.File]::ReadAllText($Yol) }

# md ve json BOM'suz UTF-8 yazılır (BOM yalnız .ps1 için gerekir; o Copy-Item ile kopyalanır).
function MetinYaz([string]$Yol, [string]$Metin) {
    $klasor = Split-Path -Parent $Yol
    if (-not (Test-Path -LiteralPath $klasor)) { New-Item -ItemType Directory -Path $klasor -Force | Out-Null }
    [System.IO.File]::WriteAllText($Yol, $Metin, $script:Utf8)
}

function Doldur([string]$Metin) {
    return $Metin.Replace('{{PROJE_ADI}}', $script:ProjeAdi).Replace('{{TARIH}}', $script:Tarih).Replace('{{TARIH_SAAT}}', $script:TarihSaat).Replace('{{SABLON_SURUM}}', $script:Surum).Replace('{{SABLON_KOKU}}', $script:SablonKoku)
}

function EksikSatirlar([string[]]$Mevcut, [string[]]$Eklenecek) {
    $var = @{}
    foreach ($s in $Mevcut) { $var[$s.Trim()] = 1 }
    $sonuc = New-Object System.Collections.Generic.List[string]
    foreach ($s in $Eklenecek) {
        $t = $s.Trim()
        if ($t -eq '') { continue }
        if (-not $var.ContainsKey($t)) { $sonuc.Add($t); $var[$t] = 1 }
    }
    return @($sonuc)
}

# İzin girdilerini şablonun girintisini bozmadan metin üzerinden ekler; sonunda ayrıştırmayı denetler.
function JsonListeyeEkle([string]$Json, [string]$Liste, [string[]]$Girdiler) {
    $nesne = $Json | ConvertFrom-Json
    $var = @($nesne.permissions.$Liste)
    $yeni = @($Girdiler | Where-Object { $var -notcontains $_ } | Select-Object -Unique)
    if ($yeni.Count -eq 0) { return $Json }
    $m = [regex]::Match($Json, ('(?s)("' + $Liste + '"\s*:\s*\[)(.*?)(\r?\n\s*\])'))
    if (-not $m.Success) { throw "$Liste listesi bulunamadı" }
    $blok = ($yeni | ForEach-Object { '      ' + (ConvertTo-Json -InputObject $_ -Compress) }) -join ",`n"
    $ayirac = ",`n"
    if ($m.Groups[2].Value.Trim() -eq '') { $ayirac = "`n" }
    $son = $Json.Substring(0, $m.Groups[2].Index + $m.Groups[2].Length) + $ayirac + $blok + $Json.Substring($m.Groups[3].Index)
    $null = $son | ConvertFrom-Json
    return $son
}

function PlanaEkle([string]$Kaynak, [string]$Rel, [string]$Tur) {
    $yol = Join-Path $script:Hedef $Rel
    $script:Plan.Add([pscustomobject]@{
            Kaynak = $Kaynak; Rel = $Rel; Tur = $Tur; Yol = $yol
            Var = (Test-Path -LiteralPath $yol -PathType Leaf); Durum = ''; Not = ''
        })
}

# ---------------------------------------------------------------- girdiler
$Kok = Split-Path -Parent $PSScriptRoot
$script:SablonKoku = $Kok
$script:Surum = SurumBul $Kok
$simdi = Get-Date
$script:Tarih = $simdi.ToString('yyyy-MM-dd', $script:Inv)
$script:TarihSaat = $simdi.ToString('yyyy-MM-dd HH:mm', $script:Inv)

if (-not (Test-Path -LiteralPath $Hedef -PathType Container)) { Hata "hedef klasör bulunamadı: $Hedef" }
$script:Hedef = (Resolve-Path -LiteralPath $Hedef).Path.TrimEnd('\')

# Bu klasörlere kurulum yapılmaz (savunma amaçlı; skill de aynısını reddeder).
$masaustu = [Environment]::GetFolderPath('Desktop').TrimEnd('\')
$ev = $HOME.TrimEnd('\')
if ($script:Hedef -ieq $Kok.TrimEnd('\') -or $script:Hedef.StartsWith($Kok.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { Hata 'hedef şablon deposunun kendisi ya da içi olamaz.' }
if ($script:Hedef -ieq $ev) { Hata 'hedef ev klasörü olamaz.' }
if ($script:Hedef -ieq $masaustu) { Hata 'hedef Masaüstü kökü olamaz; bir alt klasör seç.' }
$stajYolu = Join-Path $masaustu 'Staj'
if ($script:Hedef -ieq $stajYolu -or $script:Hedef.StartsWith($stajYolu + '\', [StringComparison]::OrdinalIgnoreCase)) { Hata 'Staj eski düzenli bir proje; buraya kurulum yapılmaz.' }
if ($script:Hedef.Length -le 3) { Hata 'hedef sürücü kökü olamaz.' }

$script:ProjeAdi = $ProjeAdi.Trim()
if (-not $script:ProjeAdi) { $script:ProjeAdi = Split-Path -Leaf $script:Hedef }

$aracAdi = ''
if ($Arac.Trim()) {
    if ($Arac.Trim() -ieq 'Claude') { $aracAdi = 'Claude' }
    elseif ($Arac.Trim() -ieq 'Codex') { $aracAdi = 'Codex' }
    else { Hata "-Arac Claude ya da Codex olmalı: $Arac" }
}

$ekAdlari = @($Ekler | ForEach-Object { $_ -split '[,;]' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$ekVeri = New-Object System.Collections.Generic.List[object]
foreach ($e in $ekAdlari) {
    if ($e -notmatch '^[a-z0-9-]+$') { Hata "geçersiz ek adı: $e" }
    $ekYol = Join-Path $Kok "ekler\$e"
    if (-not (Test-Path -LiteralPath $ekYol -PathType Container)) {
        $mevcutEkler = @(Get-ChildItem -LiteralPath (Join-Path $Kok 'ekler') -Directory -ErrorAction SilentlyContinue | ForEach-Object Name) -join ', '
        Hata "ek bulunamadı: $e (mevcut ekler: $mevcutEkler)"
    }
    $agentsEk = ''
    $izinEk = ''
    $gitEk = @()
    if (Test-Path -LiteralPath (Join-Path $ekYol 'AGENTS.ek.md')) { $agentsEk = Doldur (MetinOku (Join-Path $ekYol 'AGENTS.ek.md')) }
    if (Test-Path -LiteralPath (Join-Path $ekYol 'izinler.ek.json')) { $izinEk = MetinOku (Join-Path $ekYol 'izinler.ek.json') }
    if (Test-Path -LiteralPath (Join-Path $ekYol 'gitignore.ek')) { $gitEk = @((MetinOku (Join-Path $ekYol 'gitignore.ek')) -split "`r?`n") }
    $ekVeri.Add([pscustomobject]@{ Ad = $e; Yol = $ekYol; Agents = $agentsEk; Izin = $izinEk; Git = $gitEk })
}

# ---------------------------------------------------------------- plan
$script:Plan = New-Object System.Collections.Generic.List[object]
$projeKlasoru = Join-Path $Kok 'proje'
foreach ($f in (Get-ChildItem -LiteralPath $projeKlasoru -Recurse -File -Force | Sort-Object FullName)) {
    $rel = $f.FullName.Substring($projeKlasoru.Length + 1)
    $parcalar = @($rel -split '\\' | ForEach-Object { if ($_ -match '^_(claude|githooks)$') { '.' + $Matches[1] } else { $_ } })
    $son = $parcalar[$parcalar.Count - 1]
    if ($son -eq 'gitignore.sablon') { $son = '.gitignore' }
    elseif ($son -eq 'gitattributes.sablon') { $son = '.gitattributes' }
    else { $son = $son -replace '\.sablon(?=\.[^.]+$)', '' }
    $parcalar[$parcalar.Count - 1] = $son
    $hedefRel = $parcalar -join '\'
    $tur = 'sablon'
    if ($hedefRel -eq '.gitignore') { $tur = 'gitignore' } elseif ($hedefRel -like '*.json') { $tur = 'json' }
    PlanaEkle $f.FullName $hedefRel $tur
}
PlanaEkle (Join-Path $Kok 'scripts\durum.ps1') '.ai\durum.ps1' 'ps1'

# Ekin dosyalar\ klasörü olduğu gibi (yol yapısı korunarak) hedefe kopyalanır; var olan dosyanın üzerine yazılmaz.
foreach ($ek in $ekVeri) {
    $dosyaKlasoru = Join-Path $ek.Yol 'dosyalar'
    if (-not (Test-Path -LiteralPath $dosyaKlasoru -PathType Container)) { continue }
    foreach ($f in (Get-ChildItem -LiteralPath $dosyaKlasoru -Recurse -File -Force | Sort-Object FullName)) {
        PlanaEkle $f.FullName $f.FullName.Substring($dosyaKlasoru.Length + 1) 'ekdosya'
    }
}

$agentsPlan = $script:Plan | Where-Object { $_.Rel -eq 'AGENTS.md' } | Select-Object -First 1
$ayarPlan = $script:Plan | Where-Object { $_.Rel -eq '.claude\settings.json' } | Select-Object -First 1
# Ayar dosyası bu şablondan kurulduysa (oturum başı kancası durum.ps1'i çağırır) sonradan eklenen ekin
# izinleri birleştirilir; başka bir kaynaktan gelen ayar dosyasına dokunulmaz.
$script:AyarBizim = $false
if ($ayarPlan.Var) { $script:AyarBizim = (MetinOku $ayarPlan.Yol).Contains('.ai/durum.ps1') }
$agentsMetni = ''
$agentsIsaretli = $false
if ($agentsPlan.Var) {
    $agentsMetni = MetinOku $agentsPlan.Yol
    $agentsIsaretli = $agentsMetni.Contains('<!-- ai-sablon:')
}
$mod = 'yeni proje'
if ($agentsPlan.Var -and -not $agentsIsaretli) { $mod = 'mevcut projeye ekleme (AGENTS.md var, ai-sablon işareti yok; yalnız eksik dosyalar eklenir)' }
elseif ($agentsPlan.Var) { $mod = 'ai-sablon kurulu projeye ekleme (yalnız eksikler eklenir)' }

$gitSatirlari = @((MetinOku (Join-Path $projeKlasoru 'gitignore.sablon')) -split "`r?`n")
foreach ($ek in $ekVeri) { $gitSatirlari += $ek.Git }

foreach ($p in $script:Plan) {
    switch ($p.Tur) {
        'gitignore' {
            if ($p.Var) {
                $eksik = @(EksikSatirlar @((MetinOku $p.Yol) -split "`r?`n") $gitSatirlari)
                $p.Durum = 'VAR'
                $p.Not = "+$($eksik.Count) satır eklenir"
            }
            else {
                $p.Durum = 'YENİ'
                $p.Not = "$(@(EksikSatirlar @() $gitSatirlari).Count) satır"
            }
        }
        'ps1' {
            if ($p.Var) {
                $p.Durum = 'VAR'
                $ayni = (Get-FileHash -LiteralPath $p.Yol -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $p.Kaynak -Algorithm SHA256).Hash
                if ($ayni) { $p.Not = 'atlanır (şablonla aynı)' } else { $p.Not = 'atlanır (şablondan FARKLI, üzerine yazılmaz)' }
            }
            else { $p.Durum = 'YENİ' }
        }
        'json' {
            if ($p.Var) {
                $p.Durum = 'VAR'
                if ($script:AyarBizim) { $p.Not = 'korunur; varsa ek izinleri eklenir' } else { $p.Not = 'atlanır; ek izinleri eklenmez' }
            }
            else { $p.Durum = 'YENİ' }
        }
        default {
            if ($p.Var) { $p.Durum = 'VAR'; $p.Not = 'atlanır' } else { $p.Durum = 'YENİ' }
        }
    }
}

# Ek bölümü AGENTS.md'ye ne olacak?
$ekNotlari = New-Object System.Collections.Generic.List[string]
foreach ($ek in $ekVeri) {
    $ekAgentsIslem = 'yok'
    if ($ek.Agents) {
        $baslik = ($ek.Agents -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
        if (-not $agentsPlan.Var) { $ekAgentsIslem = 'ekle'; $ekNotlari.Add("EK   $($ek.Ad): AGENTS.md'ye bölüm eklenecek ('$baslik')") }
        elseif (-not $agentsIsaretli) { $ekNotlari.Add("EK   $($ek.Ad): AGENTS.md'ye bölüm EKLENMEZ (ai-sablon işareti yok); eklemek için kullanıcıdan onay al") }
        elseif (-not $agentsMetni.Contains('<!-- EKLER -->')) { $ekNotlari.Add("EK   $($ek.Ad): AGENTS.md'ye bölüm EKLENMEZ (<!-- EKLER --> işareti yok)") }
        elseif ($agentsMetni.Contains($baslik)) { $ekNotlari.Add("EK   $($ek.Ad): AGENTS.md'de bölüm zaten var (atlanır)") }
        else { $ekAgentsIslem = 'ekle'; $ekNotlari.Add("EK   $($ek.Ad): mevcut AGENTS.md'ye bölüm eklenecek ('$baslik')") }
    }
    $ek | Add-Member -NotePropertyName AgentsIslem -NotePropertyValue $ekAgentsIslem -Force
    if ($ek.Izin) {
        $girdiler = @((($ek.Izin | ConvertFrom-Json).permissions.allow))
        if ($ayarPlan.Var) {
            $mevcutAllow = @()
            try { $mevcutAllow = @(((MetinOku $ayarPlan.Yol) | ConvertFrom-Json).permissions.allow) } catch { }
            $eksikIzin = @($girdiler | Where-Object { $mevcutAllow -notcontains $_ })
            if ($eksikIzin.Count -eq 0) { $ekNotlari.Add("EK   $($ek.Ad): izinler settings.json'da zaten var (atlanır)") }
            elseif ($script:AyarBizim) { $ekNotlari.Add("EK   $($ek.Ad): mevcut settings.json'a $($eksikIzin.Count) izin girdisi eklenecek") }
            else { $ekNotlari.Add("EK   $($ek.Ad): .claude\settings.json ai-sablon'a ait değil, dokunulmaz; eksik izinleri elle ekle: " + ($eksikIzin -join ' | ')) }
        }
        else { $ekNotlari.Add("EK   $($ek.Ad): settings.json'a $($girdiler.Count) izin girdisi eklenecek") }
    }
}

# ---------------------------------------------------------------- envanter
$baslikMetni = '[yeni-proje] Uygulama'
if ($Kontrol) { $baslikMetni = '[yeni-proje] Kontrol (hiçbir şey yazılmaz)' }
Write-Output $baslikMetni
Write-Output "Hedef     : $($script:Hedef)"
Write-Output "Şablon    : $Kok (sürüm: $($script:Surum))"
Write-Output "Proje adı : $($script:ProjeAdi)"
$ekOzet = 'yok'
if ($ekAdlari.Count) { $ekOzet = $ekAdlari -join ', ' }
Write-Output "Ekler     : $ekOzet"
Write-Output "Mod       : $mod"
if ($agentsPlan.Var) {
    if ($agentsIsaretli) { Write-Output 'AGENTS.md : ai-sablon işareti VAR' } else { Write-Output 'AGENTS.md : ai-sablon işareti YOK' }
}
else { Write-Output 'AGENTS.md : yok' }
Write-Output ''
foreach ($p in $script:Plan) {
    $satir = '{0,-6} {1}' -f $p.Durum, $p.Rel
    if ($p.Not) { $satir += "  ($($p.Not))" }
    Write-Output $satir
}
foreach ($n in $ekNotlari) { Write-Output $n }
$yeniSayisi = @($script:Plan | Where-Object { $_.Durum -eq 'YENİ' }).Count
$varSayisi = @($script:Plan | Where-Object { $_.Durum -eq 'VAR' }).Count
Write-Output ''
Write-Output "Özet: $yeniSayisi YENİ, $varSayisi VAR."
if ($Kontrol) { exit 0 }

# ---------------------------------------------------------------- uygulama
$degisen = New-Object System.Collections.Generic.List[string]
$sonuclar = New-Object System.Collections.Generic.List[string]
$gitTam = $gitSatirlari

# AGENTS.md metni: yeni dosyada doldurulmuş şablon, işaretli mevcut dosyada olduğu gibi.
function EkleriUygula([string]$Agents) {
    foreach ($ek in $script:EkVeri) {
        if ($ek.AgentsIslem -ne 'ekle') { continue }
        $Agents = $Agents.Replace('<!-- EKLER -->', $ek.Agents.TrimEnd() + "`n`n<!-- EKLER -->")
    }
    return $Agents
}
$script:EkVeri = $ekVeri

foreach ($p in $script:Plan) {
    switch ($p.Tur) {
        'sablon' {
            if ($p.Var) { $sonuclar.Add("ATLANDI    $($p.Rel)"); continue }
            $m = Doldur (MetinOku $p.Kaynak)
            if ($p.Rel -eq 'AGENTS.md') { $m = EkleriUygula $m }
            # Git kancası sh betiğidir; şablon CRLF'li klonlanmış olsa bile hedefe LF yazılır.
            if ($p.Rel -like '.githooks\*') { $m = $m.Replace("`r`n", "`n") }
            MetinYaz $p.Yol $m
            $degisen.Add($p.Rel); $sonuclar.Add("OLUŞTURULDU $($p.Rel)")
        }
        'ps1' {
            if ($p.Var) { $sonuclar.Add("ATLANDI    $($p.Rel)"); continue }
            $klasor = Split-Path -Parent $p.Yol
            if (-not (Test-Path -LiteralPath $klasor)) { New-Item -ItemType Directory -Path $klasor -Force | Out-Null }
            Copy-Item -LiteralPath $p.Kaynak -Destination $p.Yol
            $sonuclar.Add("OLUŞTURULDU $($p.Rel)")
        }
        'json' {
            if ($p.Var) { $sonuclar.Add("ATLANDI    $($p.Rel)"); continue }
            $m = MetinOku $p.Kaynak
            foreach ($ek in $ekVeri) {
                if (-not $ek.Izin) { continue }
                $izinNesne = ($ek.Izin | ConvertFrom-Json).permissions
                foreach ($liste in @($izinNesne.PSObject.Properties | ForEach-Object Name)) {
                    $m = JsonListeyeEkle $m $liste @($izinNesne.$liste)
                }
            }
            MetinYaz $p.Yol $m
            $degisen.Add($p.Rel); $sonuclar.Add("OLUŞTURULDU $($p.Rel)")
        }
        'ekdosya' {
            # İki ek aynı yolu verirse ikincisi ilkinin üzerine yazmasın: yazmadan hemen önce yeniden bakılır.
            if ($p.Var -or (Test-Path -LiteralPath $p.Yol -PathType Leaf)) { $sonuclar.Add("ATLANDI    $($p.Rel)"); continue }
            MetinYaz $p.Yol (Doldur (MetinOku $p.Kaynak))
            $degisen.Add($p.Rel); $sonuclar.Add("OLUŞTURULDU $($p.Rel)")
        }
        'gitignore' {
            if ($p.Var) {
                $mevcut = MetinOku $p.Yol
                $eksik = @(EksikSatirlar @($mevcut -split "`r?`n") $gitTam)
                if ($eksik.Count -eq 0) { $sonuclar.Add("ATLANDI    $($p.Rel) (eklenecek satır yok)"); continue }
                $nl = "`n"
                if ($mevcut.Contains("`r`n")) { $nl = "`r`n" }
                $govde = $mevcut
                if ($govde.Length -gt 0 -and -not $govde.EndsWith("`n")) { $govde += $nl }
                MetinYaz $p.Yol ($govde + ($eksik -join $nl) + $nl)
                $sonuclar.Add("BİRLEŞTİRİLDİ $($p.Rel) (+$($eksik.Count) satır)")
            }
            else {
                $satirlar = @(EksikSatirlar @() $gitTam)
                MetinYaz $p.Yol (($satirlar -join "`n") + "`n")
                $sonuclar.Add("OLUŞTURULDU $($p.Rel)")
            }
        }
    }
}

# Var olan, ai-sablon işaretli AGENTS.md'ye ek bölümü eklemek (yeni dosyada zaten eklendi).
if ($agentsPlan.Var -and $agentsIsaretli) {
    $m = EkleriUygula $agentsMetni
    if ($m -ne $agentsMetni) {
        MetinYaz $agentsPlan.Yol $m
        $degisen.Add('AGENTS.md'); $sonuclar.Add('EK EKLENDİ  AGENTS.md (mevcut dosyaya bölüm eklendi)')
    }
}

# Var olan, bu şablondan kurulmuş settings.json'a ek izinleri eklemek (yeni dosyada zaten eklendi).
if ($ayarPlan.Var -and $script:AyarBizim) {
    $once = MetinOku $ayarPlan.Yol
    $m = $once
    try {
        foreach ($ek in $ekVeri) {
            if (-not $ek.Izin) { continue }
            $izinNesne = ($ek.Izin | ConvertFrom-Json).permissions
            foreach ($liste in @($izinNesne.PSObject.Properties | ForEach-Object Name)) {
                $m = JsonListeyeEkle $m $liste @($izinNesne.$liste)
            }
        }
        if ($m -ne $once) {
            MetinYaz $ayarPlan.Yol $m
            $sonuclar.Add('EK EKLENDİ  .claude\settings.json (ek izinleri eklendi)')
        }
    }
    catch { $sonuclar.Add("ATLANDI    .claude\settings.json (izinler eklenemedi: $($_.Exception.Message); elle ekle)") }
}

# Araştırma belgeleri için klasör (boş klasör Git'e girmez; kullanıcı ilk belgeyi koyunca girer).
$arastirma = Join-Path $script:Hedef 'docs\arastirma\genel'
if (($mod -eq 'yeni proje' -or $agentsIsaretli) -and -not (Test-Path -LiteralPath $arastirma)) {
    New-Item -ItemType Directory -Path $arastirma -Force | Out-Null
    $sonuclar.Add('OLUŞTURULDU docs\arastirma\genel\ (boş klasör)')
}

Write-Output ''
Write-Output 'Sonuç:'
foreach ($s in $sonuclar) { Write-Output ('  ' + $s) }

# Kalan yer tutucular: yapay zekâ cevaplara göre doldurur.
$kalan = New-Object System.Collections.Generic.List[string]
foreach ($rel in ($degisen | Select-Object -Unique)) {
    $bul = [regex]::Matches((MetinOku (Join-Path $script:Hedef $rel)), '\{\{[A-Z_]+\}\}') | ForEach-Object { $_.Value } | Select-Object -Unique
    if ($bul) { $kalan.Add("  ${rel}: " + ($bul -join ', ')) }
}
Write-Output ''
if ($kalan.Count) {
    Write-Output 'Doldurulacak yer tutucular (yeni-proje skill cevaplardan doldurur):'
    foreach ($k in $kalan) { Write-Output $k }
}
else { Write-Output 'Doldurulacak yer tutucu kalmadı.' }

$basla = '/basla (Claude) ya da $basla (Codex)'
if ($aracAdi -eq 'Claude') { $basla = '/basla' } elseif ($aracAdi -eq 'Codex') { $basla = '$basla' }
Write-Output ''
Write-Output 'Sonraki adım:'
if ($mod -eq 'yeni proje') {
    Write-Output '  1. Kalan yer tutucuları doldur; KARARLAR.md''ye K-001, GUNLUK.md''ye ilk kaydı yaz.'
    Write-Output '  2. Git''i (git init, commit) sen yönetirsin; şablon Git''e dokunmaz.'
    Write-Output '  3. Araştırma sonuçlarını docs\arastirma\genel\ klasörüne koy.'
    Write-Output "  4. Yeni oturum aç, güven penceresini kabul et; plan modunda 'araştırmaya göre projenin planını çıkar' de."
}
else {
    Write-Output '  1. Kalan yer tutucuları doldur (ek soruları: ekin EK.md dosyası).'
    Write-Output "  2. AGENTS.md 'Kod ve kontrol' bölümündeki test ve biçim satırlarını ekin komutlarına yönlendir."
    Write-Output "  3. Gerekirse yeni oturum aç ($basla)."
}
exit 0
