# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# �E�A�N�Z�X�g�[�N���̗L��������Ď擾���l�����Ă��܂���B

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# Signature Base String ���擾
# [OAuth Core 1.0a](https://oauth.net/core/1.0a/#sig_base_example)
# [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
# ���\�b�h�́A�啶���ł��邱�ƁB
function GetSignatureBaseString($method, $url, $params) {
  $arr = $params.GetEnumerator() | sort Name | %{
    $_.Name + '=' + $_.Value
  }
  $signatureBaseString = $method.ToUpper() + '&' + [Uri]::EscapeDataString($url) + '&' + [Uri]::EscapeDataString($arr -join '&')
  Write-Debug "SignatureBaseString: $signatureBaseString"
  return $signatureBaseString
}
# GetSignatureBaseString "POST" "https://sample.com" @{a="1";b="2"}

# oauth_signature���擾
function GetSignature($signatureBaseString, $consumerKey, $tokenSecret) {
  $key = $consumerSecret + '&' + $tokenSecret
  $hmacsha1 = New-Object System.Security.Cryptography.HMACSHA1
  $hmacsha1.Key = [System.Text.Encoding]::ASCII.GetBytes($key)
  $signature = [System.Convert]::ToBase64String($hmacsha1.ComputeHash(
    [System.Text.Encoding]::ASCII.GetBytes($signatureBaseString)))
  Write-Debug "Key: $key"
  Write-Debug "Signature: $signature"
  return $signature
}
# GetSignature "abc" "def" "ghi"

# Authorization�w�b�_�[���擾
function GetAuthorizationHeader($params, $signature) {
  $params2 = $params.Clone()
  $params2['oauth_signature'] = $signature
  $arr = $params2.GetEnumerator() | sort Name | %{
    [Uri]::EscapeDataString($_.Name) + '="' + [Uri]::EscapeDataString($_.Value) + '"'
  }
  $result = "OAuth " + ($arr -join ",")
  Write-Debug "Authorization: $result"
  return $result
}
# GetAuthorization @{a="1";b="2"} "abc"

# ���X�|���X�����
function ParseResponse($responseStr) {
  Write-Debug "Response: $responseStr"
  $hash = @{}
  $responseStr.Split('&') | %{
    $name, $value = $_.Split('=')
    $hash[$name] = $value
  }
  return $hash
}
# ParseResponse "oauth_token=aaa&oauth_token_secret=bbb&oauth_callback_confirmed=true"

# HTTP�A�N�Z�X�G���[���̃G���[����\��
function PrintWebException($e) {
  Write-Host $e
  Write-Host "$($e.Exception.Status.value__) $($e.Exception.Status.ToString())"
  $stream = $e.Exception.Response.GetResponseStream()
  $reader = New-Object System.IO.StreamReader $stream
  $reader.BaseStream.Position = 0
  $reader.DiscardBufferedData()
  Write-Host $reader.ReadToEnd()
  $stream.Close()
}

# OAuth1.0a��API�Ăяo�������s
# ������ $token, $tokenSecret, $oauthVerifier, $optionParams �́A�K�v�ɉ����Đݒ肷��B
# ���N�G�X�g�g�[�N���擾���́A$oauthToken, $oauthTokenSecret, $oauthVerifier �Ȃ��B
# �A�N�Z�X�g�[�N���擾���́A$oauthToken, $oauthTokenSecret �Ƀ��N�G�X�g�g�[�N���擾���ʂ�ݒ肵�A$oauthVerifier �Ƀ��[�U�F�،��ʂ�ݒ肷��B
# ���\�[�XAPI�Ăяo�����́A$oauthToken, $oauthTokenSecret �ɃA�N�Z�X�g�[�N���擾���ʂ�ݒ肵�A�Ăяo��API��GET/POST�p�����[�^��t������Ƃ��́AoptionParams ���ݒ肷��B
function InvokeOauthApi($method, $url, $callbackUrl, $consumerKey, $consumerSecret,
  $oauthToken='', $oauthTokenSecret='', $oauthVerifier=$null, $optionParams=@{}) {

  # oauth_nonce�́A��ӂȒl�ł���΂悢�̂ŁA�Ƃ肠�����^�C���X�^���v����쐬����B
  $timestamp = [int]((Get-Date) - [Datetime]"1970/1/1 00:00:00 GMT").TotalSeconds
  $nonce = "NONCE" + $timestamp
  # oauth_token���l�Ȃ��̏ꍇ�AZaimAPI�œ���m�F�����Ƃ���A���ږ�����Ńu�����N�ioauth_token=�j�ł��A���ږ����ƂȂ��ł����v�������B
  $params = @{
    "oauth_consumer_key" = $consumerKey
    "oauth_nonce" = $nonce
    "oauth_signature_method" = "HMAC-SHA1"
    "oauth_timestamp" = $timestamp
    "oauth_token" = $oauthToken
    "oauth_version" = "1.0"
  }
  if ($callbackUrl) {
    $params['oauth_callback'] = $callbackUrl
  }
  if ($oauthVerifier) {
    $params['oauth_verifier'] = $oauthVerifier
  }
  if ($optionParams) {
    $params += $optionParams
  }
  $signatureBaseString = GetSignatureBaseString $method $url $params
  $signature = GetSignature $signatureBaseString $consumerSecret $oauthTokenSecret
  $authorizationHeader = GetAuthorizationHeader $params $signature

  try {
    $headers = @{
      Authorization = $authorizationHeader
    }
    $res = Invoke-RestMethod $url -Method $method -Headers $headers -Body $optionParams
    return $res
  } catch {
    PrintWebException $_
    throw $_
  }
}

# OAuth�F��
# ���O�� $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl ��ݒ肵�Ă���
function InvokeOauthFlow($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
  # �P�D���N�G�X�g�g�[�N���擾
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step1) 6.1. Obtaining an Unauthorized Request Token
  # [POST oauth/request_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/request_token)
  # [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
  # ���N�G�X�g�g�[�N���擾�����ł́Aoauth_callback��"oob"(out-of-band)��ݒ肵�Ȃ���΂Ȃ�Ȃ��͗l�B
  # OAuth 1.0a �̎d�l�Ƃ��ẮAoauth_* �ȊO�̒ǉ��p�����[�^������Ƃ������APOST�f�[�^/GET�p�����[�^��ݒ肷��悤�Ɍ�����B����ǉ��p�����[�^�Ȃ��Ȃ̂Ŋ֌W�Ȃ����ǁB
  Write-Verbose "���N�G�X�g�g�[�N���擾 �J�n"
  $res = InvokeOauthApi 'POST' $requestUrl 'oob' $consumerKey $consumerSecret
  $res = ParseResponse $res

  # �Q�D���[�U�ɂ�鏳�F
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step2) 6.2. Obtaining User Authorization
  # [GET oauth/authorize | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/authorize)
  Write-Verbose "���[�U�F�� �J�n"
  $url = $authUrl + "?oauth_token=" + $res.oauth_token
  Write-Verbose $url
  Start-Process $url
  $oauthVerifier = Read-Host "������ʂɕ\�����ꂽ�g�[�N������͂��Ă��������B"

  # �R�D�A�N�Z�X�g�[�N���擾
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step3) 6.3. Obtaining an Access Token
  # [POST oauth/access_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/access_token)
  # �A�N�Z�X�g�[�N���擾�����ł́Aoauth_callback��"oob"(out-of-band)��ݒ肷�邩�Aoauth_callback���̂𑗐M���Ȃ��͗l�B
  Write-Verbose "�A�N�Z�X�g�[�N���擾 �J�n"
  $res = InvokeOauthApi 'POST' $accessUrl $null $consumerKey $consumerSecret $res.oauth_token $res.oauth_token_secret $oauthVerifier
  return ParseResponse $res
}
# $DebugPreference = 'Continue'
# $token = InvokeOauthFlow $consumerKey $consumerSecret $requestUrl $authUrl $accessUrl

# �N���X��
# �ȈՓI�Ƀf�[�^���Í����t�@�C���Ƃ��ĕۑ�/�ǂݍ��݂ł���悤�ɂ����B�i���܂�ǂ��Ȃ�������������Ȃ��j
class OAuth1aLocalClient {
  $consumerKey
  $consumerSecret
  $requestUrl
  $authUrl
  $accessUrl
  $accessToken
  $accessTokenSecret

  OAuth1aLocalClient() {
  }
  OAuth1aLocalClient($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
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
    return $this.Invoke($method, $url, $null)
  }
  [object] Invoke($method, $url, $optionParams) {
    if (!$this.accessToken -or !$this.accessTokenSecret) {
      $this.InvokeOauthFlow()
    }
    return InvokeOauthApi $method $url $null $this.consumerKey $this.consumerSecret $this.accessToken $this.accessTokenSecret -optionParams $optionParams
  }

  Save($path) {
    $jsonStr = ConvertTo-Json $this -Compress
    ConvertTo-SecureString $jsonStr -AsPlainText -Force | ConvertFrom-SecureString | Set-Content $path
  }

  Load($path) {
    $ss = Get-Content $path | ConvertTo-SecureString
    $jsonStr = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(
      [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss))
    (ConvertFrom-Json $jsonStr).psobject.properties | %{
      $this.($_.Name) = $_.Value
    }
  }
}
# $client = New-Object OAuth1aLocalClient
# $path = Join-Path $home "PSOAuth1aLocalClient_Dummy.dat"
# $client.Save($path)
# $client.Load($path)
