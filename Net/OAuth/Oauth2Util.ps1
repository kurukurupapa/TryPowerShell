# PowerShell標準機能で OAuth 2.0 クライアントを作成してみる
# ユーティリティ関数

. (Join-Path $PSScriptRoot "OauthUtil.ps1")
$OAUTH2_CODE_MSG = "完了画面に表示されたコード、または完了/遷移エラー画面のURLからcodeの値を入力してください。"
$OAUTH2_USER_AGENT = "PsOauth2Client"

function Oauth2_ReadUserCode($message=$OAUTH2_CODE_MSG, $dialog) {
  return ReadUserInput $message $dialog
}

function Oauth2_AddResponse($base, $response) {
  $response.psobject.properties | ForEach-Object {
    $name = ToCamelCase $_.Name
    if ($base -is [Object]) {
      Add-Member -InputObject $base -MemberType NoteProperty -Name $name -Value $_.Value -Force
    } else {
      $base[$name] = $_.Value
    }
  }
  return $base
}
