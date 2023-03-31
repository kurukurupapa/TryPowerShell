# バックアップサービスクラス
class BackupService {
  $inDir
  $inName
  $inPath
  $outDir
  $outName
  $outPath
  $logName = "BackupLog.txt"
  $logSep = "-" * 80
  
  BackupService($inPath) {
    # 末尾が区切り文字なら除去
    $this.inPath = $inPath -replace "\\+$", ""
    # 分解しておく
    $this.inDir = Split-Path $this.inPath -Parent
    $this.inName = Split-Path $this.inPath -Leaf
  }

  # バックアップパスを組み立て
  # $folder - バックアップ先フォルダ。バックアップ対象と同じフォルダの場合"."。
  [void] MakeOutPath($folder) {
    $this.outDir = Join-Path $this.inDir $folder
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    if (Test-Path $this.inPath -PathType container) {
      # フォルダ
      $this.outName = "$($this.inName)_bk${timestamp}"
    }
    elseif (Test-Path $this.inPath -PathType leaf) {
      if ($this.inPath -match "\.[^\.\\]*$") {
        # ファイル・拡張子あり
        # $outpath = $path -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
        $this.outName = $this.inName -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
      }
      else {
        # ファイル・拡張子なし
        # $outpath = $path + "_bk${timestamp}"
        $this.outName = "$($this.inName)_bk${timestamp}"
      }
    }
    else {
      throw "対象ファイル/フォルダが見つかりません。$($this.inPath)"
    }
    $this.outPath = Join-Path $this.outDir $this.outName
  }

  # バックアップ実行
  [void] Backup() {
    # コピー先ディレクトリ作成
    if (!(Test-Path $this.outDir -PathType container)) {
      New-Item $this.outDir -ItemType Directory
    }

    # コピー先チェック
    if (Test-Path $this.outPath) {
      throw "バックアップ先パスが存在します。$($this.outPath)"
    }

    # コピー実施
    Copy-Item $this.inPath -Destination $this.outPath -Recurse
    Write-Verbose "バックアップしました。$($this.outPath)"
  }
  
  # バックアップ時のコメントを書き込み
  [void] WriteLog($message) {
    $logPath = Join-Path $this.outDir $this.logName
    $this.logSep, $this.outPath, $message | Out-File $logPath -Encoding default -Append
  }
}
