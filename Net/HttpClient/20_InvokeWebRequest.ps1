<#

# HTTP�N���C�A���g

HTTP�A�N�Z�X���邽�߂̃N���C�A���g�@�\�́AInvoke-WebRequest�R�}���h���b�g�AInvoke-RestMethod�R�}���h���b�g�Ƃ��Ē񋟂���Ă��܂����B
�������APowerShell 3.0 �ȍ~�ł��B
�Â����ł́A�����̃R�}���h���b�g���g���Ȃ��̂ŁA�ւ��� .NET Framework ���g�����ƂŁA�����ł��܂����B

��v�R�}���h���b�g/�N���X

- Invoke-WebRequest�R�}���h���b�g�FPowerShell 3.0 �ȍ~
- Invoke-RestMethod�R�}���h���b�g�FPowerShell 3.0 �ȍ~
- System.Net.Http.HttpClient�N���X�F.NET Framework 4.5 �ȍ~�i�Ȃ̂ŁAPowerShell 4.0 �ȍ~�j
- System.Net.WebClient�N���X�F.NET Framework 1.1 �ȍ~�i�Ȃ̂ŁA�ǂ�PowerShell�o�[�W�����ł��g�p�\�j

## Invoke-WebRequest�R�}���h���b�g GET���\�b�h

��FGoogle����

#>
$url = 'https://www.google.com/search'
$params = @{"q"="Powershell"}

# �����P�D�R���e���c�����X�|���X�I�u�W�F�N�g�Ƃ��Ď擾
$res = Invoke-WebRequest $url -Body $params
# MakeMd SKIP_START
$res.StatusCode.ToString() + " " + $res.StatusDescription 
$res.Headers
$res.Content.Substring(0, 1000)
# MakeMd SKIP_END

# �����Q�D�R���e���c���t�@�C���ɕۑ�
Invoke-WebRequest $url -Body $params -OutFile 'D:\tmp\out.txt'
# MakeMd SKIP_START
Get-Content 'D:\tmp\out.txt' | Select-Object -First 5
# MakeMd SKIP_END

# �����R�D�G���[�l��
try {
  $res = Invoke-WebRequest $url -Body $params 
  $res.StatusCode.ToString() + " " + $res.StatusDescription 
  $res.Headers
  $res.Content
} catch {
  $error[0].Exception.Response.StatusCode.value__
}
<#

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iGET�j

#>
$clientid = "���Ȃ��� Yahoo! JAPAN WebAPI �p�N���C�A���gID ��ݒ肷��"
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$params = @{
  "appid" = $clientid;
  "results" = "ma,uniq";
  "uniq_filter" = "9|10";
  "sentence" = "��ɂ͓�H�j���g��������B"}
$res = Invoke-WebRequest $url -Body $params
$xmlobj = [Xml]$res.Content
$xmlobj.OuterXml
<#

## Invoke-WebRequest�R�}���h���b�g POST���\�b�h

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iPOST�j

#>
$url = "https://jlp.yahooapis.jp/MAService/V1/parse" 
$headers = @{
  "User-Agent" = "Yahoo AppID: $clientid";
  "Content-Type" = "application/x-www-form-urlencoded"}

# �����P�DPOST�f�[�^�𕶎���Ŏw��B
$poststr = "results=ma,uniq" +
  "&uniq_filter=" + [System.Web.HttpUtility]::UrlEncode("9|10") +
  "&sentence=" + [System.Web.HttpUtility]::UrlEncode("��ɂ͓�H�j���g��������B")
$res = Invoke-WebRequest $url -Method 'POST' -Headers $headers -Body $poststr
$xmlobj = [Xml]$res.Content
$xmlobj.OuterXml

# �����Q�DPOST�f�[�^��A�z�z��Ŏw��B������URL�G���R�[�h�����B
$params = @{
  "results" = "ma,uniq"; 
  "uniq_filter" = "9|10"; 
  "sentence" = "��ɂ͓�H�j���g��������B"}
$res = Invoke-WebRequest $url -Method 'POST' -Headers $headers -Body $params
$xmlobj = [Xml]$res.Content
$xmlobj.OuterXml
<#

��F���{��W��󂯉�́iPOST���\�b�h�AJSON���N�G�X�g�j

#>
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$headers = @{
  "User-Agent" = "Yahoo AppID: $clientid";
  "Content-Type" = "application/x-www-form-urlencoded"}
# JSON���N�G�X�g�B����ASCII���������Ȃ�G���R�[�h�s�v�B
$poststr = ConvertTo-Json @{
  id="123"; jsonrpc="2.0"; method="jlp.daservice.parse";
  params=@{q="�����̒�ɂ͓�H�{�����܂�"}}
$postbytes = [System.Text.Encoding]::UTF8.GetBytes($poststr)
$res = Invoke-WebRequest $url -Method 'POST' -Headers $headers -Body $postbytes
$jsonobj = ConvertFrom-Json $res.Content
Write-Output (ConvertTo-Json $jsonobj -Depth 100)
<#

## Invoke-RestMethod�R�}���h���b�g GET���\�b�h

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iGET�j

#>
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$params = @{
  "appid" = $clientid;
  "results" = "ma,uniq";
  "uniq_filter" = "9|10";
  "sentence" = "��ɂ͓�H�j���g��������B"}
$xmldoc = Invoke-RestMethod $url -Body $params
Write-Output $xmldoc.OuterXml

# �G���[���l������ꍇ
try {
  $xmldoc = Invoke-RestMethod $url -Body $params
  Write-Output $xmldoc.OuterXml
} catch {
  $error[0].Exception.Response.StatusCode.value__
}
<#

## Invoke-RestMethod�R�}���h���b�g POST���\�b�h

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iPOST�j

#>
$url = "https://jlp.yahooapis.jp/MAService/V1/parse" 
$headers = @{
  "User-Agent" = "Yahoo AppID: $clientid";
  "Content-Type" = "application/x-www-form-urlencoded"}

# �����P�DPOST�f�[�^�𕶎���Ŏw��B
$poststr = "results=ma,uniq" +
  "&uniq_filter=" + [System.Web.HttpUtility]::UrlEncode("9|10") +
  "&sentence=" + [System.Web.HttpUtility]::UrlEncode("��ɂ͓�H�j���g��������B")
$xmldoc = Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body $poststr
Write-Output $xmldoc.OuterXml

# �����Q�DPOST�f�[�^��A�z�z��Ŏw��B������URL�G���R�[�h�����B
$params = @{
  "results" = "ma,uniq"; 
  "uniq_filter" = "9|10"; 
  "sentence" = "��ɂ͓�H�j���g��������B"}
$xmldoc = Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body $params
Write-Output $xmldoc.OuterXml
<#

��F���{��W��󂯉�́iPOST���\�b�h�AJSON���N�G�X�g�j

#>
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$headers = @{
  "User-Agent" = "Yahoo AppID: $clientid";
  "Content-Type" = "application/x-www-form-urlencoded"}

# JSON���N�G�X�g�B����ASCII���������Ȃ�G���R�[�h�s�v�B
$poststr = ConvertTo-Json @{
  id="123"; jsonrpc="2.0"; method="jlp.daservice.parse";
  params=@{q="�����̒�ɂ͓�H�{�����܂�"}}
$postbytes = [System.Text.Encoding]::UTF8.GetBytes($poststr)
$res = Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body $postbytes
Write-Output (ConvertTo-Json $res -Depth 100)
<#

## WebClient�N���X GET���\�b�h

��FGoogle����

#>
$url = 'https://www.google.com/search'
$wc = New-Object System.Net.WebClient 
$wc.QueryString.Add("q", "Powershell")

# �����P�D�R���e���c���擾���ۑ��B�e�L�X�g�̃G���R�[�h�ϊ��Ȃ��̖͗l�B 
$wc.DownloadFile($url, 'D:\tmp\out.txt')

# �����Q�D�R���e���c���o�C�g�z��Ƃ��Ď擾 
$resbytes = $wc.DownloadData($url) 

# �����R�D�R���e���c�𕶎���Ƃ��Ď擾�B�K�v�Ȃ�$wc.Encoding�ɃG���R�[�h���w�肷��B 
$resstr = $wc.DownloadString($url)

# �G���[���l������ꍇ
try {
  $resstr = $wc.DownloadString($url)
} catch {
  $error[0].Exception.InnerException.Response.StatusCode.value__
}

# ��Еt�� 
$wc.Dispose()
<#

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iGET�j

#>
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$wc = New-Object System.Net.WebClient
$wc.Encoding = [System.Text.Encoding]::UTF8
$wc.QueryString.Add("appid", $clientid)
$wc.QueryString.Add("results", "ma,uniq")
$wc.QueryString.Add("uniq_filter", "9|10")
$wc.QueryString.Add("sentence", "��ɂ͓�H�j���g��������B")
$resstr = $wc.DownloadString($url)
$wc.Dispose()
Write-Output $resstr
<#

## WebClient�N���X POST���\�b�h

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iPOST�j

#>
Add-Type -AssemblyName System.Web
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Yahoo AppID: $clientid")
$wc.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
$wc.Encoding = [System.Text.Encoding]::UTF8

# �����P�DPOST�f�[�^�𕶎���Őݒ�
$poststr = "results=ma,uniq" +  
  "&uniq_filter=" + [System.Web.HttpUtility]::UrlEncode("9|10") + 
  "&sentence=" + [System.Web.HttpUtility]::UrlEncode("��ɂ͓�H�j���g��������B")
$resstr = $wc.UploadString($url, $poststr) 
Write-Output $resstr

# �����Q�DPOST�f�[�^�𖼑O�ƒl�̃R���N�V�����Őݒ�
$posthash = New-Object System.Collections.Specialized.NameValueCollection 
$posthash.Add("results", "ma,uniq") 
$posthash.Add("uniq_filter", "9|10") 
$posthash.Add("sentence", "��ɂ͓�H�j���g��������B") 
$resbytes = $wc.UploadValues($url, $posthash) 
$resstr = [System.Text.Encoding]::UTF8.GetString($resbytes)
Write-Output $resstr

# �����R�DPOST�f�[�^���o�C�g�z��Őݒ�ibyte[] UploadData(string url, byte[] postdata)�j
# ���ȗ�

# ��Еt��
$wc.Dispose() 
<#

��F���{��W��󂯉�́iPOST���\�b�h�AJSON���N�G�X�g�j

#>
Add-Type -AssemblyName System.Web
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Yahoo AppID: $clientid")
$wc.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
$wc.Encoding = [System.Text.Encoding]::UTF8
# JSON���N�G�X�g�B����ASCII���������Ȃ�$wc.UploadString()���g�p�\�B
$poststr = '{"id":"123","jsonrpc":"2.0","method":"jlp.daservice.parse","params":{' +
  '"q":"�����̒�ɂ͓�H�{�����܂�"' +
  '}}'
$postbytes = [System.Text.Encoding]::UTF8.GetBytes($poststr)
$resbytes = $wc.UploadData($url, $postbytes)
$resstr = [System.Text.Encoding]::UTF8.GetString($resbytes)
Write-Output $resstr
# ��Еt��
$wc.Dispose()
