# ユーティリティ関数

function ReadUserInput($message, $dialog) {
  $str = $null
  if (!$dialog) {
    $str = Read-Host $message
    # ※accessToken貼り付けたときに、時々、文字が欠けるので注意。
  } else {
    $str = ShowInputDialog $message
  }
  return $str
}

function ShowInputDialog($message, $title) {
  Add-Type -AssemblyName System.Windows.Forms
  $form = New-Object System.Windows.Forms.Form -Property @{
    Text = $title
    Width = 300
    Height = 200
  }
  $form.Controls.Add(($textBox = New-Object System.Windows.Forms.TextBox -Property @{
    AutoSize = $false
    Dock = [System.Windows.Forms.DockStyle]::Fill
  }))
  $form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = $message
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
  $form.ShowDialog() | Out-Null
  $form.Dispose()
  return $form.Tag
}

<#
.SYNOPSIS
  HTTPボディのハッシュを Content-Type に従って変換
.OUTPUTS
  Content-Type が application/json の場合に、byte[]を返却したいが、PowerShellのfunctionの仕様で、Object[]に変換されてしまうため、ハッシュで返却。
#>
function ConvToWrappedBody($params, $contentType='application/x-www-form-urlencoded') {
  $body = $null
  if ($contentType -eq 'application/x-www-form-urlencoded') {
    $body = @{value=$params}
  } elseif ($contentType -match 'application/json') {
    # $body = $params | ConvertTo-Json -Depth 100
    $body = ConvToWrappedJsonBody $params
  } else {
    throw "ERROR: invalid contentType, $contentType"
  }
  return $body
}

<#
.SYNOPSIS
  HTTPボディのハッシュをJSON文字列のバイト配列に変換
.OUTPUTS
  byte[]を返却したいが、PowerShellのfunctionの仕様で、Object[]に変換されてしまうため、ハッシュで返却。
#>
function ConvToWrappedJsonBody($params) {
  $jsonStr = $params | ConvertTo-Json -Depth 100
  return @{value=[System.Text.Encoding]::UTF8.GetBytes($jsonStr)}
}

# HTTPアクセスエラー時のエラー情報を表示
function PrintWebException($e) {
  try {
    Write-Host $e
    Write-Host "$($e.Exception.Status.value__) $($e.Exception.Status.ToString())"
    $stream = $e.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader $stream
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    Write-Host $reader.ReadToEnd()
    $stream.Close()
  } catch {
    Write-Host "PrintWebException ERROR: $_"
  }
}

# 簡易的にデータを暗号化ファイルとして保存/読み込みできるようにした。（あまり良くない実装かもしれない）
function SaveSecretObject($path, $obj) {
  $jsonStr = ConvertTo-Json $obj -Compress
  ConvertTo-SecureString $jsonStr -AsPlainText -Force | ConvertFrom-SecureString | Set-Content $path
  Write-Verbose "Saved $path"
}
function LoadSecretObject($path) {
  $ss = Get-Content $path | ConvertTo-SecureString
  $jsonStr = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss))
  $jsonObj = ConvertFrom-Json $jsonStr
  Write-Verbose "Loaded $path"
  return $jsonObj
}

function ToCamelCase($snakeCase) {
  return ([regex]"_([a-z])").Replace($snakeCase, {$args[0].Groups[1].Value.ToUpper()})
}
