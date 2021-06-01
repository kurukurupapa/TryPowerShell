# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# Evernote API �œ���m�F����B

. (Join-Path $PSScriptRoot "OAuth1a_01_oauth.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'

# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$infoPath = Join-Path $home "PsOauth1aClient_Evernote.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# �P�D���N�G�X�g�g�[�N��
# oauth_callback��oob���ƁA400 Bad Request �ɂȂ�̂ŁAURL��ݒ肷��i���݂��Ȃ��Ă��悢�j�B
$callbackUrl = 'https://dummy.evernote.com'
Invoke-RequestToken 'GET' $info.RequestUrl $info.ConsumerKey $info.ConsumerSecret $callbackUrl | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# �Q�D���[�U�F��
$verifier = Invoke-UserAuthorization $info.AuthUrl $res.oauth_token -Dialog -Message "�J�ڃG���[��ʂ�URL���� oauth_verifier �̒l����͂��Ă��������B"
# URL�̗�F http://www.sample.com/?oauth_token=xxx&oauth_verifier=xxx&sandbox_lnb=false
# verifier��\��t�����Ƃ��ɁA���X�A������������̂Œ��ӁB

# �R�D�A�N�Z�X�g�[�N��
# ���X�|���X��oauth_token_secret�̓u�����N�ƂȂ�B
Invoke-AccessToken 'GET' $info.AccessUrl $info.ConsumerKey $info.ConsumerSecret $res.oauth_token $res.oauth_token_secret $verifier | Tee-Object -Variable res
$info.AccessToken = $res.oauth_token
$info.AccessTokenSecret = $res.oauth_token_secret
$info.EdamShard = $res.edam_shard
$info.EdamUserId = $res.edam_userId
$info.EdamExpires = $res.edam_expires
$info.EdamNoteStoreUrl = $res.edam_noteStoreUrl
$info.EdamWebApiUrlPrefix = $res.edam_webApiUrlPrefix

# �ۑ�
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# �S�D���\�[�XAPI
# TODO
# Invoke-OauthApi 'POST' "https://sandbox.evernote.com/edam/note/$($info.EdamShard)" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret



# # �N���X��
# if (Test-Path $infoPath) {
#   $client = New-Object Oauth1aClient
#   $client.Load($infoPath)
# } else {
#   # ���O�� $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl ��ݒ肵�Ă���
#   $client = New-Object Oauth1aClient($info.ConsumerKey, $info.ConsumerSecret, $info.RequestUrl, $info.AuthUrl, $info.AccessUrl)
#   $client.InvokeRequestToken('GET', 'https://dummy.evernote.com')
#   $client.InvokeUserAuthorization($true)
#   $client.InvokeAccessToken('GET')
#   $client.Save($infoPath)
# }
