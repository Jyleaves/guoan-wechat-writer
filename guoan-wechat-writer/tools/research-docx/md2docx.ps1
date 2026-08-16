param([string]$InFile, [string]$Output, [string]$Variant = 'gongwen')
$ErrorActionPreference = 'Stop'
if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
  throw '未找到 pandoc：研究体 Word 生成依赖 pandoc。请先安装（winget install --id JohnMacFarlane.Pandoc，或访问 https://pandoc.org/installing.html），然后重试。'
}
if (-not (Test-Path $InFile)) { throw "输入文件不存在：$InFile" }
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$ref = if ($Variant -eq 'songti') { Join-Path $base 'reference-songti.docx' } else { Join-Path $base 'reference.docx' }
if (-not (Test-Path $ref)) { throw "template not found: $ref (run make-reference.ps1)" }
$filter = Join-Path $base 'lead-sentence.lua'
& pandoc $InFile -o $Output --reference-doc=$ref --lua-filter=$filter
if ($LASTEXITCODE -ne 0) { throw 'pandoc failed' }
Write-Host ("docx built: " + $Output + " (variant: " + $Variant + ")")
