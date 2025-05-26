# .\File\Masking\Test.ps1

# $baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = "File/Masking"
$inDir = Join-Path $baseDir "SampleInput"

# Mask_UTF8_GetSetContent.ps1
$baseName = "Mask_UTF8_GetSetContent"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/utf8_CRLF.csv           $outDir/utf8_CRLF.csv
. $scriptPath $inDir/utf8_CRLF_Quotation.csv $outDir/utf8_CRLF_Quotation.csv
. $scriptPath $inDir/utf8_LF.csv             $outDir/utf8_LF.csv             -NewLine LF

# Mask_UTF8_ImportExportCsv.ps1
# 改行コードCRLFのみ
$baseName = "Mask_UTF8_ImportExportCsv"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/utf8_CRLF.csv           $outDir/utf8_CRLF.csv
. $scriptPath $inDir/utf8_CRLF_Quotation.csv $outDir/utf8_CRLF_Quotation.csv

# Mask_UTF8_IOStream.ps1
$baseName = "Mask_UTF8_IOStream"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/utf8_CRLF.csv           $outDir/utf8_CRLF.csv
. $scriptPath $inDir/utf8_CRLF_Quotation.csv $outDir/utf8_CRLF_Quotation.csv
. $scriptPath $inDir/utf8_LF.csv             $outDir/utf8_LF.csv             -NewLine LF

# Mask_UTF8_StdInOut.ps1
$baseName = "Mask_UTF8_StdInOut"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
Get-Content -Encoding UTF8 $inDir/utf8_CRLF.csv           | . $scriptPath | % { [Text.Encoding]::UTF8.GetBytes($_ + "`r`n") } | Set-Content -Encoding Byte $outDir/utf8_CRLF.csv
Get-Content -Encoding UTF8 $inDir/utf8_CRLF_Quotation.csv | . $scriptPath | % { [Text.Encoding]::UTF8.GetBytes($_ + "`r`n") } | Set-Content -Encoding Byte $outDir/utf8_CRLF_Quotation.csv
Get-Content -Encoding UTF8 $inDir/utf8_LF.csv             | . $scriptPath | % { [Text.Encoding]::UTF8.GetBytes($_ + "`n") }   | Set-Content -Encoding Byte $outDir/utf8_LF.csv
Get-Content                $inDir/sjis_CRLF.csv           | . $scriptPath                                                     | Set-Content                $outDir/sjis_CRLF.csv

# Mask_SJIS.ps1
$baseName = "Mask_SJIS"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/sjis_CRLF.csv $outDir/sjis_CRLF.csv

# Mask_SJIS2.ps1
$baseName = "Mask_SJIS2"
$scriptPath = Join-Path $baseDir "$baseName.ps1"
$outDir = Join-Path $baseDir "SampleOutput_$baseName"
. $scriptPath $inDir/sjis_CRLF.csv $outDir/sjis_CRLF.csv
