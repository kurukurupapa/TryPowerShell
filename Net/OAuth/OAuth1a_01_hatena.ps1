# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# �͂Ă�API �œ���m�F����B

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'


# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$DebugPreference = 'Continue'

# �P�D���N�G�X�g�g�[�N��
$params = @{ scope = "read_public,write_public" }
ParseOauthResponse(InvokeOauthApi 'POST' $requestUrl $consumerKey $consumerSecret -callback 'oob' -optionParams $params) | Tee-Object -Variable res

# �Q�D���[�U�F��
InvokeUserAuthorization $res.oauth_token
$verifier = Read-Host "������ʂɕ\�����ꂽ�g�[�N������͂��Ă��������B"

# �R�D�A�N�Z�X�g�[�N��
ParseOauthResponse(InvokeOauthApi 'POST' $accessUrl $consumerKey $consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier) | Tee-Object -Variable res

# �ۑ�
$dataPath = Join-Path $home "PsOauth1aLocalClient_Hatena.dat"
SaveSecretObject $dataPath @{
  consumerKey = $consumerKey
  consumerSecret = $consumerSecret
  requestUrl = $requestUrl
  authUrl = $authUrl
  accessUrl = $accessUrl
  accessToken = $res.oauth_token
  accessTokenSecret = $res.oauth_token_secret
}
LoadSecretObject $dataPath | Tee-Object -Variable data

# ���\�[�XAPI
InvokeOauthApi 'GET' "http://n.hatena.com/applications/my.json" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret

$url = "https://dummy.hatenablog.ne.jp/"
$params = @{
  url = $url
  tags = "PsOauth1aLocalClient"
  comment = "PsOauth1aLocalClient �R�����g `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # NG�L�� !'()*
}
InvokeOauthApi 'POST' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params
$params = @{ url = $url }
InvokeOauthApi 'GET' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params

# TODO
InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params
#=> 401 Unauthorized
InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams $params
#=> {"message":"`url` parameter is required"}
