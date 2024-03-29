<#
.SYNOPSIS
ファイルやフォルダをバックアップします。

.DESCRIPTION
このスクリプトは、ファイルやフォルダを、コピーし、名前にタイムスタンプを付けます。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
BackupForm.ps1 D:\tmp\dummy.txt
BackupForm.ps1 D:\tmp
#>

[CmdletBinding()]
param (
  [Parameter(ValueFromRemainingArguments)]
  [string[]]$PathArr
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $psDir "BackupService.ps1")

# ヘルプ
if (!$PathArr) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# フォーム
$form = New-Object System.Windows.Forms.Form -Property @{
  Text    = $psBaseName
  Width   = 480
  Height  = 320
  Padding = New-Object System.Windows.Forms.Padding(10)
  StartPosition = "CenterScreen"
}

# テキストボックス
# Fill設定にするので、最初に登録する。
$form.Controls.Add(($textBox = New-Object System.Windows.Forms.TextBox -Property @{
      AutoSize  = $false # テキストボックス自身によるサイズ調整をOFF
      Multiline = $true
      Dock      = [System.Windows.Forms.DockStyle]::Fill
    }))

# ラベル
# ※Top設定は後勝ち。当ラベルは上から2番目に表示。
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
      Text     = "コメント入力"
      AutoSize = $true
      Dock     = [System.Windows.Forms.DockStyle]::Top
      Padding  = New-Object System.Windows.Forms.Padding(0, 5, 0, 0)
    }))

# ラベル
# ※Top設定は後勝ち。当ラベルは上から1番目に表示。
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
      Text     = $PathArr -join "`n"
      AutoSize = $true
      Dock     = [System.Windows.Forms.DockStyle]::Top
      # Padding  = New-Object System.Windows.Forms.Padding(5)
    }))

# バックアップ先フォルダ選択ラベル
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
      Text     = "バックアップ先フォルダ"
      AutoSize = $true
      Dock     = [System.Windows.Forms.DockStyle]::Bottom
      Padding  = New-Object System.Windows.Forms.Padding(0, 10, 0, 0)
    }))

# バックアップ先フォルダ選択ラジオボタン
# TODO backup,bak,bkフォルダの有無に従って初期選択を変えたい。
$folderArr = @(
  @{Text = "同一フォルダ"; Folder = "."; Checked = $true },
  @{Text = "backupフォルダ"; Folder = "backup"; Checked = $false },
  @{Text = "bakフォルダ"; Folder = "bak"; Checked = $false },
  @{Text = "bkフォルダ"; Folder = "bk"; Checked = $false }
)
$folderArr | ForEach-Object {
  $_.RadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
    Text     = $_.Text
    Checked  = $_.Checked
    AutoSize = $true
    Dock     = [System.Windows.Forms.DockStyle]::Bottom
  }
  if ($_.Text -eq $folderArr[-1].Text) {
    $_.RadioButton.Padding = New-Object System.Windows.Forms.Padding(0, 0, 0, 10)
  }
  $form.Controls.Add($_.RadioButton)
}

# ボタン
$form.Controls.Add(($button = New-Object System.Windows.Forms.Button -Property @{
      Text     = "バックアップ"
      AutoSize = $true
      Dock     = [System.Windows.Forms.DockStyle]::Bottom
      Padding  = New-Object System.Windows.Forms.Padding(5)
    }))
$button.Add_Click({
    # バックアップ先フォルダを取得
    $folder = $null
    $folderArr | ForEach-Object {
      if ($_.RadioButton.Checked) {
        $folder = $_.Folder
      }
    }

    # バックアップ実施
    # New-Objectの場合、配列の要素数分の引数として扱われてエラーになった。
    # $service = New-Object BackupService($PathArr)
    $service = [BackupService]::new($PathArr)
    $service.Run($folder)
    $message = $textBox.Text.Trim()
    if ($message) {
      $service.WriteLog($message)
    }

    # フォームを閉じる
    $form.Close()
  })

# 表示
$form.ShowDialog() | Out-Null

# 後処理
$form.Dispose()
