<#
.SYNOPSIS
  PowerShell標準機能で OAuth 1.0a クライアントを作成してみる
.DESCRIPTION
  ・アクセストークンの有効制限や再取得を考慮していません。
  参考
  [OAuth Core 1.0a](https://oauth.net/core/1.0a/#sig_base_example)
  [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
#>

. (Join-Path $PSScriptRoot "OauthUtil.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# $VerbosePreference = 'Continue'
# $DebugPreference = 'SilentlyContinue'

<#
.SYNOPSIS
  Signature Base String を取得
#>
function Get-SignatureBaseString($Method, $Url, $Params) {
  $arr = $Params.GetEnumerator() | Sort-Object Name | ForEach-Object {
    # $_.Name + '=' + $_.Value
    [Uri]::EscapeDataString($_.Name) + '=' + [Uri]::EscapeDataString($_.Value)
  }
  $signatureBaseString = $Method.ToUpper() + '&' + [Uri]::EscapeDataString($Url.ToLower()) + '&' + [Uri]::EscapeDataString($arr -join '&')
  Write-Debug ("SignatureBaseString: " + $signatureBaseString -replace ('&',"&`n  ") -replace ('%26',"%26`n  "))
  return $signatureBaseString
}
# Get-SignatureBaseString "POST" "https://sample.com" @{a="1";b="2";c="A B"}

<#
.SYNOPSIS
  oauth_signatureを取得
#>
function Get-Signature($SignatureBaseString, $ConsumerSecret, $TokenSecret) {
  $key = [Uri]::EscapeDataString($ConsumerSecret) + '&' + [Uri]::EscapeDataString($TokenSecret)
  $hmacsha1 = New-Object System.Security.Cryptography.HMACSHA1
  $hmacsha1.Key = [System.Text.Encoding]::ASCII.GetBytes($key)
  $signature = [System.Convert]::ToBase64String($hmacsha1.ComputeHash(
    [System.Text.Encoding]::ASCII.GetBytes($SignatureBaseString)))
  Write-Debug "Signature: $signature, Key: $key"
  return $signature
}
# Get-Signature "abc" "def" "ghi"

<#
.SYNOPSIS
  Authorizationヘッダーを取得
#>
function Get-AuthorizationHeader($Params, $Signature) {
  $Params['oauth_signature'] = $Signature
  $arr = $Params.GetEnumerator() | Sort-Object Name | ForEach-Object {
    [Uri]::EscapeDataString($_.Name) + '="' + [Uri]::EscapeDataString($_.Value) + '"'
  }
  $result = "OAuth " + ($arr -join ",")
  Write-Debug ("Authorization header: " + $result -replace (',',",`n  "))
  return $result
}
# GetAuthorization @{a="1";b="2"} "abc"

<#
.SYNOPSIS
  レスポンスを解析
#>
function ParseOauthResponse($ResponseStr) {
  Write-Debug "Response: $ResponseStr"
  $hash = @{}
  $ResponseStr.Split('&') | ForEach-Object {
    $name, $value = $_.Split('=')
    $hash[[Uri]::UnescapeDataString($name)] = [Uri]::UnescapeDataString($value)
  }
  return $hash
}
# ParseOauthResponse "oauth_token=aaa&oauth_token_secret=bbb&oauth_callback_confirmed=true"

<#
.SYNOPSIS
  OAuth1.0aでAPI呼び出しを実行
.DESCRIPTION
  引数の $token, $tokenSecret, $verifier, $callback, $authParams, $bodyParams, $queryParams は、必要に応じて設定する。
  $callback, $authParams は、Authorizationヘッダーやoauth_signatureの計算に含める。
  $bodyParams は、GETパラメータまたはPOSTデータとなる。
  $queryParams は、基本使用しないが、リクエストメソッドによらず、URLにクエリ文字列を設定したいときに使用する。
  リクエストトークン取得時は、$token, $tokenSecret, $verifier なし、必要に応じて $callback を設定する。
  アクセストークン取得時は、$token, $tokenSecret にリクエストトークン取得結果を設定し、$verifier にユーザ認可結果を設定する。
  リソースAPI呼び出し時は、$token, $tokenSecret にアクセストークン取得結果を設定し、必要に応じて $authParams, $bodyParams, $queryParams を設定する。
#>
function Invoke-OauthApi($Method, $Url, $ConsumerKey, $ConsumerSecret,
  $Token, $TokenSecret, $Verifier, $Callback, $AuthParams, $BodyParams, $QueryParams,
  $SignatureMethod='HMAC-SHA1') {

  # oauth_nonceは、一意な値であればよいので、とりあえずタイムスタンプから作成する。
  $timestamp = [int]((Get-Date) - [Datetime]"1970/1/1 00:00:00 GMT").TotalSeconds
  $nonce = "NONCE" + $timestamp
  # oauth_tokenが値なしの場合、ZaimAPIで動作確認したところ、項目名ありでブランク（oauth_token=）でも、項目名ごとなしでも大丈夫だった。
  $params = @{
    "oauth_consumer_key" = $ConsumerKey
    "oauth_nonce" = $nonce
    "oauth_signature_method" = $SignatureMethod
    "oauth_timestamp" = $timestamp
    "oauth_version" = "1.0"
  }
  if ($Token) { $params["oauth_token"] = $Token }
  if ($Verifier) { $params['oauth_verifier'] = $Verifier }
  if ($Callback) { $params['oauth_callback'] = $Callback }
  if ($AuthParams) { $params += $AuthParams }
  $allParams = $params.Clone()
  if ($BodyParams) { $allParams += $BodyParams }
  if ($QueryParams) { $allParams += $QueryParams }
  $signatureBaseString = Get-SignatureBaseString $Method $Url $allParams
  $signature = Get-Signature $signatureBaseString $ConsumerSecret $TokenSecret
  $authorizationHeader = Get-AuthorizationHeader $params $signature

  if ($QueryParams) {
    $arr = $QueryParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
      [System.Web.HttpUtility]::UrlEncode($_.Name) + '=' + [System.Web.HttpUtility]::UrlEncode($_.Value)
    }
    $Url += '?' + ($arr -join '&')
  }

  try {
    $headers = @{
      Authorization = $authorizationHeader
      'User-Agent' = $OAUTH1A_USER_AGENT
    }
    if ($Method -eq 'POST') {
      $headers['Content-Type'] = 'application/x-www-form-urlencoded'
    }
    return Invoke-RestMethod $Url -Method $Method -Headers $headers -Body $BodyParams
  } catch {
    Write-WebException $_
    throw $_
  }
}
# Invoke-OauthApi 'DELETE' "https://kurukurupapap.com/oauth1a" "consumerKey" "consumerSecret" "callback" -QueryParams @{q1=1;q2="abc";"symbol!#"="$%< >+*"}
# Invoke-OauthApi 'DELETE' "https://kurukurupapap.com/oauth1a?a=1" "consumerKey" "consumerSecret" "callback" -QueryParams @{q1=1;q2="abc";"symbol!#"="$%< >+*"}

<#
.SYNOPSIS
  リクエストトークン取得
.DESCRIPTION
  [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step1) 6.1. Obtaining an Unauthorized Request Token
  [POST oauth/request_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/request_token)
  [curl - Powershell OAuth 1.0 'one-legged' authentication with HMAC-SHA1 fails - Stack Overflow](https://stackoverflow.com/questions/60992276/powershell-oauth-1-0-one-legged-authentication-with-hmac-sha1-fails)
  ローカルアプリのリクエストトークン取得処理では、oauth_callbackに"oob"(out-of-band)を設定しなければならない様だけど、サービスプロバイダーによっては、何かしらのURLが必要な場合もある。
  OAuth 1.0a の仕様としては、oauth_* 以外の追加パラメータがあるときだけ、POSTデータ/GETパラメータを設定するように見える。今回追加パラメータなしなので関係ないけど。
#>
function Invoke-RequestToken($Method, $RequestUrl, $ConsumerKey, $ConsumerSecret,
  $Callback, $AuthParams, $BodyParams, $QueryParams) {
  Write-Verbose "リクエストトークン取得"
  return ParseOauthResponse (
    Invoke-OauthApi $Method $RequestUrl $ConsumerKey $ConsumerSecret -Callback $Callback `
      -AuthParams $AuthParams -BodyParams $BodyParams -QueryParams $QueryParams)
}

<#
.SYNOPSIS
  ユーザ認可URLの実行（ブラウザが開く）
.DESCRIPTION
  [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step2) 6.2. Obtaining User Authorization
  [GET oauth/authorize | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/authorize)
#>
function Invoke-UserAuthorization($AuthUrl, $RequestToken, [switch]$Dialog,
  $Message=$OAUTH1A_VERIFIER_MSG) {
  Write-Verbose "ユーザ認証"
  $url = $AuthUrl + "?oauth_token=" + [System.Web.HttpUtility]::UrlEncode($RequestToken)
  Write-Verbose $url
  Start-Process $url
  return Read-UserInput $Message $Dialog
}

<#
.SYNOPSIS
  アクセストークン取得
.DESCRIPTION
  [OAuth Core 1.0a](https://oauth.net/core/1.0a/#auth_step3) 6.3. Obtaining an Access Token
  [POST oauth/access_token | Twitter Developer](https://developer.twitter.com/en/docs/authentication/api-reference/access_token)
  アクセストークン取得処理では、oauth_callbackに"oob"(out-of-band)を設定するか、oauth_callback自体を送信しない模様。
#>
function Invoke-AccessToken($Method, $AccessUrl, $ConsumerKey, $ConsumerSecret,
  $Token, $TokenSecret, $Verifier) {
  Write-Verbose "アクセストークン取得"
  return ParseOauthResponse (
    Invoke-OauthApi $Method $AccessUrl $ConsumerKey $ConsumerSecret $Token $TokenSecret $Verifier)
}

# # クラス化
# class Oauth1aClient {
#   $ConsumerKey
#   $ConsumerSecret
#   $RequestUrl
#   $AuthUrl
#   $AccessUrl
#   $AccessToken
#   $AccessTokenSecret
#   # 一時的な変数
#   $RequestToken
#   $RequestTokenSecret
#   $Verifier
# 
#   Oauth1aClient() {
#   }
#   Oauth1aClient($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl) {
#     $this.ConsumerKey = $consumerKey
#     $this.ConsumerSecret = $consumerSecret
#     $this.RequestUrl = $requestUrl
#     $this.AuthUrl = $authUrl
#     $this.AccessUrl = $accessUrl
#   }
# 
#   InvokeRequestToken($method, $callback) {
#     $this.InvokeRequestToken($method, $callback, $null, $null, $null)
#   }
#   InvokeRequestToken($method, $callback, $authParams, $bodyParams) {
#     $this.InvokeRequestToken($method, $callback, $authParams, $bodyParams, $null)
#   }
#   InvokeRequestToken($method, $callback, $authParams, $bodyParams, $queryParams) {
#     $res = Invoke-RequestToken $method $this.RequestUrl $this.ConsumerKey $this.ConsumerSecret `
#       $callback $authParams $bodyParams $queryParams
#     $this.RequestToken = $res.oauth_token
#     $this.RequestTokenSecret = $res.oauth_token_secret
#   }
# 
#   InvokeUserAuthorization($dialog) {
#     $this.Verifier = Invoke-UserAuthorization $this.AuthUrl $this.RequestToken -Dialog
#   }
# 
#   InvokeAccessToken($method) {
#     $res = Invoke-AccessToken $method $this.AccessUrl $this.ConsumerKey $this.ConsumerSecret `
#       $this.RequestToken $this.RequestTokenSecret $this.Verifier
#     $this.AccessToken = $res.oauth_token
#     $this.AccessTokenSecret = $res.oauth_token_secret
#   }
# 
#   [object] Invoke($method, $url) {
#     return $this.Invoke($method, $url, $null, $null, $null)
#   }
#   [object] Invoke($method, $url, $optionParams) {
#     return $this.Invoke($method, $url,
#       $optionParams["auth"], $optionParams["body"], $optionParams["query"])
#   }
#   [object] Invoke($method, $url, $authParams, $bodyParams) {
#     return $this.Invoke($method, $url, $authParams, $bodyParams, $null)
#   }
#   [object] Invoke($method, $url, $authParams, $bodyParams, $queryParams) {
#     return Invoke-OauthApi $method $url $this.consumerKey $this.consumerSecret `
#       -Token $this.accessToken -TokenSecret $this.accessTokenSecret `
#       -AuthParams $authParams -BodyParams $bodyParams -QueryParams $queryParams
#   }
# 
#   Save($path) {
#     Export-OauthClientInfo $path $this
#   }
# 
#   Load($path) {
#     $data = Import-OauthClientInfo $path
#     $data.psobject.properties | ForEach-Object {
#       $this.($_.Name) = $_.Value
#     }
#   }
# }
# # $path = Join-Path $home "PsOauth1aClient_Dummy.dat"
# # $client = New-Object Oauth1aClient
# # $client.Save($path)
# # $client.Load($path)
