param(
  [string]$RepoOwner = 'leekitleung',
  [string]$RepoName = 'better-fonts-market',
  [string]$Branch = 'main',
  [string]$SourceId = 'better-fonts-market',
  [string]$SourceName = 'Better Fonts Market',
  [string]$FontDir = '.',
  [string]$Output = 'manifest.json',
  [string]$ReleaseTag = 'fonts',
  [int]$LargeFileThresholdMB = 20,
  [ValidateSet('ofl', 'apache-2.0', 'gpl-2.0', 'gpl-3.0', 'mit', 'public-domain', 'personal', 'commercial', 'unknown')]
  [string]$DefaultLicense = 'unknown'
)

$ErrorActionPreference = 'Stop'
$LargeFileThreshold = $LargeFileThresholdMB * 1024 * 1024

function Get-RelativePath {
  param(
    [Parameter(Mandatory = $true)][string]$BasePath,
    [Parameter(Mandatory = $true)][string]$TargetPath
  )

  $baseWithSlash = $BasePath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  $baseUri = [System.Uri]::new($baseWithSlash)
  $targetUri = [System.Uri]::new($TargetPath)
  return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('\\', '/')
}

function Encode-PathForUrl {
  param([Parameter(Mandatory = $true)][string]$Path)

  $segments = $Path.Split('/') | Where-Object { $_ -ne '' }
  $encoded = $segments | ForEach-Object { [System.Uri]::EscapeDataString($_) }
  return ($encoded -join '/')
}

function Get-FontStyle {
  param([string]$Name)

  $n = $Name.ToLowerInvariant()
  if ($n -match 'oblique') { return 'oblique' }
  if ($n -match 'italic') { return 'italic' }
  return 'normal'
}

function Get-FontWeight {
  param([string]$Name)

  $n = $Name.ToLowerInvariant()
  if ($n -match 'thin') { return 100 }
  if ($n -match 'extra[-_ ]?light|ultra[-_ ]?light') { return 200 }
  if ($n -match 'light') { return 300 }
  if ($n -match 'regular|book|normal') { return 400 }
  if ($n -match 'medium') { return 500 }
  if ($n -match 'semi[-_ ]?bold|demi[-_ ]?bold') { return 600 }
  if ($n -match 'extra[-_ ]?bold|ultra[-_ ]?bold') { return 800 }
  if ($n -match 'bold') { return 700 }
  if ($n -match 'black|heavy') { return 900 }
  return 400
}

function Get-Family {
  param([string]$BaseName)

  $family = $BaseName -replace '[_-]+', ' '
  $family = $family -replace '(?i)\b(thin|extra\s*light|ultra\s*light|light|regular|book|normal|medium|semi\s*bold|demi\s*bold|bold|extra\s*bold|ultra\s*bold|black|heavy|italic|oblique)\b', ''
  $family = ($family -replace '\s+', ' ').Trim()
  if ([string]::IsNullOrWhiteSpace($family)) {
    return $BaseName
  }
  return $family
}

function Get-Id {
  param([string]$RelativePath)

  $normalized = $RelativePath.ToLowerInvariant()
  $base = $normalized -replace '\.[^.]+$', ''
  $base = $base -replace '[^a-z0-9]+', '-'
  $base = $base.Trim('-')
  if ([string]::IsNullOrWhiteSpace($base)) {
    $base = 'font'
  }

  $bytes = [System.Text.Encoding]::UTF8.GetBytes($normalized)
  $sha = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
  $suffix = ($sha | ForEach-Object { $_.ToString('x2') }) -join ''

  return "$base-$($suffix.Substring(0, 8))"
}

function Get-ReleaseAssetName {
  param([string]$Sha256, [string]$FileName)
  $ext = [System.IO.Path]::GetExtension($FileName)
  return "$($Sha256.Substring(0, 12))$ext"
}

$projectRoot = (Get-Location).Path
$fontRoot = Resolve-Path -Path $FontDir
$fontExtensions = @('.ttf', '.otf', '.ttc', '.woff', '.woff2')

$files = Get-ChildItem -Path $fontRoot -Recurse -File | Where-Object {
  $fontExtensions -contains $_.Extension.ToLowerInvariant()
} | Sort-Object FullName

if ($files.Count -eq 0) {
  throw "No fonts found under $fontRoot"
}

$fonts = @()
$largeFiles = @()

foreach ($file in $files) {
  $relativePath = Get-RelativePath -BasePath $projectRoot -TargetPath $file.FullName
  $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
  $sha = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()

  if ($file.Length -gt $LargeFileThreshold) {
    # 大文件走 Release
    $assetName = Get-ReleaseAssetName -Sha256 $sha -FileName $file.Name
    $url = "https://github.com/$RepoOwner/$RepoName/releases/download/$ReleaseTag/$assetName"
    $largeFiles += [ordered]@{
      path      = $file.FullName
      assetName = $assetName
      sha256    = $sha
    }
    Write-Host "  [Release] $($file.Name) ($([math]::Round($file.Length / 1MB, 1)) MB) -> $assetName"
  } else {
    # 小文件走 jsDelivr CDN
    $urlPath = Encode-PathForUrl -Path $relativePath
    $url = "https://cdn.jsdelivr.net/gh/$RepoOwner/$RepoName@$Branch/$urlPath"
    Write-Host "  [CDN] $($file.Name) ($([math]::Round($file.Length / 1MB, 1)) MB)"
  }

  $fonts += [ordered]@{
    id        = Get-Id -RelativePath $relativePath
    family    = Get-Family -BaseName $baseName
    style     = Get-FontStyle -Name $baseName
    weight    = Get-FontWeight -Name $baseName
    url       = $url
    sha256    = $sha
    size      = [int64]$file.Length
    updatedAt = (Get-Date $file.LastWriteTimeUtc).ToString('yyyy-MM-ddTHH:mm:ssZ')
    license   = $DefaultLicense
  }
}

$manifest = [ordered]@{
  manifestVersion = '1'
  generatedAt     = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
  source          = [ordered]@{
    id       = $SourceId
    name     = $SourceName
    homepage = "https://github.com/$RepoOwner/$RepoName"
  }
  fonts           = $fonts
}

$json = $manifest | ConvertTo-Json -Depth 8
Set-Content -Path $Output -Value $json -Encoding UTF8
Write-Host "Generated $Output with $($fonts.Count) fonts ($($largeFiles.Count) via Release)."

# 输出大文件列表供 workflow 使用
if ($env:GITHUB_OUTPUT) {
  if ($largeFiles.Count -gt 0) {
    $largeFilesJson = ($largeFiles | ConvertTo-Json -Depth 4 -Compress)
    "large_files=$largeFilesJson" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding UTF8
    "has_large_files=true" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding UTF8
  } else {
    "has_large_files=false" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding UTF8
  }
}
