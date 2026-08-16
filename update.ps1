# 一键更新脚本：下载最新 Release 并交由包内 install.ps1 重装
# 用法：
#   pwsh -File update.ps1                                    （交互式，同 install.ps1）
#   pwsh -File update.ps1 -Workdir "D:\NewsWriter"           （沿用首次安装的工作目录，免交互）
#   pwsh -File update.ps1 -Version v1.1.9                    （更新到指定版本，默认最新）
#   pwsh -File update.ps1 -DryRun                            （更新到临时目录做测试，不污染本机）
# 说明：反馈记忆与历史产出都在工作目录（outputs/feedback），与技能目录无关，更新覆盖不影响数据。
param(
  [string]$CorpusPath,
  [string]$Workdir,
  [string]$Version,
  [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -lt 7) {
  throw 'PowerShell 7+ (pwsh) required. Windows PowerShell 5.1 cannot read this UTF-8 (no BOM) script correctly. Install it with: winget install --id Microsoft.PowerShell  then re-run: pwsh -File update.ps1'
}
$repo = 'Jyleaves/guoan-wechat-writer'

# 当前已装版本（如有）
$installedSkillMd = Join-Path $env:USERPROFILE '.agents\skills\guoan-wechat-writer\SKILL.md'
$curVer = $null
if (Test-Path -LiteralPath $installedSkillMd) {
  $m = [regex]::Match((Get-Content -LiteralPath $installedSkillMd -Raw -Encoding UTF8), 'version:\s*"([0-9.]+)"')
  if ($m.Success) { $curVer = $m.Groups[1].Value }
}

# 下载地址：默认 latest 稳定名（每个 Release 固定挂载），-Version 时用版本化地址
if ($Version) {
  $v = $Version.TrimStart('v')
  $asset = "guoan-wechat-writer-v$v.zip"
  $dl = "https://github.com/$repo/releases/download/v$v/$asset"
} else {
  $asset = 'guoan-wechat-writer-latest.zip'
  $dl = "https://github.com/$repo/releases/latest/download/$asset"
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("guoan-update-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
  $zip = Join-Path $tmp $asset
  Write-Host "下载：$dl"
  Invoke-WebRequest -Uri $dl -OutFile $zip
  Expand-Archive -LiteralPath $zip -DestinationPath $tmp -Force

  # 包完整性 + 版本对比
  $newSkillMd = Join-Path $tmp 'guoan-wechat-writer-skill\SKILL.md'
  if (-not (Test-Path -LiteralPath $newSkillMd)) { throw "包内缺少 guoan-wechat-writer-skill\SKILL.md，下载可能不完整：$zip" }
  $m2 = [regex]::Match((Get-Content -LiteralPath $newSkillMd -Raw -Encoding UTF8), 'version:\s*"([0-9.]+)"')
  $newVer = if ($m2.Success) { $m2.Groups[1].Value } else { '(未知)' }
  Write-Host ("版本：{0} -> v{1}" -f $(if ($curVer) { "v$curVer" } else { '(未安装)' }), $newVer)

  # 交由包内 install.ps1 完成安装：占位符替换、预设安装、覆盖确认逻辑的单一来源
  $installer = Join-Path $tmp 'install.ps1'
  if (-not (Test-Path -LiteralPath $installer)) { throw "包内缺少 install.ps1：$zip" }
  $installArgs = @{ Workdir = $Workdir; CorpusPath = $CorpusPath; DryRun = $DryRun }
  & $installer @installArgs
} finally {
  Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
