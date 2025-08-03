# �t�@�C�����o�͂̏������Ԃ𒲂ׂĂ݂�
# Lang/IO/Test.ps1

$inPath = ".\Lang\IO\sample.txt"
$outPath = ".\Lang\IO\tmp.txt"

# �T���v���t�@�C���쐬
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

# Get-Content/Set-Content�̏������Ԃ��v��
$startTime = Get-Date
$lines = Get-Content $inPath
Set-Content $outPath -Value $lines
$endTime = Get-Date
Write-Host "Get/Set-Content�i�p�C�v���C���Ȃ��j��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

$startTime = Get-Date
Get-Content $inPath | Set-Content $outPath
$endTime = Get-Date
Write-Host "Get/Set-Content�i�p�C�v���C���j��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

# Get-Content/Set-Content�̏������Ԃ��v���i�G���R�[�h����j
$startTime = Get-Date
Get-Content $inPath -Encoding UTF8 | Set-Content $outPath -Encoding UTF8
$endTime = Get-Date
Write-Host "Get/Set-Content�iUTF8�I�v�V��������iBOM�t��UTF8�j�j��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

$startTime = Get-Date
Get-Content $inPath |
ForEach-Object { [Text.Encoding]::UTF8.GetBytes($_ + "`r`n") } |
Set-Content $outPath -Encoding Byte
$endTime = Get-Date
Write-Host "Get/Set-Content�iUTF8�ϊ��iBOM�Ȃ�UTF8�j�j��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
# �����Ȃ�x���B

# Import-Csv/Export-Csv�̏������Ԃ��v��
$startTime = Get-Date
Import-Csv $inPath | Export-Csv $outPath -NoTypeInformation
$endTime = Get-Date
Write-Host "Import/Export-Csv��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
# ��Get/Set-Content�Ɣ�r���āA�����Ԓx���B

# �p�C�v���C���ł̏������Ԃ��v��
$startTime = Get-Date
$lines | ForEach-Object { $_ } | Out-Null
$endTime = Get-Date
Write-Host "�p�C�v���C��2�� ��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
$startTime = Get-Date
$lines | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | ForEach-Object { $_ } | Out-Null
$endTime = Get-Date
Write-Host "�p�C�v���C��10�� ��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

# ������u���̏������Ԃ��v��
$startTime = Get-Date
$lines | ForEach-Object { $_ -replace 'A', 'a' } | Out-Null
$endTime = Get-Date
Write-Host "�p�C�v���C��2���{������u��1�� ��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
$startTime = Get-Date
$lines | ForEach-Object { (((((($_ -replace 'A', 'a') -replace 'B', 'b') -replace 'C', 'c') -replace 'D', 'd') -replace 'E', 'e') -replace 'F', 'f') } | Out-Null
$endTime = Get-Date
Write-Host "�p�C�v���C��2���{������u��5�� ��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"

# StreamReader��StreamWriter�̏������Ԃ��v��
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
Write-Host "StreamReader/StreamWriter��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
# ��Get/Set-Content��荂��

# StreamReader��StreamWriter�̏������Ԃ��v���i�G���R�[�h����j
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
Write-Host "StreamReader/StreamWriter�iUTF8�j��������: $(($endTime - $startTime).ToString("hh\:mm\:ss\.fff"))"
# ��Get/Set-Content��荂��

# �T���v���t�@�C���폜
Remove-Item -Path $inPath
Remove-Item -Path $outPath
