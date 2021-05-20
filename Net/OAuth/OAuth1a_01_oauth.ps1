# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# ・アクセストークンの有効制限や再取得を考慮していません。

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# Signature Base String を取得
# [OAuth Core 1.0a](https://oauth.net/core/1.0a/#sig_base_example)
# [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
# メソッドは、大文字であること。
function GetSignatureBaseString($method, $url, $params) {
  $arr = $params.GetEnumerator() | sort Name | %{
    $_.Name + '=' + $_.Value
  }
  $signatureBaseString = $method.ToUpper() + '&' + [Uri]::EscapeDataString($url) + '&' + [Uri]::EscapeDataString($arr -join '&')
  Write-Debug "SignatureBaseString: $signatureBaseString"
  return $signatureBaseString
}
# GetSignatureBaseString "POST" "https://sample.com" @{a="1";b="2"}

# oauth_signatureを取得
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

# Authorizationヘッダーを取得
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

# レスポンスを解析
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

# HTTPアクセスエラー時のエラー情報を表示
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

# OAuth1.0aでAPI呼び出しを実行
# 引数の $token, $tokenSecret, $oauthVerifier, $optionParams は、必要に応じて設定する。
# リクエストトークン取得時は、$oauthToken, $oauthTokenSecret, $oauthVerifier なし。
# アクセストークン取得時は、$oauthToken, $oauthTokenSecret にリクエストトークン取得結果を設定し、$oauthVerifier にユーザ認証結果を設定する。
# リソースAPI呼び出し時は、$oauthToken, $oauthTokenSecret にアクセストークン取得結果を設定し、呼び出すAPIにGET/POSTパラメータを付加するときは、optionParams も設定する。
function InvokeOauthApi($method, $url, $callbackUrl, $consumerKey, $consumerSecret,
  $oauthToken='', $oauthTokenSecret='', $oauthVerifier=$null, $optionParams=@{}) {

  # oauth_nonceは、一意な値であればよいので、とりあえずタイムスタンプから作成する。
  $timestamp = [int]((Get-Date) - [Datetime]"1970/1/1 00:00:00 GMT").TotalSeconds
  $nonce = "NONCE" + $timestamp
  # oauth_tokenが値なしの場合、ZaimAPIで動作確認したところ、項目名ありでブランク（oauth_token=）でも、項目名ごとなしでも大丈夫だった。
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

# OAuth認証
# 事前に $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl を設定しておく
function InvokeOauthFlow($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
  # １．リクエストトークン取得
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step1) 6.1. Obtaining an Unauthorized Request Token
  # [POST oauth/request_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/request_token)
  # [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
  # リクエストトークン取得処理では、oauth_callbackに"oob"(out-of-band)を設定しなければならない模様。
  # OAuth 1.0a の仕様としては、oauth_* 以外の追加パラメータがあるときだけ、POSTデータ/GETパラメータを設定するように見える。今回追加パラメータなしなので関係ないけど。
  Write-Verbose "リクエストトークン取得 開始"
  $res = InvokeOauthApi 'POST' $requestUrl 'oob' $consumerKey $consumerSecret
  $res = ParseResponse $res

  # ２．ユーザによる承認
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step2) 6.2. Obtaining User Authorization
  # [GET oauth/authorize | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/authorize)
  Write-Verbose "ユーザ認証 開始"
  $url = $authUrl + "?oauth_token=" + $res.oauth_token
  Write-Verbose $url
  Start-Process $url
  $oauthVerifier = Read-Host "完了画面に表示されたトークンを入力してください。"

  # ３．アクセストークン取得
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step3) 6.3. Obtaining an Access Token
  # [POST oauth/access_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/access_token)
  # アクセストークン取得処理では、oauth_callbackに"oob"(out-of-band)を設定するか、oauth_callback自体を送信しない模様。
  Write-Verbose "アクセストークン取得 開始"
  $res = InvokeOauthApi 'POST' $accessUrl $null $consumerKey $consumerSecret $res.oauth_token $res.oauth_token_secret $oauthVerifier
  return ParseResponse $res
}
# $DebugPreference = 'Continue'
# $token = InvokeOauthFlow $consumerKey $consumerSecret $requestUrl $authUrl $accessUrl

# クラス化
# 簡易的にデータを暗号化ファイルとして保存/読み込みできるようにした。（あまり良くない実装かもしれない）
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
