<#
.SYNOPSIS
簡単なフォームを表示するPowerShellスクリプトです。

.DESCRIPTION
簡単なフォームを表示するPowerShellスクリプトです。
次の例では、3つのボタンが縦に並んだフォームを表示し、ボタンが押されると、押されたボタンの番号を $form.Tag へ保存し、フォームを閉じます。
参考
・[Form クラス (System.Windows.Forms) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.form)
・[コントロールのレイアウト オプション - Windows Forms .NET | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout)
・[Button クラス (System.Windows.Forms) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.button)

エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
SimpleForm.ps1
#>
Add-Type -AssemblyName System.Windows.Forms

# フォーム作成
$form = New-Object System.Windows.Forms.Form
$form.AutoSize = $true
$form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Text = "サンプルフォーム"

# レイアウトパネル
$layout = New-Object System.Windows.Forms.FlowLayoutPanel
$layout.AutoSize = $true
$layout.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$layout.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$form.Controls.Add($layout)

# ボタン
$button = @()
for ($i = 0; $i -lt 3; $i++) {
  $button += New-Object System.Windows.Forms.Button
  $button[$i].AutoSize = $true
  $button[$i].AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
  $button[$i].Tag = $i
  $button[$i].Text = "サンプルフォームのサンプルボタン $($i + 1)"
  $button[$i].Add_Click({
    # 当メソッド外からデータ取得
    # 案1
    param($sender, $eventArgs)
    Write-Host "Add_Click メソッド外からデータ取得 案1: $($sender.Tag)"
    $dummy = "Click! $($sender.Tag) $(Get-Date)"
    $sender.Text = $dummy
    # 案2
    Write-Host "Add_Click メソッド外からデータ取得 案2: $($this.Tag)"

    # フォーム呼び出し元へデータ返却
    # 案1
    $global:formResult = $sender.Tag
    # 案2
    $form.Tag = $sender.Tag

    # フォームを閉じる
    $form.Close()
  })
  $layout.Controls.Add($button[$i])
}

# 表示
$form.ShowDialog() | Out-Null

# フォームからデータ取得
Write-Output "フォームからデータ取得 案1: $($global:formResult)"
Write-Output "フォームからデータ取得 案2: $($form.Tag)"

# 片付け
$form.Dispose()
