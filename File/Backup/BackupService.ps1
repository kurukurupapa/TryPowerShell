# バックアップサービスクラス
class BackupService {
  $InPathArr = $null
  $OutHashArr = $null
  hidden $LogName = "BackupLog.txt"
  hidden $LogSep = "-" * 80
  
  BackupService($inPathArr) {
    $this.InPathArr = $inPathArr
  }

  # バックアップ実行
  # $outFolder - バックアップ先フォルダ。バックアップ対象と同じフォルダの場合"."。
  [void] Run($outFolder) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $this.OutHashArr = $this.InPathArr | ForEach-Object {
      $this.GetOutHash($_, $outFolder, $timestamp)
    }
    $this.OutHashArr | ForEach-Object {
      $this.Backup($_)
    }
  }

  # バックアップパスを組み立て
  [Hashtable] hidden GetOutHash($inPath, $outFolder, $timestamp) {
    # 入力パスの整形
    # 末尾が区切り文字なら除去
    $inPath = $inPath -replace "\\+$", ""
    # 分解しておく
    $inDir = Split-Path $inPath -Parent
    $inName = Split-Path $inPath -Leaf

    # 出力パスの組み立て
    $outDir = Join-Path $inDir $outFolder
    if (Test-Path $inPath -PathType container) {
      # フォルダ
      $outName = "${inName}_bk${timestamp}"
    }
    elseif (Test-Path $inPath -PathType leaf) {
      if ($inPath -match "\.[^\.\\]*$") {
        # ファイル・拡張子あり
        $outName = $inName -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
      }
      else {
        # ファイル・拡張子なし
        $outName = "${inName}_bk${timestamp}"
      }
    }
    else {
      throw "対象ファイル/フォルダが見つかりません。${inPath}"
    }
    $outPath = Join-Path $outDir $outName

    return @{
      InPath  = $inPath;
      InDir   = $inDir;
      InName  = $inName;
      OutPath = $outPath;
      OutDir  = $outDir;
      OutName = $outName;
    }
  }

  # バックアップ実行
  [void] hidden Backup($outHash) {
    # コピー先ディレクトリ作成
    if (!(Test-Path $outHash.OutDir -PathType container)) {
      New-Item $outHash.OutDir -ItemType Directory
    }

    # コピー先チェック
    if (Test-Path $outHash.OutPath) {
      throw "バックアップ先パスが存在します。$($outHash.OutPath)"
    }

    # コピー実施
    Copy-Item $outHash.InPath -Destination $outHash.OutPath -Recurse
    Write-Verbose "バックアップしました。$($outHash.OutPath)"
  }
  
  # バックアップ時のコメントを書き込み
  [void] WriteLog($message) {
    $this.OutHashArr | ForEach-Object {
      $logPath = Join-Path $_.OutDir $this.LogName
      $this.LogSep, $_.OutPath, $message | Out-File $logPath -Encoding default -Append
    }
  }
}
