# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# Zaim API �œ���m�F����B
# ZaimAPI�ւ̃A�v���o�^�ł́A�T�[�r�X��ނ��u�N���C�A���g�A�v���v�A�A�N�Z�X���x����ǂݍ��݂݂̂ɂ����B�ł��A�T�[�r�X��ނ��u�u���E�U�A�v���v�ɂ��Ă����삵���B

. (Join-Path $PSScriptRoot "OAuth1a_01_oauth.ps1")
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'
$DebugPreference = 'Continue'

# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$infoPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
if (Test-Path $infoPath) {
  Import-OauthClientInfo $infoPath | Tee-Object -Variable info
}

# �P�D���N�G�X�g�g�[�N��
Invoke-RequestToken POST $info.RequestUrl $info.ConsumerKey $info.ConsumerSecret 'oob' | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# �Q�D���[�U�F��
$verifier = Invoke-UserAuthorization $info.AuthUrl $res.oauth_token -Dialog -Message "������ʂɕ\�����ꂽ�g�[�N������͂��Ă��������B"

# �R�D�A�N�Z�X�g�[�N��
Invoke-AccessToken POST $info.AccessUrl $info.ConsumerKey $info.ConsumerSecret $res.oauth_token $res.oauth_token_secret $verifier | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx
$info.AccessToken = $res.oauth_token
$info.AccessTokenSecret = $res.oauth_token_secret

# �ۑ�
Export-OauthClientInfo $infoPath $info
Import-OauthClientInfo $infoPath | Tee-Object -Variable info

# �S�D���\�[�XAPI
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/user/verify' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret | ConvertTo-Json
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/account' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -AuthParams @{ mapping = 1 } | ConvertTo-Json
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/category' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -AuthParams @{ mapping = 1 } | ConvertTo-Json
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/genre' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -AuthParams @{ mapping = 1 } | ConvertTo-Json
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
Invoke-OauthApi GET 'https://api.zaim.net/v2/home/money' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params | ConvertTo-Json
$params = @{
  mapping = 1
  category_id = 19
  date = Get-Date -Format "yyyy-MM-dd"
  amount = 1000000
  to_account_id = 1
  place = "Dummy �_�~�[ �V���b�v"
  comment = "OAuth 1.0a Client Test `"#$%&+,-./:;<=>?@[\]^_`{|}~"
  # comment = "OAuth 1.0a Client Test !`"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
  # NG�L�� !'()*
}
Invoke-OauthApi POST 'https://api.zaim.net/v2/home/money/income' $info.ConsumerKey $info.ConsumerSecret $info.AccessToken $info.AccessTokenSecret -BodyParams $params | ConvertTo-Json



# # �N���X��
# $infoPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
# if (Test-Path $infoPath) {
#   $client = New-Object Oauth1aClient
#   $client.Load($infoPath)
# } else {
#   # ���O�� $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl ��ݒ肵�Ă���
#   $client = New-Object Oauth1aClient($info.ConsumerKey, $info.ConsumerSecret, $info.RequestUrl, $info.AuthUrl, $info.AccessUrl)
#   $client.InvokeRequestToken('POST', 'oob')
#   $client.InvokeUserAuthorization($true)
#   $client.InvokeAccessToken('POST')
#   $client.Save($infoPath)
# }
# 
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/user/verify') | ConvertTo-Json
# $params = @{ mapping = 1 }
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/account', $null, $params) | ConvertTo-Json
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/category', $null, $params) | ConvertTo-Json
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/genre', $null, $params) | ConvertTo-Json
# $params = @{
#   mapping = 1
#   start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
#   end_date = Get-Date -Format "yyyy-MM-dd"
# }
# $client.Invoke('GET', 'https://api.zaim.net/v2/home/money', $null, $params) | ConvertTo-Json
# $params = @{
#   mapping = 1
#   category_id = 19
#   date = Get-Date -Format "yyyy-MM-dd"
#   amount = 1000000
#   to_account_id = 1
#   place = "Dummy �_�~�[ �V���b�v"
#   comment = "OAuth 1.0a Client Test `"#$%&+,-./:;<=>?@[\]^_`{|}~"
#   # comment = "OAuth 1.0a Client Test !`"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
#   # NG�L�� !'()*
# }
# $client.Invoke('POST', 'https://api.zaim.net/v2/home/money/income', $null, $params) | ConvertTo-Json
