# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# �͂Ă�API �œ���m�F����B

. (Join-Path $PSScriptRoot "OAuth1a_01_oauth.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'

# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$infoPath = Join-Path $home "PsOauth1aClient_Hatena.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable data
}

# �P�D���N�G�X�g�g�[�N��
$params = @{ scope = "read_public,write_public,read_private" }
Invoke-RequestToken POST $info.RequestUrl $info.ConsumerKey $info.ConsumerSecret 'oob' -AuthParams $params | Tee-Object -Variable res

# �Q�D���[�U�F��
$verifier = Invoke-UserAuthorization $info.AuthUrl $res.oauth_token -Dialog -Message "������ʂɕ\�����ꂽ�g�[�N������͂��Ă��������B"

# �R�D�A�N�Z�X�g�[�N��
Invoke-AccessToken POST $info.AccessUrl $info.ConsumerKey $info.ConsumerSecret $res.oauth_token $res.oauth_token_secret $verifier | Tee-Object -Variable res
$info.AccessToken = $res.oauth_token
$info.AccessTokenSecret = $res.oauth_token_secret

# �ۑ�
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable data

# �S�D���\�[�XAPI

# �͂ĂȂ� OAuth �A�v���P�[�V�����p API
# [�͂ĂȂ� OAuth �A�v���P�[�V�����p API - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/nano/apis/oauth)
Invoke-OauthApi GET "http://n.hatena.com/applications/my.json" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret
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
Start-Sleep 1
Invoke-OauthApi POST "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params2
Start-Sleep 1
Invoke-OauthApi GET "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params1
Start-Sleep 1
# Invoke-OauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params1
#=> 401 Unauthorized
# Invoke-OauthApi 'DELETE' "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -OptionParams $params1
#=> {"message":"`url` parameter is required"}
Invoke-OauthApi DELETE "https://bookmark.hatenaapis.com/rest/1/my/bookmark" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -QueryParams $params1
#=> OK
Start-Sleep 1
Invoke-OauthApi GET "https://bookmark.hatenaapis.com/rest/1/my/tags" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret | ConvertTo-Json
# ��consumer key �̕����o�����ɁAread_private�̃X�R�[�v��t���Ă��Ȃ��ƁA"403 Forbidden Insufficient scope"���ԋp���ꂽ�B

# �͂Ăȃu���OAtomPub
# [�͂Ăȃu���OAtomPub - Hatena Developer Center](http://developer.hatena.ne.jp/ja/documents/blog/apis/atom)
# $hatenaId = "kurukuru-papa"
# $blogId = "kurukurupapa.hatenablog.com"
# Invoke-OauthApi GET "https://blog.hatena.ne.jp/$hatenaId/$blogId/atom" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret
#=> <p class="error-box">oauth_problem=additional_authorization_required</p>
# Invoke-OauthApi GET "https://blog.hatena.ne.jp/$hatenaId/$blogId/atom/entry" $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret
#=> <p class="error-box">oauth_problem=additional_authorization_required</p>
# ���ǉ��̃X�R�[�v���K�v�Ȗ͗l�B�C���������玎���Ă݂�B



# # �N���X��
# if (Test-Path $infoPath) {
#   $client = New-Object Oauth1aClient
#   $client.Load($infoPath)
# } else {
#   # TODO
#   # ���O�� $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl ��ݒ肵�Ă���
#   $params = @{ scope = "read_public,write_public,read_private" }
#   $client = New-Object Oauth1aClient($info.ConsumerKey, $info.ConsumerSecret, $info.RequestUrl, $info.AuthUrl, $info.AccessUrl)
#   $client.InvokeRequestToken('POST', 'oob', $params, $null)
#   $client.InvokeUserAuthorization($true)
#   $client.InvokeAccessToken('POST')
#   $client.Save($infoPath)
# }
# 
# # �͂ĂȂ� OAuth �A�v���P�[�V�����p API
# $client.Invoke('GET', 'http://n.hatena.com/applications/my.json')
# 
# # �͂Ăȃu�b�N�}�[�N REST API
# $url = "https://dummy.hatenablog.ne.jp/"
# $params1 = @{ url = $url }
# $params2 = @{
#   url = $url
#   tags = "PsOauth1aLocalClient"
#   comment = "PsOauth1aLocalClient �R�����g `"#$%&+,-./:;<=>?@[\]^_`{|}~"
#   # NG�L�� !'()*
# }
# $client.Invoke('POST', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $params2)
# $client.Invoke('GET', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $params1)
# $client.Invoke('DELETE', "https://bookmark.hatenaapis.com/rest/1/my/bookmark", $null, $null, $params1)
# $client.Invoke('GET', "https://bookmark.hatenaapis.com/rest/1/my/tags") | ConvertTo-Json
