# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�
# Zaim API �œ���m�F����B
# ZaimAPI�ւ̃A�v���o�^�ł́A�T�[�r�X��ނ��u�N���C�A���g�A�v���v�A�A�N�Z�X���x����ǂݍ��݂݂̂ɂ����B�ł��A�T�[�r�X��ނ��u�u���E�U�A�v���v�ɂ��Ă����삵���B

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

# OAuth�t���[��1�X�e�b�v���m�F
# ���O�ɁA$consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl ��ݒ肵�Ă����B
$DebugPreference = 'Continue'

# �P�D���N�G�X�g�g�[�N��
InvokeRequestToken 'POST' $data.requestUrl $data.consumerKey $data.consumerSecret -callback 'oob' | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx&oauth_callback_confirmed=true

# �Q�D���[�U�F��
InvokeUserAuthorization $data.authUrl $res.oauth_token
$verifier = Read-Host "������ʂɕ\�����ꂽ�g�[�N������͂��Ă��������B"

# �R�D�A�N�Z�X�g�[�N��
InvokeAccessToken 'POST' $data.accessUrl $data.consumerKey $data.consumerSecret -token $res.oauth_token -tokenSecret $res.oauth_token_secret -verifier $verifier | Tee-Object -Variable res
#=> oauth_token=xxx&oauth_token_secret=xxx
$data.accessToken = $res.oauth_token
$data.accessTokenSecret = $res.oauth_token_secret

# �ۑ�
$dataPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
SaveSecretObject $dataPath $data
LoadSecretObject $dataPath | Tee-Object -Variable data

# �S�D���\�[�XAPI
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/user/verify' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret | ConvertTo-Json
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/account' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/category' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/genre' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams @{ mapping = 1 } | ConvertTo-Json
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
InvokeOauthApi 'GET' 'https://api.zaim.net/v2/home/money' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret $params -body $params | ConvertTo-Json
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
InvokeOauthApi 'POST' 'https://api.zaim.net/v2/home/money/income' $data.consumerKey $data.consumerSecret -token $data.accessToken -tokenSecret $data.accessTokenSecret -optionParams $params -body $params | ConvertTo-Json



# �N���X��
$dataPath = Join-Path $home "PsOauth1aClient_Zaim.dat"
if (Test-Path $dataPath) {
  $client = New-Object Oauth1aClient
  $client.Load($dataPath)
} else {
  # ���O�� $consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl, $callbackUrl ��ݒ肵�Ă���
  $client = New-Object Oauth1aClient($data.consumerKey, $data.consumerSecret, $data.requestUrl, $data.authUrl, $data.accessUrl)
  $client.InvokeRequestToken('POST', 'oob')
  $client.InvokeUserAuthorization()
  $client.InvokeAccessToken('POST')
  $client.Save($dataPath)
}

$client.Invoke('GET', 'https://api.zaim.net/v2/home/user/verify') | ConvertTo-Json
$client.Invoke('GET', 'https://api.zaim.net/v2/home/account', @{body=@{mapping=1}}) | ConvertTo-Json
$client.Invoke('GET', 'https://api.zaim.net/v2/home/category', @{body=@{mapping=1}}) | ConvertTo-Json
$client.Invoke('GET', 'https://api.zaim.net/v2/home/genre', @{body=@{mapping=1}}) | ConvertTo-Json
$params = @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}
$client.Invoke('GET', 'https://api.zaim.net/v2/home/money', @{body=$params}) | ConvertTo-Json
$client.Invoke('GET', 'https://api.zaim.net/v2/home/money', $null, $params, $null) | ConvertTo-Json
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
$client.Invoke('POST', 'https://api.zaim.net/v2/home/money/income', @{body=$params}) | ConvertTo-Json
