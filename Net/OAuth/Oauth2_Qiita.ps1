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
# ���O�ɁA$clientId, $clientSecret, $redirectUri ��ݒ肵�Ă����B
$infoPath = Join-Path $home "PsOauth2Client_Qiita.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# �P�D�F���N�G�X�g
# redirect_uri�s�v�BQiita�ɃA�v���P�[�V�����o�^�����Ƃ��̃��_�C���N�g��URL���g����B
# state�p�����[�^��ݒ肷�邱�Ƃ���������邪����͊ȗ����B
$authCode = Invoke-Oauth2UserAuth "https://qiita.com/api/v2/oauth/authorize" $info.ClientId @{
  scope = "read_qiita write_qiita"
  state = "abc"
} -Message $CODE_MSG -Dialog $true

# �Q�D�A�N�Z�X�g�[�N�����N�G�X�g
# state�p�����[�^��ݒ肷�邱�Ƃ���������邪����͊ȗ����B
Invoke-Oauth2AccessToken "https://qiita.com/api/v2/access_tokens" $authCode @{
  client_id = $info.ClientId
  client_secret = $info.ClientSecret
  state = "abc"
} -ContentType 'application/json' | Tee-Object -Variable res | ConvertTo-Json
# ���X�|���X��F{"client_id":"xxx", "scopes":["read_qiita"], "token": "xxx"}
$info.AccessToken = $res.token

# �ۑ�
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# �R�D���\�[�XAPI

# �F�ؒ��̃��[�U
Invoke-Oauth2Api GET "https://qiita.com/api/v2/authenticated_user" $info.AccessToken | Tee-Object -Variable res | ConvertTo-Json
$userId = $res.id

# �L��
# �F�ؒ����[�U�̋L���ꗗ���쐬�����̍~���Ŏ擾
Invoke-Oauth2Api GET "https://qiita.com/api/v2/authenticated_user/items" $info.AccessToken @{
  page = 1
  per_page = 3
} | Tee-Object -Variable res | ConvertTo-Json
$res | Select-Object id, updated_at, title
$itemId = $res[0].id
# �L�����擾
Invoke-Oauth2Api GET "https://qiita.com/api/v2/items/$itemId" $info.AccessToken | ConvertTo-Json

# �V���ɋL�����쐬
Invoke-Oauth2Api POST "https://qiita.com/api/v2/items" $info.AccessToken @{
  title = "Example title"
  body = "# Example"
  private = $true
  tags = @(@{"name"="Ruby"; "versions"=@("0.0.1")})
} -ContentType "application/json" | Tee-Object -Variable res | ConvertTo-Json
$newItemId1 = $res.id
Invoke-Oauth2Api POST "https://qiita.com/api/v2/items" $info.AccessToken @{
  title = "Dummy�L��"
  body = "# Dummy`nDummy�L���ł��B`nDummy�L���ł��B`nDummy�L���ł��B"
  private = $true
  tags = @(@{"name"="PowerShell"})
} -ContentType "application/json;charset=UTF-8" | Tee-Object -Variable res | ConvertTo-Json
$newItemId2 = $res.id

# ��L�ō쐬�����L�����폜
Invoke-Oauth2Api DELETE "https://qiita.com/api/v2/items/$newItemId1" $info.AccessToken
Invoke-Oauth2Api DELETE "https://qiita.com/api/v2/items/$newItemId2" $info.AccessToken

# �^�O
# ���[�U���t�H���[���Ă���^�O�ꗗ���t�H���[�����̍~���Ŏ擾
Invoke-Oauth2Api GET "https://qiita.com/api/v2/users/$userId/following_tags" $info.AccessToken @{
  page = 1
  per_page = 3
} | Tee-Object -Variable res | ConvertTo-Json
$res | Select-Object id, items_count, followers_count
