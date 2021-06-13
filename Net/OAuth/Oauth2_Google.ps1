<#
.SYNOPSIS
  PowerShell標準機能で OAuth 2.0 クライアントを作成（Google API）
.DESCRIPTION
  参考
  [OAuth 2.0 for Mobile & Desktop Apps ?|? Google Identity Platform](https://developers.google.com/identity/protocols/oauth2/native-app)
  [GoogleAPIのOAuth2.0スコープ ?|? Google Identity Platform ?|? Google Developers](https://developers.google.com/identity/protocols/oauth2/scopes)
  前提
  Google Cloud Platform で OAuth 2.0 クライアントを登録し、クライアントID、クライアントシークレットを払い出しておく。
  [ホーム ? Test01 ? Google Cloud Platform](https://console.cloud.google.com/home/dashboard?project=test01-e645b)
#>

. (Join-Path $PSScriptRoot "Oauth2AuthCodeClient.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
# $DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'
$CODE_MSG = "完了画面に表示されたコードを入力してください。"

# OAuthフローを1ステップずつ確認（認可コードグラントタイプ）
# 事前に、$clientId, $clientSecret, $redirectUri, $authUrl, $accessUrl を設定しておく。
$infoPath = Join-Path $home "PsOauth2Client_Google.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# １．認可リクエスト
# stateパラメータを設定することが推奨されるが今回は省略。
$authCode = Invoke-Oauth2UserAuth "https://accounts.google.com/o/oauth2/v2/auth" $info.ClientId @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  scope = "email profile" +
    " https://www.googleapis.com/auth/drive.metadata.readonly" +
    # " https://www.googleapis.com/auth/tasks.readonly"
    " https://www.googleapis.com/auth/tasks" +
    " https://www.googleapis.com/auth/spreadsheets"
} -Message $CODE_MSG -Dialog $true

# ２．アクセストークンリクエスト
Invoke-Oauth2AccessToken "https://oauth2.googleapis.com/token" $authCode @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
} | Tee-Object -Variable res
Add-Oauth2ClientInfo $info $res | Tee-Object -Variable info

# 保存
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# ３．リソースAPI

# Google Drive API
# [Introduction to Google Drive API ?|? Google Developers](https://developers.google.com/drive/api/v3/about-sdk)
Invoke-Oauth2Api GET "https://www.googleapis.com/drive/v3/files" $info.AccessToken | ConvertTo-Json

# Google Tasks API
# [Overview ?|? Tasks API ?|? Google Developers](https://developers.google.com/tasks)
# TaskList 追加
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/users/@me/lists" $info.AccessToken @{
  title = "PsOauth2Client TaskList 01"
} -ContentType "application/json" | Tee-Object -Variable taskListRes | ConvertTo-Json
# TaskList 変更
Invoke-Oauth2Api PATCH "https://tasks.googleapis.com/tasks/v1/users/@me/lists/$($taskListRes.id)" $info.AccessToken @{
  title = "PsOauth2Client TaskList 01b"
} -ContentType "application/json" | ConvertTo-Json
Invoke-Oauth2Api PUT "https://tasks.googleapis.com/tasks/v1/users/@me/lists/$($taskListRes.id)" $info.AccessToken @{
  id = $taskListRes.id # idがないとエラーになる
  title = "PsOauth2Client TaskList 01c"
} -ContentType "application/json" | ConvertTo-Json
# TaskList 取得
Invoke-Oauth2Api GET "https://tasks.googleapis.com/tasks/v1/users/@me/lists/$($taskListRes.id)" $info.AccessToken | ConvertTo-Json
# TaskList 一覧
Invoke-Oauth2Api GET "https://tasks.googleapis.com/tasks/v1/users/@me/lists" $info.AccessToken | ConvertTo-Json
# Task 追加
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks" $info.AccessToken @{
  title = "タスク1"
  notes = "タスクの詳細です。"
  due = (Get-Date).AddDays(1).ToString("o")
} -ContentType "application/json" | Tee-Object -Variable taskRes | ConvertTo-Json
# Task 追加（子タスク）
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks" $info.AccessToken @{
  title = "タスク2"
} -ContentType "application/json" | Tee-Object -Variable task2Res | ConvertTo-Json
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($task2Res.id)/move" $info.AccessToken @{
  parent = $taskRes.id
} -ContentType "application/json" | ConvertTo-Json
# Task 変更
Invoke-Oauth2Api PATCH "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($taskRes.id)" $info.AccessToken @{
  title = "タスク1b"
} -ContentType "application/json" | ConvertTo-Json
Invoke-Oauth2Api PUT "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($taskRes.id)" $info.AccessToken @{
  id = $taskRes.id # idがないとエラーになる
  title = "タスク1c"
  status = "completed"
} -ContentType "application/json" | ConvertTo-Json
# Task 取得
Invoke-Oauth2Api GET "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($taskRes.id)" $info.AccessToken | ConvertTo-Json
# Task 一覧
Invoke-Oauth2Api GET "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks" $info.AccessToken | ConvertTo-Json
# Task 削除
Invoke-Oauth2Api DELETE "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($taskRes.id)" $info.AccessToken
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/clear" $info.AccessToken
# TaskList 削除
Invoke-Oauth2Api DELETE "https://tasks.googleapis.com/tasks/v1/users/@me/lists/$($taskListRes.id)" $info.AccessToken

# Google Sheets API
# [Sheets API ?|? Google Developers](https://developers.google.com/sheets/api)
# Spreadsheetファイルを作成
Invoke-Oauth2Api POST "https://sheets.googleapis.com/v4/spreadsheets" $info.AccessToken @{
  properties = @{
    title = "PsOauth2Client_Sheet_1"
  }
  sheets = @(@{ data = @(@{ rowData = @(@{ values = @(
      @{ userEnteredValue = @{ stringValue = "A1" } },
      @{ userEnteredValue = @{ stringValue = "B1" } }
    )}, @{ values = @(
      @{ userEnteredValue = @{ stringValue = "A2" } },
      @{ userEnteredValue = @{ stringValue = "B2" } }
    )}
  ) }) })
} -ContentType "application/json" | Tee-Object -Variable sheetRes | ConvertTo-Json
# 値の追加
Invoke-Oauth2Api POST "https://sheets.googleapis.com/v4/spreadsheets/$($sheetRes.spreadsheetId)/values/A1:append" $info.AccessToken -QueryParams @{
  valueInputOption = "USER_ENTERED"
} -OptionParams @{
  values = @(@("Append row 1"),@("Append row 2"))
} -ContentType "application/json"  | ConvertTo-Json
# 値の変更
Invoke-Oauth2Api PUT "https://sheets.googleapis.com/v4/spreadsheets/$($sheetRes.spreadsheetId)/values/A1" $info.AccessToken -QueryParams @{
  valueInputOption = "USER_ENTERED"
} -OptionParams @{
  values = @(@("A1b"),@("Dummy"))
} -ContentType "application/json" | ConvertTo-Json
Invoke-Oauth2Api PUT "https://sheets.googleapis.com/v4/spreadsheets/$($sheetRes.spreadsheetId)/values/'シート1'!A1:B2" $info.AccessToken -QueryParams @{
  valueInputOption = "USER_ENTERED"
} -OptionParams @{
  majorDimension = "COLUMNS"
  values = @(@("A1b","B1b"),@("A2b","B2b"))
} -ContentType "application/json" | ConvertTo-Json
# 値のクリア
Invoke-Oauth2Api POST "https://sheets.googleapis.com/v4/spreadsheets/$($sheetRes.spreadsheetId)/values/A4:clear" $info.AccessToken | ConvertTo-Json
# 取得
Invoke-Oauth2Api GET "https://sheets.googleapis.com/v4/spreadsheets/$($sheetRes.spreadsheetId)/values/A1:B4" $info.AccessToken | ConvertTo-Json
Invoke-Oauth2Api GET "https://sheets.googleapis.com/v4/spreadsheets/$($sheetRes.spreadsheetId)" $info.AccessToken | ConvertTo-Json

# ４．リフレッシュトークンリクエスト
Invoke-Oauth2RefreshToken "https://oauth2.googleapis.com/token" $info.RefreshToken @{
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
} | Tee-Object -Variable res
Add-Oauth2ClientInfo $info $res | Tee-Object -Variable info
