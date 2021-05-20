# PowerShell�W���@�\�� OAuth 1.0a �N���C�A���g���쐬���Ă݂�

# Zaim API �œ���m�F����B
# ZaimAPI�ւ̃A�v���o�^�ł́A�T�[�r�X��ނ��u�N���C�A���g�A�v���v�A�A�N�Z�X���x����ǂݍ��݂݂̂ɂ����B
# �ł��A�T�[�r�X��ނ��u�u���E�U�A�v���v�ɂ��Ă����삵���B

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

$oauthPath = Join-Path $home "PSOAuth1aLocalClient_Zaim.dat"
if (Test-Path $oauthPath) {
  $client = New-Object OAuth1aLocalClient
  $client.Load($oauthPath)
} else {
  $client = New-Object OAuth1aLocalClient($consumerKey, $consumerSecret, $requestUrl, $authUrl, $accessUrl)
  $client.InvokeOauthFlow()
  $client.Save($oauthPath)
}

$client.Invoke('GET', 'https://api.zaim.net/v2/home/user/verify') | ConvertTo-Json -Depth 100 | %{ Write-Host $_ }
$client.Invoke('GET', 'https://api.zaim.net/v2/home/account', @{ mapping = 1 }) | ConvertTo-Json -Depth 100 | %{ Write-Host $_ }
$client.Invoke('GET', 'https://api.zaim.net/v2/home/category', @{ mapping = 1 }) | ConvertTo-Json -Depth 100 | %{ Write-Host $_ }
$client.Invoke('GET', 'https://api.zaim.net/v2/home/genre', @{ mapping = 1 }) | ConvertTo-Json -Depth 100 | %{ Write-Host $_ }
$client.Invoke('GET', 'https://api.zaim.net/v2/home/money', @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}) | ConvertTo-Json -Depth 100 | %{ Write-Host $_ }
$client.Invoke('POST', 'https://api.zaim.net/v2/home/money', @{
  mapping = 1
  start_date = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
  end_date = Get-Date -Format "yyyy-MM-dd"
}) | ConvertTo-Json -Depth 100 | %{ Write-Host $_ }
