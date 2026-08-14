param([string]$Variant = 'gongwen')
$ErrorActionPreference = 'Stop'
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$tmp = Join-Path $base 'tmp-default'
if (-not (Test-Path (Join-Path $tmp 'word\styles.xml'))) {
  $srcZip = Join-Path $base 'reference-default.docx'
  if (-not (Test-Path $srcZip)) { throw 'reference-default.docx not found in script directory' }
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($srcZip, $tmp)
  Write-Host 'tmp-default extracted from reference-default.docx'
}
$stPath = Join-Path $tmp 'word\styles.xml'
$st = [System.IO.File]::ReadAllText($stPath, [System.Text.Encoding]::UTF8)

function ReplaceBlock($sid, $newBlock) {
  $pattern = '(?s)<w:style [^>]*w:styleId="' + $sid + '"[^>]*>.*?</w:style>'
  $m = [regex]::Match($script:st, $pattern)
  if (-not $m.Success) { throw "style $sid not found" }
  $script:st = $script:st.Substring(0, $m.Index) + $newBlock + $script:st.Substring($m.Index + $m.Length)
  Write-Host "patched style: $sid"
}

if ($Variant -eq 'gongwen') {
  # 公文式（1集装箱实测）：正文仿宋三号、一级标题黑体三号、二级标题楷体三号、首行缩进2字符
  $bodyFont = '仿宋'; $bodySz = '32'
  $h1Font = '黑体'; $h1Sz = '32'; $h1Bold = '<w:b w:val="0" />'
  $h2Font = '楷体'; $h2Sz = '32'; $h2Bold = '<w:b w:val="0" />'
} else {
  # 宋体小四式（1石油实测）：正文宋体小四、标题宋体加粗
  $bodyFont = '宋体'; $bodySz = '24'
  $h1Font = '宋体'; $h1Sz = '27'; $h1Bold = '<w:b />'
  $h2Font = '宋体'; $h2Sz = '24'; $h2Bold = '<w:b />'
}

$normal = @"
<w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal" />
    <w:qFormat />
    <w:pPr>
      <w:widowControl w:val="0" />
      <w:jc w:val="both" />
      <w:ind w:firstLineChars="200" w:firstLine="640" />
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="$bodyFont" w:cs="Times New Roman" />
      <w:sz w:val="$bodySz" />
      <w:szCs w:val="$bodySz" />
    </w:rPr>
  </w:style>
"@

$bodyText = @"
<w:style w:type="paragraph" w:styleId="BodyText">
    <w:name w:val="Body Text" />
    <w:basedOn w:val="Normal" />
    <w:link w:val="BodyTextChar" />
    <w:qFormat />
    <w:pPr>
      <w:spacing w:before="0" w:after="0" />
    </w:pPr>
  </w:style>
"@

$compact = @"
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact">
    <w:name w:val="Compact" />
    <w:basedOn w:val="BodyText" />
    <w:qFormat />
    <w:pPr>
      <w:spacing w:before="0" w:after="0" />
    </w:pPr>
  </w:style>
"@

$h1 = @"
<w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1" />
    <w:basedOn w:val="Normal" />
    <w:next w:val="BodyText" />
    <w:link w:val="Heading1Char" />
    <w:uiPriority w:val="9" />
    <w:qFormat />
    <w:pPr>
      <w:keepNext />
      <w:keepLines />
      <w:spacing w:before="0" w:after="0" />
      <w:outlineLvl w:val="0" />
      <w:ind w:firstLineChars="200" w:firstLine="640" />
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="$h1Font" w:cs="Times New Roman" />
      $h1Bold
      <w:color w:val="000000" />
      <w:sz w:val="$h1Sz" />
      <w:szCs w:val="$h1Sz" />
    </w:rPr>
  </w:style>
"@

$h2 = @"
<w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2" />
    <w:basedOn w:val="Normal" />
    <w:next w:val="BodyText" />
    <w:link w:val="Heading2Char" />
    <w:uiPriority w:val="9" />
    <w:qFormat />
    <w:pPr>
      <w:keepNext />
      <w:keepLines />
      <w:spacing w:before="0" w:after="0" />
      <w:outlineLvl w:val="1" />
      <w:ind w:firstLineChars="200" w:firstLine="640" />
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="$h2Font" w:cs="Times New Roman" />
      $h2Bold
      <w:color w:val="000000" />
      <w:sz w:val="$h2Sz" />
      <w:szCs w:val="$h2Sz" />
    </w:rPr>
  </w:style>
"@

$h1Char = @"
<w:style w:type="character" w:customStyle="1" w:styleId="Heading1Char">
    <w:name w:val="Heading 1 Char" />
    <w:basedOn w:val="DefaultParagraphFont" />
    <w:link w:val="Heading1" />
    <w:uiPriority w:val="9" />
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="$h1Font" w:cs="Times New Roman" />
      $h1Bold
      <w:color w:val="000000" />
      <w:sz w:val="$h1Sz" />
      <w:szCs w:val="$h1Sz" />
    </w:rPr>
  </w:style>
"@

$h2Char = @"
<w:style w:type="character" w:customStyle="1" w:styleId="Heading2Char">
    <w:name w:val="Heading 2 Char" />
    <w:basedOn w:val="DefaultParagraphFont" />
    <w:link w:val="Heading2" />
    <w:uiPriority w:val="9" />
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="$h2Font" w:cs="Times New Roman" />
      $h2Bold
      <w:color w:val="000000" />
      <w:sz w:val="$h2Sz" />
      <w:szCs w:val="$h2Sz" />
    </w:rPr>
  </w:style>
"@

ReplaceBlock 'Normal' $normal
ReplaceBlock 'BodyText' $bodyText
ReplaceBlock 'Compact' $compact
ReplaceBlock 'Heading1' $h1
ReplaceBlock 'Heading2' $h2
ReplaceBlock 'Heading1Char' $h1Char
ReplaceBlock 'Heading2Char' $h2Char

[System.IO.File]::WriteAllText($stPath, $st, (New-Object System.Text.UTF8Encoding($false)))

# document.xml: 替换空 sectPr 为样本页面设置（A4、上下2.54cm、左右3.175cm、行网格312）
$docPath = Join-Path $tmp 'word\document.xml'
$doc = [System.IO.File]::ReadAllText($docPath, [System.Text.Encoding]::UTF8)
$sampleSect = '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1440" w:right="1800" w:bottom="1440" w:left="1800" w:header="851" w:footer="992" w:gutter="0"/><w:cols w:space="425"/><w:docGrid w:type="lines" w:linePitch="312"/></w:sectPr>'
if ($doc.Contains('<w:sectPr />')) { $doc = $doc.Replace('<w:sectPr />', $sampleSect); Write-Host 'sectPr patched' } else { Write-Warning 'sectPr anchor not found' }
[System.IO.File]::WriteAllText($docPath, $doc, (New-Object System.Text.UTF8Encoding($false)))

# 打包
$outName = if ($Variant -eq 'gongwen') { 'reference.docx' } else { 'reference-songti.docx' }
$dst = Join-Path $base $outName
Remove-Item $dst -Force -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tmp, $dst)
Write-Host ("template built: " + $dst + " (" + (Get-Item $dst).Length + " bytes)")
