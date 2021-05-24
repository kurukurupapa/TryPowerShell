# PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
# ・アクセストークンの有効制限や再取得を考慮していません。
# 参考
# [OAuth Core 1.0a](https://oauth.net/core/1.0a/#sig_base_example)
# [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# Signature Base String を取得
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

# oauth_signatureを取得
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

# Authorizationヘッダーを取得
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

# レスポンスを解析
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

# OAuth1.0aでAPI呼び出しを実行
# 引数の $callback, $token, $tokenSecret, $verifier, $optionParams, $bodyParams, $queryParams は、必要に応じて設定する。
# $optionParamsの値は、Authorizationヘッダーやoauth_signatureの計算に含める。
# $bodyParamsの値は、GETパラメータまたはPOSTデータとなる。
# リクエストトークン取得時は、$token, $tokenSecret, $verifier なし、必要に応じて $callback を設定する。
# アクセストークン取得時は、$token, $tokenSecret にリクエストトークン取得結果を設定し、$verifier にユーザ認証結果を設定する。
# リソースAPI呼び出し時は、$token, $tokenSecret にアクセストークン取得結果を設定し、呼び出すAPIにGET/POSTパラメータを付加するときは、optionParams を設定する。
# $queryParams は、基本使用しないが、リクエストメソッドによらず、URLにクエリ文字列を設定したいときに使用する。
function InvokeOauthApi($method, $url, $consumerKey, $consumerSecret,
  $callback=$null, $token='', $tokenSecret='', $verifier=$null, $optionParams=@{}, $bodyParams=$null, $queryParams=$null,
  $signatureMethod='HMAC-SHA1') {

  # oauth_nonceは、一意な値であればよいので、とりあえずタイムスタンプから作成する。
  $timestamp = [int]((Get-Date) - [Datetime]"1970/1/1 00:00:00 GMT").TotalSeconds
  $nonce = "NONCE" + $timestamp
  # oauth_tokenが値なしの場合、ZaimAPIで動作確認したところ、項目名ありでブランク（oauth_token=）でも、項目名ごとなしでも大丈夫だった。
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

# ユーザ認可URLの実行（ブラウザが開く）
function InvokeUserAuthorization($authUrl, $token) {
  $url = $authUrl + "?oauth_token=" + [System.Web.HttpUtility]::UrlEncode($token)
  Write-Verbose $url
  Start-Process $url
}

# OAuth1.0a認証のリクエストトークンからアクセストークン取得までのフロー
function InvokeOauthFlow($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
  # １．リクエストトークン取得
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step1) 6.1. Obtaining an Unauthorized Request Token
  # [POST oauth/request_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/request_token)
  # [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
  # リクエストトークン取得処理では、oauth_callbackに"oob"(out-of-band)を設定しなければならない模様。
  # OAuth 1.0a の仕様としては、oauth_* 以外の追加パラメータがあるときだけ、POSTデータ/GETパラメータを設定するように見える。今回追加パラメータなしなので関係ないけど。
  Write-Verbose "リクエストトークン取得 開始"
  $res = ParseOauthResponse(
    InvokeOauthApi 'POST' $requestUrl $consumerKey $consumerSecret -callback 'oob')

  # ２．ユーザによる承認
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step2) 6.2. Obtaining User Authorization
  # [GET oauth/authorize | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/authorize)
  Write-Verbose "ユーザ認証 開始"
  InvokeUserAuthorization $authUrl $res.oauth_token
  $verifier = Read-Host "完了画面に表示されたトークンを入力してください。"

  # ３．アクセストークン取得
  # [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step3) 6.3. Obtaining an Access Token
  # [POST oauth/access_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/access_token)
  # アクセストークン取得処理では、oauth_callbackに"oob"(out-of-band)を設定するか、oauth_callback自体を送信しない模様。
  Write-Verbose "アクセストークン取得 開始"
  return ParseOauthResponse(
    InvokeOauthApi 'POST' $accessUrl $consumerKey $consumerSecret `
    -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier)
}
# $DebugPreference = 'Continue'
# $token = InvokeOauthFlow $consumerKey $consumerSecret $requestUrl $authUrl $accessUrl

# 簡易的にデータを暗号化ファイルとして保存/読み込みできるようにした。（あまり良くない実装かもしれない）
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

# クラス化
# 簡易的にデータを暗号化ファイルとして保存/読み込みできるようにした。（あまり良くない実装かもしれない）
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
