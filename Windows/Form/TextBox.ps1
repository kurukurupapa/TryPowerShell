<#
.SYNOPSIS
フォームにテキストボックスとボタンを表示するPowerShellスクリプトです。

.DESCRIPTION
フォームにテキストボックスとボタンを表示するPowerShellスクリプトです。
なお、New-Objectでは、-Propertyeで、生成するオブジェクトのプロパティに対して初期値を与えられるということなので、使ってみました。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
TextBox.ps1
#>
Add-Type -AssemblyName System.Windows.Forms

# フォーム作成
$form = New-Object System.Windows.Forms.Form -Property @{
  Text = "サンプルフォーム"
  Width = 300
  Height = 200
}
$form.Controls.Add(($textBox = New-Object System.Windows.Forms.TextBox -Property @{
  AutoSize = $false # テキストボックス自身によるサイズ調整をOFF
  Multiline = $true
  Dock = [System.Windows.Forms.DockStyle]::Fill
}))
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
  Text = "お好きな文字列を入力してください。"
  Dock = [System.Windows.Forms.DockStyle]::Top
}))
$form.Controls.Add(($button = New-Object System.Windows.Forms.Button -Property @{
  Text = "OK"
  Dock = [System.Windows.Forms.DockStyle]::Bottom
}))
$button.Add_Click({
  $form.Tag = $textBox.Text
  $form.Close()
})

# 表示
$form.ShowDialog() | Out-Null
Write-Output $form.Tag

# 後処理
$form.Dispose()
