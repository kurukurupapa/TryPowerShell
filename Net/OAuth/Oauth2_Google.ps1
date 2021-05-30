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
$dataPath = Join-Path $home "PsOauth2Client_Google.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# �P�D�F���N�G�X�g
# state�p�����[�^��ݒ肷�邱�Ƃ���������邪����͏ȗ��B
$authCode = Oauth2AuthCode_InvokeUserAuth $data.authUrl $data.clientId @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  scope = "email profile https://www.googleapis.com/auth/drive.metadata.readonly"
} -message $CODE_MSG -dialog $true

# �Q�D�A�N�Z�X�g�[�N�����N�G�X�g
Oauth2AuthCode_InvokeAccessToken $data.accessUrl $authCode @{
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  client_id = $data.clientId
  client_secret = $data.clientSecret
} | Tee-Object -Variable res
Oauth2_AddResponse $data $res | Tee-Object -Variable data

# �ۑ�
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# �R�D���\�[�XAPI
Oauth2AuthCode_InvokeApi 'GET' "https://www.googleapis.com/drive/v2/files" $data.accessToken | ConvertTo-Json

# �S�D���t���b�V���g�[�N�����N�G�X�g
Oauth2AuthCode_InvokeRefreshToken $data.accessUrl $data.refreshToken @{
  client_id = $data.clientId
  client_secret = $data.clientSecret
} | Tee-Object -Variable res
Oauth2_AddResponse $data $res | Tee-Object -Variable data



# �N���X��
if (Test-Path $dataPath) {
  $client = New-Object Oauth2AuthCodeClient
  $client.Load($dataPath)
} else {
  # ���O�ɁA$clientId, $clientSecret, $redirectUri, $authUrl, $accessUrl ��ݒ肵�Ă����B
  $client = New-Object Oauth2AuthCodeClient($data.clientId, $data.clientSecret, $data.redirectUri, $data.authUrl, $data.accessUrl)
  $client.InvokeUserAuth(@{
    redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
    scope = "email profile https://www.googleapis.com/auth/drive.metadata.readonly"
  }, $CODE_MSG, $true)
  $client.InvokeAccessToken(@{
    redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
    client_id = $client.clientId
    client_secret = $client.clientSecret
  })
  $client.Save($dataPath)
}

$client.InvokeApi('GET', "https://www.googleapis.com/drive/v2/files", $null) | ConvertTo-Json
