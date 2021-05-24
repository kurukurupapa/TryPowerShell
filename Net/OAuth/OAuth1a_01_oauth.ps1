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
# ������ $callback, $token, $tokenSecret, $verifier, $optionParams, $bodyParams, $queryParams �́A�K�v�ɉ����Đݒ肷��B
# $optionParams�̒l�́AAuthorization�w�b�_�[��oauth_signature�̌v�Z�Ɋ܂߂�B
# $bodyParams�̒l�́AGET�p�����[�^�܂���POST�f�[�^�ƂȂ�B
# ���N�G�X�g�g�[�N���擾���́A$token, $tokenSecret, $verifier �Ȃ��A�K�v�ɉ����� $callback ��ݒ肷��B
# �A�N�Z�X�g�[�N���擾���́A$token, $tokenSecret �Ƀ��N�G�X�g�g�[�N���擾���ʂ�ݒ肵�A$verifier �Ƀ��[�U�F�،��ʂ�ݒ肷��B
# ���\�[�XAPI�Ăяo�����́A$token, $tokenSecret �ɃA�N�Z�X�g�[�N���擾���ʂ�ݒ肵�A�Ăяo��API��GET/POST�p�����[�^��t������Ƃ��́AoptionParams ��ݒ肷��B
# $queryParams �́A��{�g�p���Ȃ����A���N�G�X�g���\�b�h�ɂ�炸�AURL�ɃN�G���������ݒ肵�����Ƃ��Ɏg�p����B
function InvokeOauthApi($method, $url, $consumerKey, $consumerSecret,
  $callback=$null, $token='', $tokenSecret='', $verifier=$null, $optionParams=@{}, $bodyParams=$null, $queryParams=$null,
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
  if ($optionParams) {
    $params += $optionParams
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
      'User-Agent' = "PsOauth1aLocalClient"
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

# ���[�U�F��URL�̎��s�i�u���E�U���J���j
function InvokeUserAuthorization($authUrl, $token) {
  $url = $authUrl + "?oauth_token=" + [System.Web.HttpUtility]::UrlEncode($token)
  Write-Verbose $url
  Start-Process $url
}

# OAuth1.0a�F�؂̃��N�G�X�g�g�[�N������A�N�Z�X�g�[�N���擾�܂ł̃t���[
function InvokeOauthFlow($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
  # �P�D���N�G�X�g�g�[�N���擾
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step1) 6.1. Obtaining an Unauthorized Request Token
  # [POST oauth/request_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/request_token)
  # [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
  # ���N�G�X�g�g�[�N���擾�����ł́Aoauth_callback��"oob"(out-of-band)��ݒ肵�Ȃ���΂Ȃ�Ȃ��͗l�B
  # OAuth 1.0a �̎d�l�Ƃ��ẮAoauth_* �ȊO�̒ǉ��p�����[�^������Ƃ������APOST�f�[�^/GET�p�����[�^��ݒ肷��悤�Ɍ�����B����ǉ��p�����[�^�Ȃ��Ȃ̂Ŋ֌W�Ȃ����ǁB
  Write-Verbose "���N�G�X�g�g�[�N���擾 �J�n"
  $res = ParseOauthResponse(
    InvokeOauthApi 'POST' $requestUrl $consumerKey $consumerSecret -callback 'oob')

  # �Q�D���[�U�ɂ�鏳�F
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step2) 6.2. Obtaining User Authorization
  # [GET oauth/authorize | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/authorize)
  Write-Verbose "���[�U�F�� �J�n"
  InvokeUserAuthorization $authUrl $res.oauth_token
  $verifier = Read-Host "������ʂɕ\�����ꂽ�g�[�N������͂��Ă��������B"

  # �R�D�A�N�Z�X�g�[�N���擾
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step3) 6.3. Obtaining an Access Token
  # [POST oauth/access_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/access_token)
  # �A�N�Z�X�g�[�N���擾�����ł́Aoauth_callback��"oob"(out-of-band)��ݒ肷�邩�Aoauth_callback���̂𑗐M���Ȃ��͗l�B
  Write-Verbose "�A�N�Z�X�g�[�N���擾 �J�n"
  return ParseOauthResponse(
    InvokeOauthApi 'POST' $accessUrl $consumerKey $consumerSecret `
    -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier)
}
# $DebugPreference = 'Continue'
# $token = InvokeOauthFlow $consumerKey $consumerSecret $requestUrl $authUrl $accessUrl

# �ȈՓI�Ƀf�[�^���Í����t�@�C���Ƃ��ĕۑ�/�ǂݍ��݂ł���悤�ɂ����B�i���܂�ǂ��Ȃ�������������Ȃ��j
function SaveSecretObject($path, $obj) {
  $jsonStr = ConvertTo-Json $obj -Compress
  ConvertTo-SecureString $jsonStr -AsPlainText -Force | ConvertFrom-SecureString | Set-Content $path
}
function LoadSecretObject($path) {
  $ss = Get-Content $path | ConvertTo-SecureString
  $jsonStr = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss))
  return ConvertFrom-Json $jsonStr
}

# �N���X��
# �ȈՓI�Ƀf�[�^���Í����t�@�C���Ƃ��ĕۑ�/�ǂݍ��݂ł���悤�ɂ����B�i���܂�ǂ��Ȃ�������������Ȃ��j
class Oauth1aLocalClient {
  $consumerKey
  $consumerSecret
  $requestUrl
  $authUrl
  $accessUrl
  $accessToken
  $accessTokenSecret

  Oauth1aLocalClient() {
  }
  Oauth1aLocalClient($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
    $this.consumerKey = $consumerKey
    $this.consumerSecret = $consumerSecret
    $this.requestUrl = $requestUrl
    $this.authUrl = $authUrl
    $this.accessUrl = $accessUrl
  }

  InvokeOauthFlow() {
    $token = InvokeOauthFlow $this.consumerKey $this.consumerSecret $this.requestUrl $this.authUrl $this.accessUrl
    $this.accessToken = $token.oauth_token
    $this.accessTokenSecret = $token.oauth_token_secret
  }

  [object] Invoke($method, $url) {
    return $this.Invoke($method, $url, $null, $null, $null)
  }
  [object] Invoke($method, $url, $optionParams, $bodyParams) {
    return $this.Invoke($method, $url, $optionParams, $bodyParams, $null)
  }
  [object] Invoke($method, $url, $optionParams, $bodyParams, $queryParams) {
    if (!$this.accessToken -or !$this.accessTokenSecret) {
      $this.InvokeOauthFlow()
    }
    return InvokeOauthApi $method $url $this.consumerKey $this.consumerSecret `
      -token $this.accessToken -tokenSecret $this.accessTokenSecret `
      -optionParams $optionParams -bodyParams $bodyParams -queryParams $queryParams
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
# $path = Join-Path $home "PsOauth1aLocalClient_Dummy.dat"
# $client = New-Object Oauth1aLocalClient
# $client.InvokeOauthFlow()
# $client.Save($path)
# $client.Load($path)
