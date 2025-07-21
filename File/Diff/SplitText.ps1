<#
.SYNOPSIS
    テキストファイルを指定した条件で複数のファイルに分割します。

.DESCRIPTION
    このスクリプトは、入力テキストファイルを読み込み、指定された行数または正規表現に一致する行を区切りとして、複数のファイルに分割します。
    分割方法は、行数指定（-LineCount）、または正規表現（-SplitBefore, -SplitAfter）のいずれかを選択します。
    結果は、指定された出力ディレクトリ（デフォルトは入力ファイルと同じディレクトリ）に、元のファイル名に連番を付与した形で保存されます。

.PARAMETER Path
    分割する入力ファイルのパスを指定します。

.PARAMETER LineCount
    このパラメータを指定すると、ファイルを行数で分割します。
    指定した行数ごとに新しいファイルが作成されます。

.PARAMETER SplitBefore
    このパラメータを指定すると、正規表現に一致する行の【前】でファイルを分割します。
    一致した行は、新しいファイルの先頭行になります。

.PARAMETER SplitAfter
    このパラメータを指定すると、正規表現に一致する行の【後】でファイルを分割します。
    一致した行は、現在のファイルの最終行になります。

.PARAMETER OutputDirectory
    分割したファイルを保存するディレクトリのパスを指定します。指定しない場合、入力ファイルと同じディレクトリに出力されます。

.PARAMETER Encoding
    入出力ファイルのエンコーディングを指定します。デフォルトは 'UTF8' です。

.EXAMPLE
    .\File\Diff\SplitText.ps1 -Path 'C:\logs\large_log.txt' -LineCount 100
    'C:\logs\large_log.txt' を100行ずつのファイルに分割し、'C:\logs' ディレクトリに 'large_log_00001.txt', 'large_log_00002.txt'... として保存します。

.EXAMPLE
    .\File\Diff\SplitText.ps1 -Path 'data.csv' -SplitBefore '^HEADER,'
    'data.csv' の中で 'HEADER,' で始まる行を見つけるたびに新しいファイルを開始し、'data.csv' と同じディレクトリに 'data_00001.csv', 'data_00002.csv'... として保存します。

.EXAMPLE
    .\File\Diff\SplitText.ps1 -Path 'C:\logs\app.log' -SplitAfter 'Session End' -OutputDirectory 'C:\logs\output'
    'C:\logs\app.log' の中で 'Session End' という文字列を含む行を見つけるたびにファイルを分割し、結果を 'C:\logs\output' ディレクトリに保存します。

.NOTES
    大きなファイルを効率的に処理するために、.NETのStreamReaderクラスを使用しています。
    これにより、ファイル全体をメモリに読み込むことなく、一行ずつ処理することができます。
    パラメータセット機能により、-LineCount, -SplitBefore, -SplitAfter は同時に指定できません。
#>
[CmdletBinding(DefaultParameterSetName = 'LineCountSet')]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '分割する入力ファイルのパスを指定します。')]
    [string]$Path,

    [Parameter(Mandatory = $true, ParameterSetName = 'LineCountSet', HelpMessage = 'このパラメータを指定すると、ファイルを行数で分割します。')]
    [int]$LineCount,

    [Parameter(Mandatory = $true, ParameterSetName = 'SplitBeforeSet', HelpMessage = '指定した正規表現に一致する行の【前】でファイルを分割します。一致行は新しいファイルの先頭になります。')]
    [string]$SplitBefore,

    [Parameter(Mandatory = $true, ParameterSetName = 'SplitAfterSet', HelpMessage = '指定した正規表現に一致する行の【後】でファイルを分割します。一致行は現在のファイルの末尾になります。')]
    [string]$SplitAfter,

    [Parameter(Mandatory = $false, HelpMessage = "分割したファイルを保存するディレクトリのパスを指定します。指定しない場合、入力ファイルと同じディレクトリに出力されます。")]
    [string]$OutputDirectory,

    [Parameter(Mandatory = $false, HelpMessage = "入出力ファイルのエンコーディングを指定します。デフォルトは 'Default' です。")]
    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)

function Write-SplitFile {
    [CmdletBinding()]
    param(
        [string]$Directory,
        [string]$BaseName,
        [string]$Extension,
        [int]$Index,
        [System.Collections.Generic.List[string]]$Lines,
        [System.Text.Encoding]$EncodingObject
    )
    $fileName = "$($BaseName)_$($Index.ToString('D5'))$($Extension)"
    $outputPath = Join-Path -Path $Directory -ChildPath $fileName
    Write-Verbose "ファイルに書き込み中 ($($Lines.Count) 行): $outputPath"
    [System.IO.File]::WriteAllLines($outputPath, $Lines, $EncodingObject)
}

try {
    # 入力パスを絶対パスに変換して、曖昧さをなくす
    $absolutePath = Resolve-Path -Path $Path -ErrorAction Stop

    # 入力ファイルの存在確認
    if (-not (Test-Path -Path $absolutePath -PathType Leaf)) {
        throw "指定された入力ファイルが見つかりません: $absolutePath"
    }

    $inputFileInfo = Get-Item -Path $absolutePath
    $baseName = $inputFileInfo.BaseName # 拡張子なしのファイル名
    $extension = $inputFileInfo.Extension # 拡張子
    $fileIndex = 1

    # 出力ディレクトリを決定
    $destinationPath = $inputFileInfo.DirectoryName
    if ($PSBoundParameters.ContainsKey('OutputDirectory')) {
        $destinationPath = $OutputDirectory
        # 指定されたパスが存在しない場合は作成
        if (-not (Test-Path -Path $destinationPath -PathType Container)) {
            Write-Verbose "出力ディレクトリを作成します: $destinationPath"
            New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
        }
        # 常に絶対パスで扱う
        $destinationPath = (Resolve-Path -Path $destinationPath).Path
    }

    # 出力用のエンコーディングオブジェクトを決定
    # 'UTF8' はBOMなし、'Default' はシステムの既定（日本語環境では通常Shift_JIS）
    $outputEncodingObject = switch ($Encoding) {
        'UTF8' { New-Object System.Text.UTF8Encoding($false) } # BOMなし
        'Default' { [System.Text.Encoding]::Default }
    }

    # 読み込み用のエンコーディングオブジェクトを決定
    # [System.Text.Encoding]::UTF8 はBOMを自動判別するため、BOMの有無を意識する必要はない
    $readEncodingObject = switch ($Encoding) {
        'UTF8' { [System.Text.Encoding]::UTF8 }
        'Default' { [System.Text.Encoding]::Default }
    }

    Write-Verbose "ファイルの読み込みを開始します: $absolutePath (出力先: $destinationPath)"
    $reader = [System.IO.StreamReader]::new($absolutePath, $readEncodingObject)

    try {
        $lineBuffer = New-Object System.Collections.Generic.List[string]

        while ($null -ne ($line = $reader.ReadLine())) {
            # --- 分割判定 (現在の行をバッファに追加する前) ---
            $splitBeforeAdd = $false
            if ($PSCmdlet.ParameterSetName -eq 'LineCountSet') {
                if ($lineBuffer.Count -gt 0 -and $lineBuffer.Count % $LineCount -eq 0) {
                    $splitBeforeAdd = $true
                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'SplitBeforeSet') {
                if ($lineBuffer.Count -gt 0 -and $line -match $SplitBefore) {
                    $splitBeforeAdd = $true
                }
            }

            if ($splitBeforeAdd) {
                Write-SplitFile -Directory $destinationPath -BaseName $baseName -Extension $extension -Index $fileIndex -Lines $lineBuffer -EncodingObject $outputEncodingObject
                $lineBuffer.Clear()
                $fileIndex++
            }

            # --- 現在の行をバッファに追加 ---
            $lineBuffer.Add($line)

            # --- 分割判定 (現在の行をバッファに追加した後) ---
            $splitAfterAdd = $false
            if ($PSCmdlet.ParameterSetName -eq 'SplitAfterSet') {
                if ($line -match $SplitAfter) {
                    $splitAfterAdd = $true
                }
            }

            if ($splitAfterAdd) {
                Write-SplitFile -Directory $destinationPath -BaseName $baseName -Extension $extension -Index $fileIndex -Lines $lineBuffer -EncodingObject $outputEncodingObject
                $lineBuffer.Clear()
                $fileIndex++
            }
        }

        # バッファに残った最後の行を書き出す
        if ($lineBuffer.Count -gt 0) {
            Write-SplitFile -Directory $destinationPath -BaseName $baseName -Extension $extension -Index $fileIndex -Lines $lineBuffer -EncodingObject $outputEncodingObject
        }
    }
    finally {
        if ($reader) { $reader.Dispose() }
    }

    Write-Host "ファイルの分割が完了しました。"
}
catch {
    Write-Error "エラーが発生しました: $_"
}
