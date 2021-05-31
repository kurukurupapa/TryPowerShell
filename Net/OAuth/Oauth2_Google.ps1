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
  scope = "email profile https://www.googleapis.com/auth/drive.metadata.readonly"
} -Message $CODE_MSG -Dialog $true

# �Q�D�A�N�Z�X�g�[�N�����N�G�X�g
Invoke-Oauth2AccessToken "https://oauth2.googleapis.com/token" $authCode @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
} | Tee-Object -Variable res
Add-OauthClientInfo $info $res | Tee-Object -Variable info

# �ۑ�
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# �R�D���\�[�XAPI
Invoke-Oauth2Api 'GET' "https://www.googleapis.com/drive/v2/files" $info.AccessToken | ConvertTo-Json

# �S�D���t���b�V���g�[�N�����N�G�X�g
Invoke-Oauth2RefreshToken "https://oauth2.googleapis.com/token" $info.RefreshToken @{
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
} | Tee-Object -Variable res
Add-OauthClientInfo $info $res | Tee-Object -Variable info
