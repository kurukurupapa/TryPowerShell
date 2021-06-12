<#
.SYNOPSIS
  PowerShell�W���@�\�� OAuth 2.0 �N���C�A���g���쐬�iGoogle API�j
.DESCRIPTION
  �Q�l
  [OAuth 2.0 for Mobile & Desktop Apps ?|? Google Identity Platform](https://developers.google.com/identity/protocols/oauth2/native-app)
  [GoogleAPI��OAuth2.0�X�R�[�v ?|? Google Identity Platform ?|? Google Developers](https://developers.google.com/identity/protocols/oauth2/scopes)
  �O��
  Google Cloud Platform �� OAuth 2.0 �N���C�A���g��o�^���A�N���C�A���gID�A�N���C�A���g�V�[�N���b�g�𕥂��o���Ă����B
  [�z�[�� ? Test01 ? Google Cloud Platform](https://console.cloud.google.com/home/dashboard?project=test01-e645b)
#>

. (Join-Path $PSScriptRoot "Oauth2AuthCodeClient.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
# $DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'
$CODE_MSG = "������ʂɕ\�����ꂽ�R�[�h����͂��Ă��������B"

# OAuth�t���[��1�X�e�b�v���m�F�i�F�R�[�h�O�����g�^�C�v�j
# ���O�ɁA$clientId, $clientSecret, $redirectUri, $authUrl, $accessUrl ��ݒ肵�Ă����B
$infoPath = Join-Path $home "PsOauth2Client_Google.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# �P�D�F���N�G�X�g
# state�p�����[�^��ݒ肷�邱�Ƃ���������邪����͏ȗ��B
$authCode = Invoke-Oauth2UserAuth "https://accounts.google.com/o/oauth2/v2/auth" $info.ClientId @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  scope = "email profile" +
    " https://www.googleapis.com/auth/drive.metadata.readonly" +
    # " https://www.googleapis.com/auth/tasks.readonly"
    " https://www.googleapis.com/auth/tasks"
} -Message $CODE_MSG -Dialog $true

# �Q�D�A�N�Z�X�g�[�N�����N�G�X�g
Invoke-Oauth2AccessToken "https://oauth2.googleapis.com/token" $authCode @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
} | Tee-Object -Variable res
Add-Oauth2ClientInfo $info $res | Tee-Object -Variable info

# �ۑ�
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# �R�D���\�[�XAPI

# Google Drive API
# [Introduction to Google Drive API ?|? Google Developers](https://developers.google.com/drive/api/v3/about-sdk)
Invoke-Oauth2Api GET "https://www.googleapis.com/drive/v3/files" $info.AccessToken | ConvertTo-Json

# Google Tasks API
# [Overview ?|? Tasks API ?|? Google Developers](https://developers.google.com/tasks)
# TaskList �ǉ�
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/users/@me/lists" $info.AccessToken @{
  title = "PsOauth2Client TaskList 01"
} -ContentType "application/json" | Tee-Object -Variable taskListRes | ConvertTo-Json
# TaskList �ύX
Invoke-Oauth2Api PATCH "https://tasks.googleapis.com/tasks/v1/users/@me/lists/$($taskListRes.id)" $info.AccessToken @{
  title = "PsOauth2Client TaskList 01b"
} -ContentType "application/json" | ConvertTo-Json
Invoke-Oauth2Api PUT "https://tasks.googleapis.com/tasks/v1/users/@me/lists/$($taskListRes.id)" $info.AccessToken @{
  id = $taskListRes.id # id���Ȃ��ƃG���[�ɂȂ�
  title = "PsOauth2Client TaskList 01c"
} -ContentType "application/json" | ConvertTo-Json
# TaskList �擾
Invoke-Oauth2Api GET "https://tasks.googleapis.com/tasks/v1/users/@me/lists/$($taskListRes.id)" $info.AccessToken | ConvertTo-Json
# TaskList �ꗗ
Invoke-Oauth2Api GET "https://tasks.googleapis.com/tasks/v1/users/@me/lists" $info.AccessToken | ConvertTo-Json
# Task �ǉ�
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks" $info.AccessToken @{
  title = "�^�X�N1"
  notes = "�^�X�N�̏ڍׂł��B"
  due = (Get-Date).AddDays(1).ToString("o")
} -ContentType "application/json" | Tee-Object -Variable taskRes | ConvertTo-Json
# Task �ǉ��i�q�^�X�N�j
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks" $info.AccessToken @{
  title = "�^�X�N2"
} -ContentType "application/json" | Tee-Object -Variable task2Res | ConvertTo-Json
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($task2Res.id)/move" $info.AccessToken @{
  parent = $taskRes.id
} -ContentType "application/json" | ConvertTo-Json
# Task �ύX
Invoke-Oauth2Api PATCH "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($taskRes.id)" $info.AccessToken @{
  title = "�^�X�N1b"
} -ContentType "application/json" | ConvertTo-Json
Invoke-Oauth2Api PUT "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($taskRes.id)" $info.AccessToken @{
  id = $taskRes.id # id���Ȃ��ƃG���[�ɂȂ�
  title = "�^�X�N1c"
  status = "completed"
} -ContentType "application/json" | ConvertTo-Json
# Task �擾
Invoke-Oauth2Api GET "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($taskRes.id)" $info.AccessToken | ConvertTo-Json
# Task �ꗗ
Invoke-Oauth2Api GET "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks" $info.AccessToken | ConvertTo-Json
# Task �폜
Invoke-Oauth2Api DELETE "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/tasks/$($taskRes.id)" $info.AccessToken
Invoke-Oauth2Api POST "https://tasks.googleapis.com/tasks/v1/lists/$($taskListRes.id)/clear" $info.AccessToken
# TaskList �폜
Invoke-Oauth2Api DELETE "https://tasks.googleapis.com/tasks/v1/users/@me/lists/$($taskListRes.id)" $info.AccessToken

# �S�D���t���b�V���g�[�N�����N�G�X�g
Invoke-Oauth2RefreshToken "https://oauth2.googleapis.com/token" $info.RefreshToken @{
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
} | Tee-Object -Variable res
Add-Oauth2ClientInfo $info $res | Tee-Object -Variable info
