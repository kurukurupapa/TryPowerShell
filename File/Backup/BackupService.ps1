# バックアップパスクラス
class BackupPath {
  $InPath = $null
  $InDir = $null
  $InName = $null
  $OutPath = $null
  $OutDir = $null
  $OutName = $null

  BackupPath($inPath) {
    # 末尾が区切り文字なら除去
    $this.InPath = $inPath -replace "\\+$", ""
    # 分解しておく
    $this.InDir = Split-Path $this.InPath -Parent
    $this.InName = Split-Path $this.InPath -Leaf
  }

  # バックアップ実行
  # $folder - バックアップ先フォルダ。バックアップ対象と同じフォルダの場合"."。
  [void] Backup($folder) {
    $this.MakeOutPath($folder)

    # コピー先ディレクトリ作成
    if (!(Test-Path $this.OutDir -PathType container)) {
      New-Item $this.OutDir -ItemType Directory
    }

    # コピー先チェック
    if (Test-Path $this.OutPath) {
      throw "バックアップ先パスが存在します。$($this.OutPath)"
    }

    # コピー実施
    Copy-Item $this.InPath -Destination $this.OutPath -Recurse
    Write-Verbose "バックアップしました。$($this.OutPath)"
  }

  # バックアップパスを組み立て
  [void] hidden MakeOutPath($folder) {
    # 出力パスの組み立て
    $this.OutDir = Join-Path $this.InDir $folder
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    if (Test-Path $this.InPath -PathType container) {
      # フォルダ
      $this.OutName = "$($this.InName)_bk${timestamp}"
    }
    elseif (Test-Path $this.InPath -PathType leaf) {
      if ($this.InPath -match "\.[^\.\\]*$") {
        # ファイル・拡張子あり
        $this.OutName = $this.InName -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
      }
      else {
        # ファイル・拡張子なし
        $this.OutName = "$($this.InName)_bk${timestamp}"
      }
    }
    else {
      throw "対象ファイル/フォルダが見つかりません。$($this.InPath)"
    }
    $this.OutPath = Join-Path $this.OutDir $this.OutName
  }
}

# バックアップサービスクラス
class BackupService {
  $BackupPathArr = $null
  hidden $LogName = "BackupLog.txt"
  hidden $LogSep = "-" * 80
  
  BackupService($inPathArr) {
    $this.BackupPathArr = $inPathArr | ForEach-Object {
      [BackupPath]::new($_)
    }
  }

  # バックアップ実行
  # $outFolder - バックアップ先フォルダ。バックアップ対象と同じフォルダの場合"."。
  [void] Run($outFolder) {
    $this.BackupPathArr | ForEach-Object {
      $_.Backup($outFolder)
    }
  }

  # バックアップ時のコメントを書き込み
  [void] WriteLog($message) {
    # 出力ディレクトリの種類ごとにログを書き込む
    $this.BackupPathArr | ForEach-Object { $_.OutDir } | Sort-Object -Unique | ForEach-Object {
      # 当該ループの出力ディレクトリ
      $outDir = $_
      # 同一出力ディレクトリの出力パス一覧
      $arr = $this.BackupPathArr | ForEach-Object {
        if ($_.OutDir -eq $outDir) {
          $_.OutPath
        }
      } | Sort-Object
      # ログを書き込み
      $logPath = Join-Path $outDir $this.LogName
      $logMessage = @()
      $logMessage += $this.LogSep
      $logMessage += $arr
      $logMessage += $message
      $logMessage | Out-File $logPath -Encoding default -Append
      Write-Verbose "ログを書き込みました。${logPath}"
    }
  }
}
