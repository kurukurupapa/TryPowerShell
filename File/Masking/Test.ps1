# .\File\Masking\Test.ps1

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$inDir = Join-Path $baseDir "SampleInput"
$outDir = Join-Path $baseDir "SampleOutput"

# Mask_UTF8.ps1
# UTF-8, CRLF
. $baseDir/Mask_UTF8.ps1 $inDir/utf8_CRLF.csv $outDir/Mask_UTF8_utf8_CRLF.csv
# UTF-8, CRLF, Quotation
. $baseDir/Mask_UTF8.ps1 $inDir/utf8_CRLF_Quotation.csv $outDir/Mask_UTF8_utf8_CRLF_Quotation.csv
# UTF-8, LF
. $baseDir/Mask_UTF8.ps1 $inDir/utf8_LF.csv $outDir/Mask_UTF8_utf8_LF.csv -NewLine LF

# Mask_UTF8_StdInOut.ps1
# UTF-8, CRLF
$inPath = ".\File\Masking\SampleInput\utf8_CRLF.csv"
$outPath = ".\File\Masking\SampleOutput\Mask_UTF8_StdInOut_utf8_CRLF.csv"
Get-Content -Encoding UTF8 $inPath | .\File\Masking\Mask_UTF8_StdInOut.ps1 | %{ [Text.Encoding]::UTF8.GetBytes($_+"`r`n") } | Set-Content -Encoding Byte $outPath
# UTF-8, CRLF, Quotation
$inPath = ".\File\Masking\SampleInput\utf8_CRLF_Quotation.csv"
$outPath = ".\File\Masking\SampleOutput\Mask_UTF8_StdInOut_utf8_CRLF_Quotation.csv"
Get-Content -Encoding UTF8 $inPath | .\File\Masking\Mask_UTF8_StdInOut.ps1 | %{ [Text.Encoding]::UTF8.GetBytes($_+"`r`n") } | Set-Content -Encoding Byte $outPath
# UTF-8, LF
$inPath = ".\File\Masking\SampleInput\utf8_LF.csv"
$outPath = ".\File\Masking\SampleOutput\Mask_UTF8_StdInOut_utf8_LF.csv"
Get-Content -Encoding UTF8 $inPath | .\File\Masking\Mask_UTF8_StdInOut.ps1 | %{ [Text.Encoding]::UTF8.GetBytes($_+"`n") } | Set-Content -Encoding Byte $outPath
# SJIS, CRLF
$inPath = ".\File\Masking\SampleInput\sjis.csv"
$outPath = ".\File\Masking\SampleOutput\Mask_UTF8_StdInOut_sjis.csv"
Get-Content $inPath | .\File\Masking\Mask_UTF8_StdInOut.ps1 | Set-Content $outPath
