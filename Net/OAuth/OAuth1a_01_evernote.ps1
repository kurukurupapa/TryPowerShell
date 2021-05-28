# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# Evernote API �œ���m�F����B

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$DebugPreference = 'Continue'
$dataPath = Join-Path $home "PsOauth1aClient_Evernote.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# �P�D���N�G�X�g�g�[�N��
# oauth_callback��oob���ƁA400 Bad Request �ɂȂ�̂ŁAURL��ݒ肷��i���݂��Ȃ��Ă��悢�j�B
$callbackUrl = 'https://dummy.evernote.com'
InvokeRequestToken 'GET' $data.requestUrl $data.consumerKey $data.consumerSecret -callback $callbackUrl | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# �Q�D���[�U�F��
$verifier = InvokeUserAuthorization $data.authUrl $res.oauth_token -dialog -message "�J�ڃG���[��ʂ�URL���� oauth_verifier �̒l����͂��Ă��������B"
# URL�̗�F http://www.sample.com/?oauth_token=xxx&oauth_verifier=xxx&sandbox_lnb=false
# verifier��\��t�����Ƃ��ɁA���X�A������������̂Œ��ӁB

# �R�D�A�N�Z�X�g�[�N��
# ���X�|���X��oauth_token_secret�̓u�����N�ƂȂ�B
InvokeAccessToken 'GET' $data.accessUrl $data.consumerKey $data.consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier | Tee-Object -Variable res
$data.accessToken = $res.oauth_token
$data.accessTokenSecret = $res.oauth_token_secret
$data.edam_shard = $res.edam_shard
$data.edam_userId = $res.edam_userId
$data.edam_expires = $res.edam_expires
$data.edam_noteStoreUrl = $res.edam_noteStoreUrl
$data.edam_webApiUrlPrefix = $res.edam_webApiUrlPrefix

# �ۑ�
$dataPath = Join-Path $home "PsOauth1aClient_Evernote.dat"
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# �S�D���\�[�XAPI
# TODO
# InvokeOauthApi 'POST' "https://sandbox.evernote.com/edam/note/$($data.edam_shard)" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret



# �N���X��
$dataPath = Join-Path $home "PsOauth1aClient_Evernote.dat"
if (Test-Path $dataPath) {
  $client = New-Object Oauth1aClient
  $client.Load($dataPath)
} else {
  # ���O�� $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl ��ݒ肵�Ă���
  $client = New-Object Oauth1aClient($data.consumerKey, $data.consumerSecret, $data.requestUrl, $data.authUrl, $data.accessUrl)
  $client.InvokeRequestToken('GET', 'https://dummy.evernote.com')
  $client.InvokeUserAuthorization($true)
  $client.InvokeAccessToken('GET')
  $client.Save($dataPath)
}
