# durum.ps1: projenin oturum durumunu SALT OKUMA ile özetler.
# Devir notunun güncelliğini Git durumuyla karşılaştırır ve UYARI (U1-U6) üretir.
# Hiçbir dosyaya yazmaz, Git durumunu değiştirmez. Oturum başı kancası bir hata yüzünden
# oturumu engellemesin diye her durumda 0 ile çıkar.
#   -Proje  incelenecek klasör (varsayılan: $env:CLAUDE_PROJECT_DIR, yoksa geçerli klasör)
#   -Kanca  oturum başı kancası için kısa çıktı (en çok 12 satır)
param(
    [string]$Proje,
    [switch]$Kanca
)

$ErrorActionPreference = 'Continue'
# Git ve bu betik UTF-8 konuşur; PowerShell 5.1 varsayılan kod sayfasıyla Türkçe harfleri bozar.
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

$script:Tr = [System.Globalization.CultureInfo]::GetCultureInfo('tr-TR')
$script:Inv = [System.Globalization.CultureInfo]::InvariantCulture

function Bicim([datetime]$Zaman) {
    return $Zaman.ToString('yyyy-MM-dd HH:mm', $script:Inv)
}

function KisaltMetin([string]$Metin, [int]$En) {
    if ($null -eq $Metin) { return '' }
    if ($Metin.Length -le $En) { return $Metin }
    return $Metin.Substring(0, $En - 1) + '…'
}

function Yas([TimeSpan]$Fark) {
    if ($Fark.TotalMinutes -lt -2) { return 'gelecekte' }
    $dk = [int][math]::Floor($Fark.TotalMinutes)
    if ($dk -lt 1) { return 'az önce' }
    if ($dk -lt 60) { return "$dk dk önce" }
    if ($dk -lt 2880) { return ('{0} sa {1} dk önce' -f [math]::Floor($dk / 60), ($dk % 60)) }
    return ('{0} gün önce' -f [math]::Floor($dk / 1440))
}

# Git çıktısını satır dizisi olarak döndürür; çıkış kodu $script:GitKod'da kalır.
function GitCalistir([string[]]$Arguman) {
    $c = & git --no-optional-locks -C $script:Proje -c core.quotepath=false @Arguman 2>$null
    $script:GitKod = $LASTEXITCODE
    if ($null -eq $c) { return @() }
    return @($c | Where-Object { $_ -ne '' })
}

# İki biçim okunur: yeni "2026-09-29 20:20" ve eski Staj biçimi "29 Eylül 2026, 20:20".
# Önce "güncelleme" ya da "tarih" geçen satırlara bakılır; başka tarihler yanıltmasın.
function TarihOku([string[]]$Satirlar) {
    $aylar = @{
        'ocak' = 1; 'şubat' = 2; 'mart' = 3; 'nisan' = 4; 'mayıs' = 5; 'haziran' = 6
        'temmuz' = 7; 'ağustos' = 8; 'eylül' = 9; 'ekim' = 10; 'kasım' = 11; 'aralık' = 12
    }
    $oncelikli = @($Satirlar | Where-Object { $_ -match 'güncelleme|tarih' })
    $digerleri = @($Satirlar | Where-Object { $_ -notmatch 'güncelleme|tarih' })
    foreach ($s in ($oncelikli + $digerleri)) {
        try {
            if ($s -match '(\d{4})-(\d{2})-(\d{2})[ T]+(\d{1,2}):(\d{2})') {
                return [datetime]::new([int]$Matches[1], [int]$Matches[2], [int]$Matches[3], [int]$Matches[4], [int]$Matches[5], 0)
            }
            if ($s -match '(\d{1,2})\s+([^\W\d_]+)\s+(\d{4})[,\s]+(\d{1,2}):(\d{2})') {
                $ay = $aylar[$Matches[2].ToLower($script:Tr)]
                if ($ay) {
                    return [datetime]::new([int]$Matches[3], $ay, [int]$Matches[1], [int]$Matches[4], [int]$Matches[5], 0)
                }
            }
        }
        catch { }
    }
    return $null
}

try {
    if (-not $Proje) {
        if ($env:CLAUDE_PROJECT_DIR) { $Proje = $env:CLAUDE_PROJECT_DIR } else { $Proje = (Get-Location).Path }
    }
    if (-not (Test-Path -LiteralPath $Proje -PathType Container)) { throw "klasör bulunamadı: $Proje" }
    $Proje = (Resolve-Path -LiteralPath $Proje).Path
    $ad = Split-Path -Leaf $Proje
    $simdi = Get-Date
    $tolerans = [TimeSpan]::FromMinutes(2)
    $uyarilar = New-Object System.Collections.Generic.List[string]
    $bilgiler = New-Object System.Collections.Generic.List[string]

    # Devir notunun adı Belge haritasından okunur; harita yoksa (eski düzen) DEVAM.md.
    $devirAd = 'DEVAM.md'
    $agents = Join-Path $Proje 'AGENTS.md'
    if (Test-Path -LiteralPath $agents -PathType Leaf) {
        foreach ($l in (Get-Content -LiteralPath $agents -Encoding UTF8 -ErrorAction Stop)) {
            if ($l -match '^\s*\|') {
                $h = $l.Trim().Trim('|').Split('|')
                if ($h.Count -ge 2 -and $h[0].Trim() -eq 'Devir notu') {
                    $d = $h[1].Trim().Trim('`').Trim()
                    if ($d -and -not [System.IO.Path]::IsPathRooted($d) -and $d -notmatch '\.\.') { $devirAd = $d }
                    break
                }
            }
        }
    }
    $devirYol = Join-Path $Proje $devirAd
    $devirVar = Test-Path -LiteralPath $devirYol -PathType Leaf

    # Git
    $gitVar = $false
    $dal = ''
    $kok = $Proje
    $commitler = @()
    $degisenler = New-Object System.Collections.Generic.List[object]
    $bekleyenPush = 0
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $top = @(GitCalistir @('rev-parse', '--show-toplevel'))
        if ($script:GitKod -eq 0 -and $top.Count -gt 0) {
            $gitVar = $true
            $kok = ($top[0] -replace '/', '\')
            $b = @(GitCalistir @('branch', '--show-current'))
            if ($b.Count -gt 0) { $dal = $b[0] } else { $dal = '(dal yok/detached)' }
            $commitler = @(GitCalistir @('log', '-5', '--format=%h%x09%ct%x09%s'))
            if ($script:GitKod -ne 0) { $commitler = @() }
            foreach ($s in (GitCalistir @('status', '--porcelain'))) {
                if ($s.Length -lt 4) { continue }
                $kod = $s.Substring(0, 2).Trim()
                $yol = $s.Substring(3)
                if ($yol.Contains(' -> ')) { $yol = $yol.Substring($yol.IndexOf(' -> ') + 4) }
                $yol = $yol.Trim('"')
                $degisenler.Add([pscustomobject]@{ Kod = $kod; Yol = $yol })
            }
            $it = @(GitCalistir @('rev-list', '--count', '@{u}..HEAD'))
            if ($script:GitKod -eq 0 -and $it.Count -gt 0) { $bekleyenPush = [int]$it[0] }
            # Biten aşamanın kodu donmuştur; son aşama etiketinden beri değişen dosya sayısı hatırlatılır.
            $etiket = @(GitCalistir @('describe', '--tags', '--abbrev=0', '--match', 'asama-*'))
            if ($script:GitKod -eq 0 -and $etiket.Count -gt 0) {
                $etiketDegisen = @(GitCalistir @('diff', '--name-only', $etiket[0]))
                if ($script:GitKod -eq 0) {
                    $bilgiler.Add("BİLGİ: son aşama etiketi $($etiket[0]); o zamandan beri değişen dosya: $($etiketDegisen.Count).")
                }
            }
        }
    }
    else {
        $bilgiler.Add('BİLGİ: git bulunamadı; Git denetimi yapılmadı.')
    }
    if (-not $gitVar -and $bilgiler.Count -eq 0) {
        $bilgiler.Add('BİLGİ: Git deposu değil; commit ve dosya denetimi yapılmadı.')
    }

    $sonCommit = $null
    $sonCommitZaman = $null
    if ($commitler.Count -gt 0) {
        $p = $commitler[0].Split("`t", 3)
        $sonCommitZaman = [DateTimeOffset]::FromUnixTimeSeconds([long]$p[1]).LocalDateTime
        $sonCommit = [pscustomobject]@{ Hash = $p[0]; Zaman = $sonCommitZaman; Ileti = $p[2] }
    }

    # Devir notu ve uyarılar
    $devirZaman = $null
    $devirSatir = 0
    $devirTum = @()
    if (-not $devirVar) {
        $uyarilar.Add("UYARI U1: devir notu yok ($devirAd); önceki oturumdan kalan bilgi olmayabilir.")
    }
    else {
        $bas = @(Get-Content -LiteralPath $devirYol -Encoding UTF8 -TotalCount 10 -ErrorAction Stop)
        $devirTum = @([System.IO.File]::ReadAllLines($devirYol))
        $devirSatir = $devirTum.Count
        $devirZaman = TarihOku $bas
        if ($null -eq $devirZaman) {
            $uyarilar.Add("UYARI U2: $devirAd içinde 'Son güncelleme' tarihi okunamadı; güncelliği denetlenemedi.")
        }
        else {
            if ($devirZaman -gt ($simdi + $tolerans)) {
                $uyarilar.Add("UYARI U6: devir notunun tarihi gelecekte ($(Bicim $devirZaman)); saat ya da tarih hatalı olabilir.")
            }
            if ($sonCommit -and $sonCommit.Zaman -gt ($devirZaman + $tolerans)) {
                $uyarilar.Add("UYARI U3: son commit ($($sonCommit.Hash), $(Bicim $sonCommit.Zaman)) devir notundan ($(Bicim $devirZaman)) yeni; devir notu eski olabilir.")
            }
            if ($gitVar) {
                # DEVAM.md ve CLAUDE.md yerel dosyalar: onların değişmesi devir notunu eskitmez.
                $haric = @('DEVAM.md', 'CLAUDE.md', (Split-Path -Leaf $devirAd))
                $yeniler = New-Object System.Collections.Generic.List[string]
                foreach ($f in $degisenler) {
                    $yolSade = $f.Yol.TrimEnd('/')
                    if ($haric -contains (Split-Path -Leaf $yolSade)) { continue }
                    $tam = Join-Path $kok ($yolSade -replace '/', '\')
                    if (-not (Test-Path -LiteralPath $tam)) { continue }
                    $mt = (Get-Item -LiteralPath $tam -Force -ErrorAction Stop).LastWriteTime
                    if ((Test-Path -LiteralPath $tam -PathType Container)) {
                        # Yeni klasör: içindeki en yeni dosyaya bak (ilk 200 dosya ile sınırlı).
                        foreach ($x in (Get-ChildItem -LiteralPath $tam -Recurse -File -Force -ErrorAction SilentlyContinue | Select-Object -First 200)) {
                            if ($x.LastWriteTime -gt $mt) { $mt = $x.LastWriteTime }
                        }
                    }
                    if ($mt -gt ($devirZaman + $tolerans)) { $yeniler.Add($f.Yol) }
                }
                if ($yeniler.Count -gt 0) {
                    $ilk = @($yeniler | Select-Object -First 3) -join ', '
                    $ek = ''
                    if ($yeniler.Count -gt 3) { $ek = " (+$($yeniler.Count - 3) dosya daha)" }
                    $uyarilar.Add("UYARI U4: devir notundan sonra değişen commit edilmemiş dosya var: $ilk$ek.")
                }
            }
            if (($simdi - $devirZaman).TotalDays -gt 3) {
                $bilgiler.Add("BİLGİ: devir notu $([int][math]::Floor(($simdi - $devirZaman).TotalDays)) gün önce yazılmış.")
            }
        }
        if ($devirSatir -gt 60) {
            $uyarilar.Add("UYARI U5: devir notu $devirSatir satır (sınır 60); biten iş Günlük'e, karar Kararlar'a taşınıp kısaltılmalı.")
        }
    }
    if ($bekleyenPush -gt 0) {
        $bilgiler.Add("BİLGİ: push edilmemiş $bekleyenPush commit var.")
    }

    # Çıktı
    $cikti = New-Object System.Collections.Generic.List[string]
    $dalMetni = ''
    if ($gitVar) { $dalMetni = " · dal: $dal" }
    $cikti.Add("[ai-sablon durum] $ad$dalMetni · $(Bicim $simdi)")
    foreach ($u in $uyarilar) { $cikti.Add($u) }

    if ($devirVar) {
        $devirMetni = "Devir notu: $devirAd"
        if ($devirZaman) { $devirMetni += " · son güncelleme $(Bicim $devirZaman) ($(Yas ($simdi - $devirZaman)))" }
        $devirMetni += " · $devirSatir satır"
    }
    else {
        $devirMetni = "Devir notu: yok ($devirAd)"
    }

    if ($Kanca) {
        if ($sonCommit) { $cikti.Add("Son commit: $($sonCommit.Hash) $(Bicim $sonCommit.Zaman) $(KisaltMetin $sonCommit.Ileti 60)") }
        elseif ($gitVar) { $cikti.Add('Son commit: henüz commit yok') }
        $cikti.Add($devirMetni)
        foreach ($b in $bilgiler) { $cikti.Add($b) }
        if ($gitVar) {
            $cikti.Add("Commit edilmemiş: $($degisenler.Count) dosya")
            foreach ($f in ($degisenler | Select-Object -First 8)) { $cikti.Add("  $($f.Kod) $(KisaltMetin $f.Yol 80)") }
            if ($degisenler.Count -gt 8) { $cikti.Add("  … ve $($degisenler.Count - 8) dosya daha") }
        }
        $cikti = @($cikti | Select-Object -First 12)
    }
    else {
        $cikti.Add("Klasör: $Proje")
        foreach ($b in $bilgiler) { $cikti.Add($b) }
        if ($gitVar) {
            $cikti.Add('Son 5 commit:')
            if ($commitler.Count -eq 0) { $cikti.Add('  (henüz commit yok)') }
            foreach ($c in $commitler) {
                $p = $c.Split("`t", 3)
                $z = [DateTimeOffset]::FromUnixTimeSeconds([long]$p[1]).LocalDateTime
                $cikti.Add("  $($p[0]) $(Bicim $z) $(KisaltMetin $p[2] 80)")
            }
        }
        $cikti.Add($devirMetni)
        if ($devirTum.Count -gt 0) {
            for ($i = 0; $i -lt $devirTum.Count; $i++) {
                if ($devirTum[$i] -match '^\s*#{1,6}\s*Sıradaki iş') {
                    for ($j = $i + 1; $j -lt $devirTum.Count; $j++) {
                        $t = $devirTum[$j].Trim()
                        if ($t -match '^#') { break }
                        if ($t) {
                            $t = $t -replace '^([-*]|\d+[.)])\s*', ''
                            $cikti.Add("Sıradaki iş (ilk madde): $(KisaltMetin $t 140)")
                            break
                        }
                    }
                    break
                }
            }
        }
        if ($gitVar) {
            $cikti.Add("Commit edilmemiş dosyalar: $($degisenler.Count)")
            foreach ($f in ($degisenler | Select-Object -First 30)) { $cikti.Add("  $($f.Kod) $($f.Yol)") }
            if ($degisenler.Count -gt 30) { $cikti.Add("  … ve $($degisenler.Count - 30) dosya daha") }
        }
    }
    foreach ($s in $cikti) { Write-Output $s }
}
catch {
    Write-Output ('durum okunamadı: ' + $_.Exception.Message)
}
exit 0
