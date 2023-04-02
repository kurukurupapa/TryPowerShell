<#
.SYNOPSIS
フォームにラジオボタンを表示するPowerShellスクリプトです。

.DESCRIPTION
フォームにラジオボタンを表示するPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
RadioButton.ps1
#>
Add-Type -AssemblyName System.Windows.Forms

# フォーム作成
$form = New-Object System.Windows.Forms.Form -Property @{
  Text     = "サンプルフォーム"
  Width    = 300
  Height   = 200
  AutoSize = $true
  Padding  = New-Object System.Windows.Forms.Padding(10)
}
$layout = New-Object System.Windows.Forms.FlowLayoutPanel -Property @{
  FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
  AutoSize      = $true
  Dock          = [System.Windows.Forms.DockStyle]::Fill
  # BackColor     = [System.Drawing.Color]::SkyBlue
}
$form.Controls.Add($layout)

# ラジオボタン
$radioButton1 = New-Object System.Windows.Forms.RadioButton
$radioButton1.Text = "ラジオボタン1"
$radioButton1.AutoSize = $true
$layout.Controls.Add($radioButton1)
$radioButton2 = New-Object System.Windows.Forms.RadioButton
$radioButton2.Text = "ラジオボタン2"
$radioButton2.AutoSize = $true
$layout.Controls.Add($radioButton2)
$radioButton3 = New-Object System.Windows.Forms.RadioButton
$radioButton3.Text = "ラジオボタン3"
$radioButton3.AutoSize = $true
$layout.Controls.Add($radioButton3)

# ラジオボタン（グループボックスあり）
# グループボックスのサイズ調整について
# ・AutoSize=$true, Anchor設定を試してみたけど自動的に調整することができなかった。
# ・Size(Width,Height)を明示的に設定した。
$layout.Controls.Add(($groupBox = New-Object System.Windows.Forms.GroupBox -Property @{
      Text = "くだものグループ"
      # AutoSize = $true
      # Size     = New-Object System.Drawing.Size(500, 50)
      # Anchor   = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
      # Anchor   = @('Left', 'Right')
    }))
$radioButtons2 = @(
  @{Text = "AppleAppleApple"; Checked = $false },
  @{Text = "Banana"; Checked = $true },
  @{Text = "Cherry"; Checked = $false }
)
$radioButtons2 | ForEach-Object {
  $groupBox.Controls.Add(($_.RadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = $_.Text
        Checked  = $_.Checked
        AutoSize = $true
        # 後に登録したものが、より上になる。
        Dock     = [System.Windows.Forms.DockStyle]::Top
      }))
}
$groupBox.Width = $radioButtons2[0].RadioButton.Width
$groupBox.Height = $radioButtons2[0].RadioButton.Height * ($radioButtons2.Count + 1)

# ボタン
$layout.Controls.Add(($button = New-Object System.Windows.Forms.Button -Property @{
      Text = "状態確認"
    }))
$button.Add_Click({
    Write-Host "ラジオボタン1-1 $($radioButton1.Checked)"
    Write-Host "ラジオボタン1-2 $($radioButton2.Checked)"
    Write-Host "ラジオボタン1-3 $($radioButton3.Checked)"
    for ($i = 0; $i -lt $radioButtons2.Length; $i++) {
      Write-Host "ラジオボタン2-$($i+1) $($radioButtons2[$i].RadioButton.Checked)"
    }
  })

# 表示
$form.ShowDialog() | Out-Null

# 後処理
$form.Dispose()
