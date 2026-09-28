$packagePath = if ($env:TYPST_PACKAGE_PATH) {
    $env:TYPST_PACKAGE_PATH
} elseif ($env:APPDATA) {
    Join-Path $env:APPDATA 'typst\packages'
} else {
    throw 'No se encontró APPDATA. Define TYPST_PACKAGE_PATH para instalar el paquete.'
}

$target = Join-Path $packagePath 'local\inaoe-tesis\0.1.0'
$tempDir = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tempDir -ErrorAction Stop | Out-Null
$stage = $null
try {
    $archive = Join-Path $tempDir 'source.zip'
    Invoke-WebRequest -Uri 'https://github.com/CRAG666/Thesis_inaoe_template_typst/archive/refs/heads/main.zip' -OutFile $archive -UseBasicParsing -ErrorAction Stop
    Expand-Archive -LiteralPath $archive -DestinationPath $tempDir -ErrorAction Stop
    $sourceDir = Join-Path $tempDir 'Thesis_inaoe_template_typst-main'

    $parent = Split-Path -Parent $target
    New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop | Out-Null
    $stage = Join-Path $parent ([IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $stage -ErrorAction Stop | Out-Null
    foreach ($name in @('typst.toml', 'inaoe-tesis.typ', 'biblatex-cites', 'cover', 'template', 'README.md', 'README.es.md', 'LICENSE')) {
        Copy-Item -LiteralPath (Join-Path $sourceDir $name) -Destination $stage -Recurse -ErrorAction Stop
    }
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction Stop
    }
    Move-Item -LiteralPath $stage -Destination $target -ErrorAction Stop
    Write-Host "Paquete instalado en $target"
    Write-Host 'Crea un proyecto con: typst init @local/inaoe-tesis:0.1.0 mi-tesis'
} finally {
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction Stop
    if ($stage -and (Test-Path -LiteralPath $stage)) {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction Stop
    }
}
