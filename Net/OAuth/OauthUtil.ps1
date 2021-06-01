# OAuth 1.0a/2.0 処理用ユーティリティ関数

$OAUTH1A_USER_AGENT = "PsOauth1aClient"
$OAUTH1A_VERIFIER_MSG = "完了画面に表示されたトークン、または完了画面/遷移エラー画面のURLから oauth_verifier の値を入力してください。"

$OAUTH2_USER_AGENT = "PsOauth2Client"
$OAUTH2_CODE_MSG = "完了画面に表示されたコード、または完了/遷移エラー画面のURLからcodeの値を入力してください。"

function Read-UserInput($Message, $Dialog) {
  $str = $null
  if (!$Dialog) {
    # ※コピペで文字列を貼り付けたときに、時々、文字が欠けるので注意。
    $str = Read-Host $Message
  } else {
    $str = Show-InputDialog $Message
  }
  $str = $str.Trim()
  if (!$str) {
    throw "ERROR: invalid user input, [$str]"
  }
  return $str
}

function Show-InputDialog($Message, $Title) {
  Add-Type -AssemblyName System.Windows.Forms
  $form = New-Object System.Windows.Forms.Form -Property @{
    Text = $Title
    Width = 300
    Height = 200
  }
  $form.Controls.Add(($textBox = New-Object System.Windows.Forms.TextBox -Property @{
    AutoSize = $false
    Dock = [System.Windows.Forms.DockStyle]::Fill
  }))
  $form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = $Message
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
function ConvertTo-WrappedHttpBody($Hash, $ContentType='application/x-www-form-urlencoded') {
  $body = $null
  if ($ContentType -eq 'application/x-www-form-urlencoded') {
    $body = @{Value=$Hash}
  } elseif ($ContentType -match 'application/json') {
    $str = $Hash | ConvertTo-Json -Depth 100
    $body = @{Value=[System.Text.Encoding]::UTF8.GetBytes($str)}
  } else {
    throw "ERROR: invalid ContentType, $ContentType"
  }
  return $body
}

# HTTPアクセスエラー時のエラー情報を表示
function Write-WebException($Ex) {
  try {
    Write-Host $Ex
    Write-Host "$($Ex.Exception.Status.value__) $($Ex.Exception.Status.ToString())"
    $stream = $Ex.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader $stream
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    Write-Host $reader.ReadToEnd()
    $stream.Close()
  } catch {
    Write-Host "WARN: Write-WebException, $_"
  }
}

# 簡易的にデータを暗号化ファイルとして保存/読み込みできるようにした。（あまり良くない実装かもしれない）
function Export-OauthClientInfo($Path, $ClientInfo) {
  $jsonStr = ConvertTo-Json $ClientInfo -Compress
  ConvertTo-SecureString $jsonStr -AsPlainText -Force | ConvertFrom-SecureString | Set-Content $Path
  Write-Verbose "Saved $Path"
}
function Import-OauthClientInfo($Path) {
  $ss = Get-Content $Path | ConvertTo-SecureString
  $jsonStr = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss))
  $jsonObj = ConvertFrom-Json $jsonStr

  # PSCustomObject を Hashtable へ変換
  $jsonHash = @{}
  $jsonObj.psobject.properties | ForEach-Object {
    $jsonHash[$_.Name] = $_.Value
  }

  Write-Verbose "Loaded $Path"
  return $jsonHash
}
function New-Oauth2ClientInfo($ClientId, $ClientSecret, $RedirectUri) {
  return @{
    ClientId = $ClientId
    ClientSecret = $ClientSecret
    RedirectUri = $RedirectUri
  }
}
function New-Oauth1aClientInfo($ConsumerKey, $ConsumerSecret, $RequestUrl, $AuthUrl, $AccessUrl, $CallbackUrl) {
  return @{
    ConsumerKey = $ConsumerKey
    ConsumerSecret = $ConsumerSecret
    RequestUrl = $RequestUrl
    AuthUrl = $AuthUrl
    AccessUrl = $AccessUrl
    CallbackUrl = $CallbackUrl
  }
}
function Add-Oauth2ClientInfo($ClientInfo, $Response) {
  return Add-Oauth1aClientInfo $ClientInfo $Response
}
function Add-Oauth1aClientInfo($ClientInfo, $Response) {
  $items = $null
  if ($Response -is [PSCustomObject]) {
    $items = $Response.psobject.properties
  } else {
    $items = $Response.GetEnumerator()
  }
  $items | ForEach-Object {
    $name = ConvertTo-UpperCamelCase $_.Name
    $ClientInfo[$name] = $_.Value
  }
  return $ClientInfo
}

function ConvertTo-UpperCamelCase($SnakeCase) {
  $str = ([regex]"^([a-z])").Replace($SnakeCase, {$args[0].Groups[1].Value.ToUpper()})
  return ([regex]"_([a-z])").Replace($str, {$args[0].Groups[1].Value.ToUpper()})
}

function ConvertTo-LowerCamelCase($SnakeCase) {
  return ([regex]"_([a-z])").Replace($SnakeCase, {$args[0].Groups[1].Value.ToUpper()})
}

function Write-ObjectDebug($Name, $Obj) {
  $value = "null"
  if ($Obj) {
    $value = $Obj.GetType().FullName
    if ($Obj -is [byte[]]) {
      $value += ", Length=" + $Obj.Length
    } else {
      $value += ", " + ($Obj | ConvertTo-Json)
    }
  }
  Write-Debug "$Name : $value"
}
