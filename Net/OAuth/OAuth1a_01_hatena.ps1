# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# �͂Ă�API �œ���m�F����B

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$DebugPreference = 'Continue'
$dataPath = Join-Path $home "PsOauth1aClient_Hatena.dat"
if (Test-Path $dataPath) {
  LoadSecretObject $dataPath | Tee-Object -Variable data
}

# �P�D���N�G�X�g�g�[�N��
$params = @{ scope = "read_public,write_public,read_private" }
InvokeRequestToken 'POST' $data.requestUrl $data.consumerKey $data.consumerSecret -callback 'oob' -authParams $params | Tee-Object -Variable res

# �Q�D���[�U�F��
$verifier = InvokeUserAuthorization $data.authUrl $res.oauth_token -dialog -message "������ʂɕ\�����ꂽ�g�[�N������͂��Ă��������B"

# �R�D�A�N�Z�X�g�[�N��
InvokeAccessToken 'POST' $data.accessUrl $data.consumerKey $data.consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier | Tee-Object -Variable res
$data.accessToken = $res.oauth_token
$data.accessTokenSecret = $res.oauth_token_secret

# �ۑ�
$dataPath = Join-Path $home "PsOauth1aClient_Hatena.dat"
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# �S�D���\�[�XAPI

# �͂ĂȂ� OAuth �A�v���P�[�V�����p API
# [�͂ĂȂ� OAuth �A�v���P�[�V�����p API - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/nano/apis/oauth)
InvokeOauthApi 'GET' "http://n.hatena.com/applications/my.json" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret
# �����N�G�X�g�g�[�N���擾����scope�ݒ�ɁA�X�R�[�v������Ȃ��ꍇ�A"oauth_problem=additional_authorization_required"���ԋp���ꂽ�B

# �͂Ăȃu�b�N�}�[�N REST API
# [�͂Ăȃu�b�N�}�[�N REST API - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/bookmark/apis/rest/)
$url = "https://dummy.hatenablog.ne.jp/"
$params1 = @{ url = $url }
$params2 = @{
  url = $url
  tags = "PsOauth1aLocalClient"
  comment = "PsOauth1aLocalClient �R�����g `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # NG�L�� !'()*
}
InvokeOauthApi 'POST' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params2
InvokeOauthApi 'GET' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params1
# InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -bodyParams $params1
#=> 401 Unauthorized
# InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams $params1
#=> {"message":"`url` parameter is required"}
InvokeOauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -queryParams $params1
#=> OK
InvokeOauthApi 'GET' "https://bookmark.hatenaapis.com/rest/1/my/tags" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret | ConvertTo-Json
# ��consumer key �̕����o�����ɁAread_private�̃X�R�[�v��t���Ă��Ȃ��ƁA"403 Forbidden Insufficient scope"���ԋp���ꂽ�B

# �͂Ăȃu���OAtomPub
# [�͂Ăȃu���OAtomPub - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/blog/apis/atom)
$hatenaId = "kurukuru-papa"
$blogId = "kurukurupapa.hatenablog.com"
InvokeOauthApi 'GET' "https://blog.hatena.ne.jp/$hatenaId/$blogId/atom" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret
#=> <p class="error-box">oauth_problem=additional_authorization_required</p>
InvokeOauthApi 'GET' "https://blog.hatena.ne.jp/$hatenaId/$blogId/atom/entry" $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret
#=> <p class="error-box">oauth_problem=additional_authorization_required</p>
# ���ǉ��̃X�R�[�v���K�v�Ȗ͗l�B�C���������玎���Ă݂�B



# �N���X��
$dataPath = Join-Path $home "PsOauth1aClient_Hatena.dat"
if (Test-Path $dataPath) {
  $client = New-Object Oauth1aClient
  $client.Load($dataPath)
} else {
  # TODO
  # ���O�� $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl ��ݒ肵�Ă���
  $params = @{ scope = "read_public,write_public,read_private" }
  $client = New-Object Oauth1aClient($data.consumerKey, $data.consumerSecret, $data.requestUrl, $data.authUrl, $data.accessUrl)
  $client.InvokeRequestToken('POST', 'oob', $params, $null)
  $client.InvokeUserAuthorization($true)
  $client.InvokeAccessToken('POST')
  $client.Save($dataPath)
}

# �͂ĂȂ� OAuth �A�v���P�[�V�����p API
$client.Invoke('GET', 'http://n.hatena.com/applications/my.json')

# �͂Ăȃu�b�N�}�[�N REST API
$url = "https://dummy.hatenablog.ne.jp/"
$params1 = @{ url = $url }
$params2 = @{
  url = $url
  tags = "PsOauth1aLocalClient"
  comment = "PsOauth1aLocalClient �R�����g `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # NG�L�� !'()*
}
$client.Invoke('POST', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $params2)
$client.Invoke('GET', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $params1)
$client.Invoke('DELETE', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $null, $params1)
$client.Invoke('GET', "https://bookmark.hatenaapis.com/rest/1/my/tags") | ConvertTo-Json
