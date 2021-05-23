# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# Zaim API �œ���m�F����B
# ZaimAPI�ւ̃A�v���o�^�ł́A�T�[�r�X��ނ��u�N���C�A���g�A�v���v�A�A�N�Z�X���x����ǂݍ��݂݂̂ɂ����B
# �ł��A�T�[�r�X��ނ��u�u���E�U�A�v���v�ɂ��Ă����삵���B

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$DebugPreference = 'Continue'

# ���N�G�X�g�g�[�N��
ParseOauthResponse(InvokeOauthApi 'POST' $requestUrl $consumerKey $consumerSecret -callback 'oob') | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# ���[�U�F��
InvokeUserAuthorization $res.oauth_token
$verifier = Read-Host "������ʂɕ\�����ꂽ�g�[�N������͂��Ă��������B"

# �A�N�Z�X�g�[�N��
ParseOauthResponse(InvokeOauthApi 'POST' $accessUrl $consumerKey $consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier) | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx

# �ۑ�
$dataPath = Join-Path $home "PsOauth1aLocalClient_Zaim.dat"
$data = @{
  consumerKey = $consumerKey
  consumerSecret = $consumerSecret
  requestUrl = $requestUrl
  authUrl = $authUrl
  accessUrl = $accessUrl
  accessToken = $res.oauth_token
  accessTokenSecret = $res.oauth_token_secret
}
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath

# ���\�[�XAPI
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/user/verify' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret | ConvertTo-Json -Depth 100
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/account' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json -Depth 100
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/category' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json -Depth 100
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/genre' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json -Depth 100
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/money' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret $params -body $params | ConvertTo-Json -Depth 100
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
InvokeOauthApi 'POST' 'https://api.zaim.net/v2/home/money/income' $consumerKey $consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams $params -body $params | ConvertTo-Json -Depth 100

# �N���X��
$dataPath = Join-Path $home "PsOauth1aLocalClient_Zaim.dat"
if (Test-Path $dataPath) {
  $client = New-Object Oauth1aLocalClient
  $client.Load($dataPath)
} else {
  # ���O�� $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl ��ݒ肵�Ă���
  $client = New-Object Oauth1aLocalClient($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl)
  $client.InvokeOauthFlow()
  $client.Save($dataPath)
}

$client.Invoke('GET', 'https://api.zaim.net/v2/home/user/verify') | ConvertTo-Json -Depth 100
$client.Invoke('GET', 'https://api.zaim.net/v2/home/account', @{ mapping = 1 }) | ConvertTo-Json -Depth 100
$client.Invoke('GET', 'https://api.zaim.net/v2/home/category', @{ mapping = 1 }) | ConvertTo-Json -Depth 100
$client.Invoke('GET', 'https://api.zaim.net/v2/home/genre', @{ mapping = 1 }) | ConvertTo-Json -Depth 100
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
$client.Invoke('GET', 'https://api.zaim.net/v2/home/money', $params, $params) | ConvertTo-Json -Depth 100
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
$client.Invoke('POST', 'https://api.zaim.net/v2/home/money/income', $params, $params) | ConvertTo-Json -Depth 100
