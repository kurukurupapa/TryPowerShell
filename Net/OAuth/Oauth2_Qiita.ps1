<#
.SYNOPSIS
  PowerShell�W���@�\�� OAuth 2.0 �N���C�A���g���쐬�iQiita API�j
.DESCRIPTION
  �Q�l
  [Qiita API v2�h�L�������g - Qiita:Developer](https://qiita.com/api/v2/docs)
  �O��
  Qiita�A�J�E���g�ݒ�ŁA�A�v���P�[�V������o�^���A�N���C�A���gID�A�N���C�A���g�V�[�N���b�g�𕥂��o���Ă����B
  [Qiita](https://qiita.com/settings/applications)
#>

. (Join-Path $PSScriptRoot "Oauth2AuthCodeClient.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
# $DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'
$CODE_MSG = "�J�ڃG���[��ʂ�URL����code�̒l����͂��Ă��������B"

# OAuth�t���[��1�X�e�b�v���m�F�i�F�R�[�h�O�����g�^�C�v�j
# ���O�ɁA$clientId, $clientSecret, $redirectUri, $authUrl, $accessUrl ��ݒ肵�Ă����B
$dataPath = Join-Path $home "PsOauth2Client_Qiita.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# �P�D�F���N�G�X�g
# redirect_uri�s�v�BQiita�ɃA�v���P�[�V�����o�^�����Ƃ��̃��_�C���N�g��URL���g����B
# state�p�����[�^��ݒ肷�邱�Ƃ���������邪����͊ȗ����B
$authCode = Oauth2AuthCode_InvokeUserAuth $data.authUrl $data.clientId @{
  scope = "read_qiita write_qiita"
  state = "abc"
} -message $CODE_MSG -dialog $true

# �Q�D�A�N�Z�X�g�[�N�����N�G�X�g
# state�p�����[�^��ݒ肷�邱�Ƃ���������邪����͊ȗ����B
Oauth2AuthCode_InvokeAccessToken $data.accessUrl $authCode @{
  client_id = $data.clientId
  client_secret = $data.clientSecret
  state = "abc"
} -contentType 'application/json' | Tee-Object -Variable res | ConvertTo-Json
# ���X�|���X��F{"client_id":"xxx", "scopes":["read_qiita"], "token": "xxx"}
$data.accessToken = $res.token

# �ۑ�
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# �R�D���\�[�XAPI

# �F�ؒ��̃��[�U
Oauth2AuthCode_InvokeApi 'GET' "https://qiita.com/api/v2/authenticated_user" $data.accessToken | Tee-Object -Variable res | ConvertTo-Json
$userId = $res.id

# �L��
# �F�ؒ����[�U�̋L���ꗗ���쐬�����̍~���Ŏ擾
Oauth2AuthCode_InvokeApi GET "https://qiita.com/api/v2/authenticated_user/items" $data.accessToken @{
  page = 1
  per_page = 3
} | Tee-Object -Variable res | ConvertTo-Json
$res | Select-Object id, updated_at, title
$itemId = $res[0].id
# �L�����擾
Oauth2AuthCode_InvokeApi GET "https://qiita.com/api/v2/items/$itemId" $data.accessToken | ConvertTo-Json

# �V���ɋL�����쐬
Oauth2AuthCode_InvokeApi POST "https://qiita.com/api/v2/items" $data.accessToken @{
  title = "Example title"
  body = "# Example"
  private = $true
  tags = @(@{"name"="Ruby"; "versions"=@("0.0.1")})
} -contentType "application/json" | Tee-Object -Variable res | ConvertTo-Json
$newItemId1 = $res.id
Oauth2AuthCode_InvokeApi POST "https://qiita.com/api/v2/items" $data.accessToken @{
  title = "Dummy�L��"
  body = "# Dummy`nDummy�L���ł��B`nDummy�L���ł��B`nDummy�L���ł��B"
  private = $true
  tags = @(@{"name"="PowerShell"})
} -contentType "application/json;charset=UTF-8" | Tee-Object -Variable res | ConvertTo-Json
$newItemId2 = $res.id

# ��L�ō쐬�����L�����폜
Oauth2AuthCode_InvokeApi DELETE "https://qiita.com/api/v2/items/$newItemId1" $data.accessToken
Oauth2AuthCode_InvokeApi DELETE "https://qiita.com/api/v2/items/$newItemId2" $data.accessToken

# �^�O
# ���[�U���t�H���[���Ă���^�O�ꗗ���t�H���[�����̍~���Ŏ擾
Oauth2AuthCode_InvokeApi GET "https://qiita.com/api/v2/users/$userId/following_tags" $data.accessToken @{
  page = 1
  per_page = 3
} | Tee-Object -Variable res | ConvertTo-Json
$res | Select-Object id, items_count, followers_count
