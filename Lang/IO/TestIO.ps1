# ファイル入出力の処理時間を調べてみる
# Lang/IO/Test.ps1

$inPath = ".\Lang\IO\sample.txt"
$outPath = ".\Lang\IO\tmp.txt"

# サンプルファイル作成
function New-SampleData {
    param (
        [string]$path,
        [int]$sizeMB = 1
    )
    
    $dummy = "1234567890ABCDEF"
    $line = ""
    for ($j = 0; $j -lt 10; $j++) {
        $line += $dummy
    }
    
    for ($i = 0; $i -lt ($sizeMB * 1024 * 1024 / $line.Length); $i++) {
        Write-Output $line
    }
}
if (-not (Test-Path $inPath)) {
    New-SampleData $inPath 10 | Set-Content $inPath
}

# Get-Content/Set-Contentの処理時間を計測
$startTime = Get-Date
$lines = Get-Content $inPath
Set-Content $outPath -Value $lines
$endTime = Get-Date
Write-Host "Get/Set-Content（パイプラインなし）処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

$startTime = Get-Date
Get-Content $inPath | Set-Content $outPath
$endTime = Get-Date
Write-Host "Get/Set-Content（パイプライン）処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

# Get-Content/Set-Contentの処理時間を計測（エンコードあり）
$startTime = Get-Date
Get-Content $inPath -Encoding UTF8 | Set-Content $outPath -Encoding UTF8
$endTime = Get-Date
Write-Host "Get/Set-Content（UTF8オプションあり（BOM付きUTF8））処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

$startTime = Get-Date
Get-Content $inPath |
ForEach-Object { [Text.Encoding]::UTF8.GetBytes($_ + "`r`n") } |
Set-Content $outPath -Encoding Byte
$endTime = Get-Date
Write-Host "Get/Set-Content（UTF8変換（BOMなしUTF8））処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
# →かなり遅い。

# Import-Csv/Export-Csvの処理時間を計測
$startTime = Get-Date
Import-Csv $inPath | Export-Csv $outPath -NoTypeInformation
$endTime = Get-Date
Write-Host "Import/Export-Csv処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
# →Get/Set-Contentと比較して、だいぶ遅い。

# パイプラインでの処理時間を計測
$startTime = Get-Date
$lines | ForEach-Object { $_ } | Out-Null
$endTime = Get-Date
Write-Host "パイプライン2件 処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
$startTime = Get-Date
$lines | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | Out-Null
$endTime = Get-Date
Write-Host "パイプライン10件 処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

# 文字列置換の処理時間を計測
$startTime = Get-Date
$lines | ForEach-Object { $_ -replace 'A', 'a' } | Out-Null
$endTime = Get-Date
Write-Host "パイプライン2件＋文字列置換1件 処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
$startTime = Get-Date
$lines | ForEach-Object { (((((($_ -replace 'A', 'a') -replace 'B', 'b') -replace 'C', 'c') -replace 'D', 'd') -replace 'E', 'e') -replace 'F', 'f') } | Out-Null
$endTime = Get-Date
Write-Host "パイプライン2件＋文字列置換5件 処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

# StreamReaderとStreamWriterの処理時間を計測
$startTime = Get-Date
$reader = [System.IO.StreamReader]::new($inPath)
$writer = [System.IO.StreamWriter]::new($outPath, $false)
try {
    while ($null -ne ($line = $reader.ReadLine())) {
        $writer.WriteLine($line)
    }
}
finally {
    $reader.Close()
    $writer.Close()
}
$endTime = Get-Date
Write-Host "StreamReader/StreamWriter処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
# →Get/Set-Contentより高速

# StreamReaderとStreamWriterの処理時間を計測（エンコードあり）
$startTime = Get-Date
$reader = [System.IO.StreamReader]::new($inPath, [System.Text.Encoding]::UTF8)
$writer = [System.IO.StreamWriter]::new($outPath, $false, [System.Text.Encoding]::UTF8)
try {
    while ($null -ne ($line = $reader.ReadLine())) {
        $writer.WriteLine($line)
    }
}
finally {
    $reader.Close()
    $writer.Close()
}
$endTime = Get-Date
Write-Host "StreamReader/StreamWriter（UTF8）処理時間: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
# →Get/Set-Contentより高速

# サンプルファイル削除
Remove-Item -Path $inPath
Remove-Item -Path $outPath
