# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# �E�A�N�Z�X�g�[�N���̗L��������Ď擾���l�����Ă��܂���B
# �Q�l
# [OAuth Core 1.0a](https://oauth.net/core/1.0a/#sig_base_example)
# [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# Signature Base String ���擾
function GetSignatureBaseString($method, $url, $params) {
  $arr = $params.GetEnumerator() | sort Name | %{
    # $_.Name + '=' + $_.Value
    [Uri]::EscapeDataString($_.Name) + '=' + [Uri]::EscapeDataString($_.Value)
  }
  $signatureBaseString = $method.ToUpper() + '&' + [Uri]::EscapeDataString($url.ToLower()) + '&' + [Uri]::EscapeDataString($arr -join '&')
  Write-Debug ("SignatureBaseString: " + $signatureBaseString -replace ('&',"&`n  ") -replace ('%26',"%26`n  "))
  return $signatureBaseString
}
# GetSignatureBaseString "POST" "https://sample.com" @{a="1";b="2";c="A B"}

# oauth_signature���擾
function GetSignature($signatureBaseString, $consumerSecret, $tokenSecret) {
  # $key = $consumerSecret + '&' + $tokenSecret
  $key = [Uri]::EscapeDataString($consumerSecret) + '&' + [Uri]::EscapeDataString($tokenSecret)
  $hmacsha1 = New-Object System.Security.Cryptography.HMACSHA1
  $hmacsha1.Key = [System.Text.Encoding]::ASCII.GetBytes($key)
  $signature = [System.Convert]::ToBase64String($hmacsha1.ComputeHash(
    [System.Text.Encoding]::ASCII.GetBytes($signatureBaseString)))
  Write-Debug "Signature: $signature, Key: $key"
  return $signature
}
# GetSignature "abc" "def" "ghi"

# Authorization�w�b�_�[���擾
function GetAuthorizationHeader($params, $signature) {
  $params['oauth_signature'] = $signature
  $arr = $params.GetEnumerator() | sort Name | %{
    [Uri]::EscapeDataString($_.Name) + '="' + [Uri]::EscapeDataString($_.Value) + '"'
  }
  $result = "OAuth " + ($arr -join ",")
  Write-Debug ("Authorization header: " + $result -replace (',',",`n  "))
  return $result
}
# GetAuthorization @{a="1";b="2"} "abc"

# ���X�|���X�����
function ParseOauthResponse($responseStr) {
  Write-Debug "Response: $responseStr"
  $hash = @{}
  $responseStr.Split('&') | %{
    $name, $value = $_.Split('=')
    $hash[[Uri]::UnescapeDataString($name)] = [Uri]::UnescapeDataString($value)
  }
  return $hash
}
# ParseOauthResponse "oauth_token=aaa&oauth_token_secret=bbb&oauth_callback_confirmed=true"

# HTTP�A�N�Z�X�G���[���̃G���[����\��
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

# OAuth1.0a��API�Ăяo�������s
# ������ $token, $tokenSecret, $verifier, $callback, $authParams, $bodyParams, $queryParams �́A�K�v�ɉ����Đݒ肷��B
# $callback, $authParams �́AAuthorization�w�b�_�[��oauth_signature�̌v�Z�Ɋ܂߂�B
# $bodyParams �́AGET�p�����[�^�܂���POST�f�[�^�ƂȂ�B
# $queryParams �́A��{�g�p���Ȃ����A���N�G�X�g���\�b�h�ɂ�炸�AURL�ɃN�G���������ݒ肵�����Ƃ��Ɏg�p����B
# ���N�G�X�g�g�[�N���擾���́A$token, $tokenSecret, $verifier �Ȃ��A�K�v�ɉ����� $callback ��ݒ肷��B
# �A�N�Z�X�g�[�N���擾���́A$token, $tokenSecret �Ƀ��N�G�X�g�g�[�N���擾���ʂ�ݒ肵�A$verifier �Ƀ��[�U�F���ʂ�ݒ肷��B
# ���\�[�XAPI�Ăяo�����́A$token, $tokenSecret �ɃA�N�Z�X�g�[�N���擾���ʂ�ݒ肵�A�K�v�ɉ����� $authParams, $bodyParams, $queryParams ��ݒ肷��B
function InvokeOauthApi($method, $url, $consumerKey, $consumerSecret,
  $token, $tokenSecret, $verifier, $callback, $authParams, $bodyParams, $queryParams,
  $signatureMethod='HMAC-SHA1') {

  # oauth_nonce�́A��ӂȒl�ł���΂悢�̂ŁA�Ƃ肠�����^�C���X�^���v����쐬����B
  $timestamp = [int]((Get-Date) - [Datetime]"1970/1/1 00:00:00 GMT").TotalSeconds
  $nonce = "NONCE" + $timestamp
  # oauth_token���l�Ȃ��̏ꍇ�AZaimAPI�œ���m�F�����Ƃ���A���ږ�����Ńu�����N�ioauth_token=�j�ł��A���ږ����ƂȂ��ł����v�������B
  $params = @{
    "oauth_consumer_key" = $consumerKey
    "oauth_nonce" = $nonce
    "oauth_signature_method" = $signatureMethod
    "oauth_timestamp" = $timestamp
    "oauth_version" = "1.0"
  }
  if ($token) {
    $params["oauth_token"] = $token
  }
  if ($verifier) {
    $params['oauth_verifier'] = $verifier
  }
  if ($callback) {
    $params['oauth_callback'] = $callback
  }
  if ($authParams) {
    $params += $authParams
  }
  $allParams = $params.Clone()
  if ($bodyParams) {
    $allParams += $bodyParams
  }
  if ($queryParams) {
    $allParams += $queryParams
  }
  $signatureBaseString = GetSignatureBaseString $method $url $allParams
  $signature = GetSignature $signatureBaseString $consumerSecret $tokenSecret
  $authorizationHeader = GetAuthorizationHeader $params $signature

  if ($queryParams) {
    $arr = $queryParams.GetEnumerator() | sort Name | %{
      [System.Web.HttpUtility]::UrlEncode($_.Name) + '=' + [System.Web.HttpUtility]::UrlEncode($_.Value)
    }
    $sep = '?'
    if ($url -match "\?") {
      $sep = '&'
    }
    $url += $sep + ($arr -join '&')
  }

  try {
    $headers = @{
      Authorization = $authorizationHeader
      'User-Agent' = "PsOauth1aClient"
    }
    if ($method -eq 'POST') {
      $headers['Content-Type'] = 'application/x-www-form-urlencoded'
    }
    return Invoke-RestMethod $url -Method $method -Headers $headers -Body $bodyParams
  } catch {
    PrintWebException $_
    throw $_
  }
}
# InvokeOauthApi 'DELETE' "https://kurukurupapap.com/oauth1a" "consumerKey" "consumerSecret" "callback" -queryParams @{q1=1;q2="abc";"symbol!#"="$%< >+*"}
# InvokeOauthApi 'DELETE' "https://kurukurupapap.com/oauth1a?a=1" "consumerKey" "consumerSecret" "callback" -queryParams @{q1=1;q2="abc";"symbol!#"="$%< >+*"}

# ���N�G�X�g�g�[�N���擾
# [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step1) 6.1. Obtaining an Unauthorized Request Token
# [POST oauth/request_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/request_token)
# [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
# ���[�J���A�v���̃��N�G�X�g�g�[�N���擾�����ł́Aoauth_callback��"oob"(out-of-band)��ݒ肵�Ȃ���΂Ȃ�Ȃ��l�����ǁA�T�[�r�X�v���o�C�_�[�ɂ���ẮA���������URL���K�v�ȏꍇ������B
# OAuth 1.0a �̎d�l�Ƃ��ẮAoauth_* �ȊO�̒ǉ��p�����[�^������Ƃ������APOST�f�[�^/GET�p�����[�^��ݒ肷��悤�Ɍ�����B����ǉ��p�����[�^�Ȃ��Ȃ̂Ŋ֌W�Ȃ����ǁB
function InvokeRequestToken($method, $requestUrl, $consumerKey, $consumerSecret,
  $callback, $authParams, $bodyParams, $queryParams) {
  Write-Verbose "���N�G�X�g�g�[�N���擾"
  return ParseOauthResponse (
    InvokeOauthApi $method $requestUrl $consumerKey $consumerSecret -callback $callback `
      -authParams $authParams -bodyParams $bodyParams -queryParams $queryParams)
}

# ���[�U�F��URL�̎��s�i�u���E�U���J���j
# [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step2) 6.2. Obtaining User Authorization
# [GET oauth/authorize | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/authorize)
function InvokeUserAuthorization($authUrl, $requestToken, [switch]$dialog,
  $message="������ʂɕ\�����ꂽ�g�[�N���A�܂��͊������/�J�ڃG���[��ʂ�URL����" +
  " oauth_verifier �̒l����͂��Ă��������B") {
  Write-Verbose "���[�U�F��"
  $url = $authUrl + "?oauth_token=" + [System.Web.HttpUtility]::UrlEncode($requestToken)
  Write-Verbose $url
  Start-Process $url

  $verifier = $null
  if (!$dialog) {
    $verifier = Read-Host $message
    # ��verifier��\��t�����Ƃ��ɁA���X�A������������̂Œ��ӁB
  } else {
    $verifier = ShowInputDialog $message
  }
  return $verifier
}

function ShowInputDialog($message="Verifier����͂��Ă��������B", $title="PsOauth1aClient") {
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

# �A�N�Z�X�g�[�N���擾
# [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step3) 6.3. Obtaining an Access Token
# [POST oauth/access_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/access_token)
# �A�N�Z�X�g�[�N���擾�����ł́Aoauth_callback��"oob"(out-of-band)��ݒ肷�邩�Aoauth_callback���̂𑗐M���Ȃ��͗l�B
function InvokeAccessToken($method, $accessUrl, $consumerKey, $consumerSecret,
  $token, $tokenSecret, $verifier) {
  Write-Verbose "�A�N�Z�X�g�[�N���擾"
  return ParseOauthResponse (
    InvokeOauthApi $method $accessUrl $consumerKey $consumerSecret $token $tokenSecret $verifier)
}

# �ȈՓI�Ƀf�[�^���Í����t�@�C���Ƃ��ĕۑ�/�ǂݍ��݂ł���悤�ɂ����B�i���܂�ǂ��Ȃ�������������Ȃ��j
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

# �N���X��
class Oauth1aClient {
  $consumerKey
  $consumerSecret
  $requestUrl
  $authUrl
  $accessUrl
  $accessToken
  $accessTokenSecret
  # �ꎞ�I�ȕϐ�
  $requestToken
  $requestTokenSecret
  $verifier

  Oauth1aClient() {
  }
  Oauth1aClient($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
    $this.consumerKey = $consumerKey
    $this.consumerSecret = $consumerSecret
    $this.requestUrl = $requestUrl
    $this.authUrl = $authUrl
    $this.accessUrl = $accessUrl
  }

  InvokeRequestToken($method, $callback) {
    $this.InvokeRequestToken($method, $callback, $null, $null, $null)
  }
  InvokeRequestToken($method, $callback, $authParams, $bodyParams) {
    $this.InvokeRequestToken($method, $callback, $authParams, $bodyParams, $null)
  }
  InvokeRequestToken($method, $callback, $authParams, $bodyParams, $queryParams) {
    $res = InvokeRequestToken $method $this.requestUrl $this.consumerKey $this.consumerSecret `
      $callback $authParams $bodyParams $queryParams
    $this.requestToken = $res.oauth_token
    $this.requestTokenSecret = $res.oauth_token_secret
  }

  InvokeUserAuthorization($dialog) {
    $this.verifier = InvokeUserAuthorization $this.authUrl $this.requestToken -dialog
  }

  InvokeAccessToken($method) {
    $res = InvokeAccessToken $method $this.accessUrl $this.consumerKey $this.consumerSecret `
      $this.requestToken $this.requestTokenSecret $this.verifier
    $this.accessToken = $res.oauth_token
    $this.accessTokenSecret = $res.oauth_token_secret
  }

  [object] Invoke($method, $url) {
    return $this.Invoke($method, $url, $null, $null, $null)
  }
  [object] Invoke($method, $url, $optionParams) {
    return $this.Invoke($method, $url,
      $optionParams["auth"], $optionParams["body"], $optionParams["query"])
  }
  [object] Invoke($method, $url, $authParams, $bodyParams) {
    return $this.Invoke($method, $url, $authParams, $bodyParams, $null)
  }
  [object] Invoke($method, $url, $authParams, $bodyParams, $queryParams) {
    return InvokeOauthApi $method $url $this.consumerKey $this.consumerSecret `
      -token $this.accessToken -tokenSecret $this.accessTokenSecret `
      -authParams $authParams -bodyParams $bodyParams -queryParams $queryParams
  }

  Save($path) {
    SaveSecretObject $path $this
  }

  Load($path) {
    $data = LoadSecretObject $path
    $data.psobject.properties | %{
      $this.($_.Name) = $_.Value
    }
  }
}
# $path = Join-Path $home "PsOauth1aClient_Dummy.dat"
# $client = New-Object Oauth1aClient
# $client.InvokeOauthFlow()
# $client.Save($path)
# $client.Load($path)
