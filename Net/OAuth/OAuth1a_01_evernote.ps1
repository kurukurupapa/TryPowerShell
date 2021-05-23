# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# Evernote API �œ���m�F����B

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$DebugPreference = 'Continue'

# �P�D���N�G�X�g�g�[�N��
# oauth_callback��oob���ƁA400 Bad Request �ɂȂ�̂ŁAURL��ݒ肷��i���݂��Ȃ��Ă��悢�j�B
$callbackUrl = 'https://dummy.evernote.com'
ParseOauthResponse(InvokeOauthApi 'GET' $requestUrl $consumerKey $consumerSecret -callback $callbackUrl) | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# �Q�D���[�U�F��
InvokeUserAuthorization $res.oauth_token
$verifier = Read-Host "�J�ڃG���[��ʂ�URL���� oauth_verifier �̒l����͂��Ă��������B"
#=> http://www.sample.com/?oauth_token=xxx&oauth_verifier=xxx&sandbox_lnb=false

# �R�D�A�N�Z�X�g�[�N��
# ���X�|���X��oauth_token_secret�̓u�����N�ƂȂ�B
ParseOauthResponse(InvokeOauthApi 'GET' $accessUrl $consumerKey $consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier) | Tee-Object -Variable res

# �ۑ�
$dataPath = Join-Path $home "PsOauth1aLocalClient_Evernote.dat"
SaveSecretObject $dataPath @{
  consumerKey = $consumerKey
  consumerSecret = $consumerSecret
  requestUrl = $requestUrl
  authUrl = $authUrl
  accessUrl = $accessUrl
  accessToken = $res.oauth_token
  accessTokenSecret = $res.oauth_token_secret
  edam_shard = $res.edam_shard
  edam_userId = $res.edam_userId
  edam_expires = $res.edam_expires
  edam_noteStoreUrl = $res.edam_noteStoreUrl
  edam_webApiUrlPrefix = $res.edam_webApiUrlPrefix
}
LoadSecretObject $dataPath | Tee-Object -Variable data

# �S�D���\�[�XAPI
# TODO
