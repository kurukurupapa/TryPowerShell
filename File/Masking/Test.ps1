# .\File\Masking\Test.ps1

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$inDir = Join-Path $baseDir "SampleInput"

# Mask_UTF8.ps1
$baseName = "Mask_UTF8"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/utf8_CRLF.csv           $outDir/utf8_CRLF.csv
. $scriptPath $inDir/utf8_CRLF_Quotation.csv $outDir/utf8_CRLF_Quotation.csv
. $scriptPath $inDir/utf8_LF.csv             $outDir/utf8_LF.csv             -NewLine LF

# Mask_UTF8_ImportExportCsv.ps1
$baseName = "Mask_UTF8_ImportExportCsv"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/utf8_CRLF.csv           $outDir/utf8_CRLF.csv
. $scriptPath $inDir/utf8_CRLF_Quotation.csv $outDir/utf8_CRLF_Quotation.csv
. $scriptPath $inDir/utf8_LF.csv             $outDir/utf8_LF.csv

# Mask_UTF8_StdInOut.ps1
$baseName = "Mask_UTF8_StdInOut"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
# UTF-8, CRLF
$inPath = "$inDir/utf8_CRLF.csv"
$outPath = "$outDir/utf8_CRLF.csv"
Get-Content -Encoding UTF8 $inPath | . $scriptPath | %{ [Text.Encoding]::UTF8.GetBytes($_+"`r`n") } | Set-Content -Encoding Byte $outPath
# UTF-8, CRLF, Quotation
$inPath = "$inDir/utf8_CRLF_Quotation.csv"
$outPath = "$outDir/utf8_CRLF_Quotation.csv"
Get-Content -Encoding UTF8 $inPath | . $scriptPath | %{ [Text.Encoding]::UTF8.GetBytes($_+"`r`n") } | Set-Content -Encoding Byte $outPath
# UTF-8, LF
$inPath = "$inDir/utf8_LF.csv"
$outPath = "$outDir/utf8_LF.csv"
Get-Content -Encoding UTF8 $inPath | . $scriptPath | %{ [Text.Encoding]::UTF8.GetBytes($_+"`n") } | Set-Content -Encoding Byte $outPath
# SJIS, CRLF
$inPath = "$inDir/sjis.csv"
$outPath = "$outDir/sjis.csv"
Get-Content $inPath | . $scriptPath | Set-Content $outPath

# Mask_SJIS.ps1
$baseName = "Mask_SJIS"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/sjis.csv $outDir/sjis.csv

# Mask_SJIS2.ps1
$baseName = "Mask_SJIS2"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/sjis.csv $outDir/sjis.csv
