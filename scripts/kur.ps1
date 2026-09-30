# kur.ps1: kişisel kuralları ve skill'leri bu bilgisayarın genel klasörlerine kurar.
#   genel\KURALLAR.md       -> ~\.claude\CLAUDE.md ve ~\.codex\AGENTS.md
#   skills\<ad>             -> ~\.claude\skills\<ad> ve <CodexSkillKlasoru>\<ad>
#   ~\.claude\settings.json -> "attribution" anahtarı eklenir (diğer anahtarlar korunur)
# Dokunulmaz: skills\synced, skills\.trash, .codex\skills\.system.
# Değişecek ya da yabancı dosyalar önce yedeklenir. -Kontrol hiçbir şey yazmaz.
#   -Kontrol            durum tablosunu gösterip çıkar
#   -CodexSkillKlasoru  Codex skill klasörü (varsayılan: ~\.agents\skills)
#   -Zorla              ai-sablon işareti olmayan (yabancı) dosyaların da yedeklenip ezilmesine izin verir
param(
    [switch]$Kontrol,
    [string]$CodexSkillKlasoru = '',
    [switch]$Zorla
)

$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }
$script:Utf8 = New-Object System.Text.UTF8Encoding($false)

# ---------------------------------------------------------------- işlevler
# İşlevler yolu parametre olarak alır (betik düzeyindeki değişkene bağlı değildir); böylece
# gerçek ev klasörüne dokunmadan geçici klasörlerde denenebilir.

function SurumBul([string]$Kok) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return 'bilinmiyor' }
    $h = & git --no-optional-locks -C $Kok rev-parse --short HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $h) { return 'commitsiz' }
    $d = & git --no-optional-locks -C $Kok status --porcelain 2>$null
    if ($d) { return "$h-degismis" }
    return "$h"
}

# Skill ve kural dosyalarında kök yol ile sürüm kurulumda doldurulur.
function IcerikUret([string]$Metin, [string]$Kok, [string]$Surum) {
    return $Metin.Replace('__SABLON_KOKU__', $Kok).Replace('__SABLON_SURUM__', $Surum)
}

# AYNI/FARKLI karşılaştırması sürüm satırlarından etkilenmesin (her commit'te sürüm değişir).
function Normalle([string]$Metin) {
    $m = $Metin.Replace("`r`n", "`n")
    $m = [regex]::Replace($m, '(?m)^[ \t]*surum:[ \t]*".*"[ \t]*\n?', '')
    $m = [regex]::Replace($m, '(?m)^<!-- ai-sablon: KURALLAR .*? -->[ \t]*\n?', '')
    return $m
}

# md ve yaml BOM'suz UTF-8 ve LF ile yazılır; skill doğrulayıcısı "---\n" bekler.
function MetinYaz([string]$Yol, [string]$Metin) {
    $klasor = Split-Path -Parent $Yol
    if (-not (Test-Path -LiteralPath $klasor)) { New-Item -ItemType Directory -Path $klasor -Force | Out-Null }
    [System.IO.File]::WriteAllText($Yol, $Metin, $script:Utf8)
}

function Korumali([string]$Yol) {
    $y = $Yol.TrimEnd('\')
    if ($y -match '(?i)\\skills\\(synced|\.trash)(\\|$)' -or $y -match '(?i)\\\.system(\\|$)') {
        throw "korumalı yol, dokunulmaz: $Yol"
    }
}

function KuralMetni([string]$Kok, [string]$Surum) {
    $m = [System.IO.File]::ReadAllText((Join-Path $Kok 'genel\KURALLAR.md'))
    if (-not $m.EndsWith("`n")) { $m += "`n" }
    return $m + "`n<!-- ai-sablon: KURALLAR $Surum -->`n"
}

# Bir skill klasörünün kurulacak içeriği: göreli yol -> metin. Claude kopyasında yalnız-elle
# işaretli skill'e disable-model-invocation eklenir; Codex kopyasında eklenmez (doğrulayıcı reddeder).
function SkillDosyalari([string]$SkillKlasoru, [string]$Kok, [string]$Surum, [bool]$Claude) {
    $sonuc = [ordered]@{}
    foreach ($f in (Get-ChildItem -LiteralPath $SkillKlasoru -Recurse -File -Force | Sort-Object FullName)) {
        $rel = $f.FullName.Substring($SkillKlasoru.Length + 1)
        $m = IcerikUret ([System.IO.File]::ReadAllText($f.FullName)) $Kok $Surum
        if ($Claude -and $rel -eq 'SKILL.md' -and $m -match '(?m)^[ \t]+yalniz-elle:[ \t]*"evet"') {
            $m = ([regex]'(?m)^metadata:').Replace($m, "disable-model-invocation: true`nmetadata:", 1)
        }
        $sonuc[$rel] = $m
    }
    return $sonuc
}

# YENİ | BOŞ (0 bayt) | AYNI | FARKLI | YABANCI (ai-sablon işareti yok)
function DosyaDurumu([string]$Yol, [string]$Beklenen) {
    if (-not (Test-Path -LiteralPath $Yol)) { return 'YENİ' }
    if (-not (Test-Path -LiteralPath $Yol -PathType Leaf)) { return 'YABANCI' }
    if ((Get-Item -LiteralPath $Yol).Length -eq 0) { return 'BOŞ' }
    $m = [System.IO.File]::ReadAllText($Yol)
    if (-not $m.Contains('<!-- ai-sablon: KURALLAR ')) { return 'YABANCI' }
    # -ceq: PowerShell'in -eq'u harf boyutuna bakmaz; yalnız büyük/küçük harfi değişen kural da FARKLI sayılmalı.
    if ((Normalle $m) -ceq (Normalle $Beklenen)) { return 'AYNI' }
    return 'FARKLI'
}

function KlasorDurumu([string]$Yol, $Beklenen) {
    if (-not (Test-Path -LiteralPath $Yol)) { return 'YENİ' }
    if (-not (Test-Path -LiteralPath $Yol -PathType Container)) { return 'YABANCI' }
    $dosyalar = @(Get-ChildItem -LiteralPath $Yol -Recurse -File -Force)
    if ($dosyalar.Count -eq 0) { return 'BOŞ' }
    $skill = Join-Path $Yol 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skill -PathType Leaf)) { return 'YABANCI' }
    if (-not ([System.IO.File]::ReadAllText($skill)).Contains('kaynak: "ai-sablon"')) { return 'YABANCI' }
    $var = @{}
    foreach ($f in $dosyalar) { $var[$f.FullName.Substring($Yol.Length + 1)] = Normalle ([System.IO.File]::ReadAllText($f.FullName)) }
    if ($var.Count -ne $Beklenen.Count) { return 'FARKLI' }
    foreach ($k in $Beklenen.Keys) {
        if (-not $var.ContainsKey($k) -or $var[$k] -cne (Normalle $Beklenen[$k])) { return 'FARKLI' }
    }
    return 'AYNI'
}

# YENİ | BOŞ | AYNI | FARKLI | BOZUK (JSON değil; asla ezilmez)
function AyarDurumu([string]$Yol) {
    if (-not (Test-Path -LiteralPath $Yol)) { return 'YENİ' }
    if ((Get-Item -LiteralPath $Yol).Length -eq 0) { return 'BOŞ' }
    try { $o = [System.IO.File]::ReadAllText($Yol) | ConvertFrom-Json } catch { return 'BOZUK' }
    if ($null -eq $o -or $o -is [array]) { return 'BOZUK' }
    # Claude bu iki alanı metin bekler (boş metin imzayı gizler); false yazılırsa dosyanın tamamı yok sayılır.
    $a = $o.attribution
    if ($a -and ($a.commit -is [string]) -and ($a.pr -is [string]) -and $a.commit -ceq '' -and $a.pr -ceq '') { return 'AYNI' }
    return 'FARKLI'
}

# Yalnız "attribution" anahtarını ekler ya da değiştirir; öteki anahtarlar korunur.
function AyarYaz([string]$Yol) {
    $attr = [pscustomobject]@{ commit = ''; pr = '' }
    if ((Test-Path -LiteralPath $Yol) -and (Get-Item -LiteralPath $Yol).Length -gt 0) {
        $o = [System.IO.File]::ReadAllText($Yol) | ConvertFrom-Json
        $o | Add-Member -NotePropertyName attribution -NotePropertyValue $attr -Force
    }
    else { $o = [pscustomobject]@{ attribution = $attr } }
    $json = $o | ConvertTo-Json -Depth 20
    $null = $json | ConvertFrom-Json
    MetinYaz $Yol ($json + "`n")
}

function DosyaYedekle([string]$Yol, [string]$Damga) {
    $y = "$Yol.yedek-$Damga"
    Copy-Item -LiteralPath $Yol -Destination $y
    return $y
}

# Skill klasörü skills\ içinde kalırsa ikinci bir skill sayılır; bu yüzden dışarı taşınır.
function KlasorYedekle([string]$Yol, [string]$YedekTaban, [string]$Damga, [string]$Arac, [string]$Ad) {
    $ust = Join-Path (Join-Path $YedekTaban $Damga) $Arac
    if (-not (Test-Path -LiteralPath $ust)) { New-Item -ItemType Directory -Path $ust -Force | Out-Null }
    $hedef = Join-Path $ust $Ad
    Move-Item -LiteralPath $Yol -Destination $hedef
    return $hedef
}

# ---------------------------------------------------------------- ana akış
$Kok = Split-Path -Parent $PSScriptRoot
$Surum = SurumBul $Kok
$ClaudeKlasoru = Join-Path $HOME '.claude'
$CodexKlasoru = Join-Path $HOME '.codex'
if (-not $CodexSkillKlasoru) { $CodexSkillKlasoru = Join-Path $HOME '.agents\skills' }
$YedekTaban = Join-Path $HOME '.ai-sablon-yedek'

if (-not (Test-Path -LiteralPath (Join-Path $Kok 'genel\KURALLAR.md'))) {
    Write-Output "HATA: $Kok\genel\KURALLAR.md bulunamadı."
    exit 1
}

$isler = New-Object System.Collections.Generic.List[object]

$kural = KuralMetni $Kok $Surum
foreach ($hedef in @((Join-Path $ClaudeKlasoru 'CLAUDE.md'), (Join-Path $CodexKlasoru 'AGENTS.md'))) {
    $isler.Add([pscustomobject]@{ Tur = 'dosya'; Hedef = $hedef; Beklenen = $kural; Durum = (DosyaDurumu $hedef $kural); Arac = ''; Ad = '' })
}

foreach ($s in (Get-ChildItem -LiteralPath (Join-Path $Kok 'skills') -Directory | Sort-Object Name)) {
    if (@('synced', '.trash', '.system') -contains $s.Name) { continue }
    $beklenenClaude = SkillDosyalari $s.FullName $Kok $Surum $true
    $beklenenCodex = SkillDosyalari $s.FullName $Kok $Surum $false
    $hc = Join-Path (Join-Path $ClaudeKlasoru 'skills') $s.Name
    $hx = Join-Path $CodexSkillKlasoru $s.Name
    $isler.Add([pscustomobject]@{ Tur = 'skill'; Hedef = $hc; Beklenen = $beklenenClaude; Durum = (KlasorDurumu $hc $beklenenClaude); Arac = 'claude'; Ad = $s.Name })
    $isler.Add([pscustomobject]@{ Tur = 'skill'; Hedef = $hx; Beklenen = $beklenenCodex; Durum = (KlasorDurumu $hx $beklenenCodex); Arac = 'codex'; Ad = $s.Name })
}

$ayarYolu = Join-Path $ClaudeKlasoru 'settings.json'
$isler.Add([pscustomobject]@{ Tur = 'ayar'; Hedef = $ayarYolu; Beklenen = $null; Durum = (AyarDurumu $ayarYolu); Arac = ''; Ad = '' })

foreach ($i in $isler) { Korumali $i.Hedef }

# ---------------------------------------------------------------- durum tablosu
$baslik = '[kur] Uygulama'
if ($Kontrol) { $baslik = '[kur] Kontrol (hiçbir şey yazılmaz)' }
Write-Output $baslik
Write-Output "Kök   : $Kok"
Write-Output "Sürüm : $Surum"
Write-Output ''
foreach ($i in $isler) {
    $not = ''
    if ($i.Tur -eq 'ayar') {
        if ($i.Durum -eq 'YENİ' -or $i.Durum -eq 'BOŞ') { $not = '  (dosya oluşturulur; yalnız attribution)' }
        elseif ($i.Durum -eq 'FARKLI') { $not = '  (yalnız attribution eklenir/değişir; diğer anahtarlar korunur)' }
        elseif ($i.Durum -eq 'BOZUK') { $not = '  (geçerli JSON değil; DOKUNULMAZ, elle düzelt)' }
    }
    if ($i.Durum -eq 'YABANCI' -and -not $Zorla) { $not = '  (ai-sablon işareti yok; -Zorla olmadan atlanır)' }
    Write-Output ('{0,-8} {1}{2}' -f $i.Durum, $i.Hedef, $not)
}
Write-Output ''
Write-Output "Dokunulmaz: $ClaudeKlasoru\skills\synced, $ClaudeKlasoru\skills\.trash, $CodexKlasoru\skills\.system"
if (Test-Path -LiteralPath (Join-Path $CodexKlasoru 'AGENTS.override.md')) {
    Write-Output 'UYARI: ~\.codex\AGENTS.override.md var; Codex genel AGENTS.md yerine onu okur, kurallar yüklenmeyebilir.'
}
$degisecek = @($isler | Where-Object { $_.Durum -in 'YENİ', 'BOŞ', 'FARKLI' })
$yabanciSayisi = @($isler | Where-Object { $_.Durum -eq 'YABANCI' }).Count
Write-Output "Özet: $(@($isler | Where-Object { $_.Durum -eq 'AYNI' }).Count) AYNI, $($degisecek.Count) yazılacak, $yabanciSayisi yabancı."
if ($Kontrol) { exit 0 }

# ---------------------------------------------------------------- yazma
$damga = Get-Date -Format 'yyyyMMdd-HHmmss'
$sonuclar = New-Object System.Collections.Generic.List[string]
foreach ($i in $isler) {
    if ($i.Durum -eq 'AYNI' -or $i.Durum -eq 'BOZUK') { continue }
    if ($i.Durum -eq 'YABANCI' -and -not $Zorla) { $sonuclar.Add("ATLANDI   $($i.Hedef) (yabancı)"); continue }
    Korumali $i.Hedef
    try {
        switch ($i.Tur) {
            'dosya' {
                $yedek = ''
                if ($i.Durum -eq 'FARKLI' -or $i.Durum -eq 'YABANCI') { $yedek = DosyaYedekle $i.Hedef $damga }
                MetinYaz $i.Hedef $i.Beklenen
                if ($yedek) { $sonuclar.Add("YAZILDI   $($i.Hedef) (yedek: $yedek)") } else { $sonuclar.Add("YAZILDI   $($i.Hedef)") }
            }
            'skill' {
                $yedek = ''
                if ($i.Durum -eq 'FARKLI' -or $i.Durum -eq 'YABANCI') { $yedek = KlasorYedekle $i.Hedef $YedekTaban $damga $i.Arac $i.Ad }
                foreach ($k in $i.Beklenen.Keys) { MetinYaz (Join-Path $i.Hedef $k) $i.Beklenen[$k] }
                if ($yedek) { $sonuclar.Add("YAZILDI   $($i.Hedef) (yedek: $yedek)") } else { $sonuclar.Add("YAZILDI   $($i.Hedef)") }
            }
            'ayar' {
                $yedek = ''
                if ($i.Durum -eq 'FARKLI') { $yedek = DosyaYedekle $i.Hedef $damga }
                try { AyarYaz $i.Hedef }
                catch {
                    if ($yedek) { Copy-Item -LiteralPath $yedek -Destination $i.Hedef -Force }
                    throw
                }
                if ($yedek) { $sonuclar.Add("YAZILDI   $($i.Hedef) (attribution; yedek: $yedek)") } else { $sonuclar.Add("YAZILDI   $($i.Hedef) (attribution)") }
            }
        }
    }
    catch { $sonuclar.Add("HATA      $($i.Hedef): $($_.Exception.Message)") }
}
Write-Output ''
Write-Output 'Sonuç:'
foreach ($s in $sonuclar) { Write-Output ('  ' + $s) }
Write-Output ''
Write-Output 'Claude Code''da yeni bir oturum aç; Codex''i yeniden başlat.'
exit 0
