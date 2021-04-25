<#

## WebClient�N���X GET���\�b�h

��FGoogle�����iGET���\�b�h�j

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
  $resstr = $wc.DownloadString('https://www.google.com/���݂��Ȃ��y�[�W')
} catch {
  # �X�e�[�^�X�R�[�h
  echo $_.Exception.InnerException.Response.StatusCode.value__
  # ���X�|���X�{�f�B
  $stream = $_.Exception.InnerException.Response.GetResponseStream()
  $reader = New-Object System.IO.StreamReader $stream
  $reader.BaseStream.Position = 0
  $reader.DiscardBufferedData()
  echo $reader.ReadToEnd()
  $reader.Close()  # Close��$reader��$stream�̈�����Ăяo���΂悢�B�����Ăяo���Ă��Q�͂Ȃ�
  $stream.Close()
}

# ��Еt��
$wc.Dispose()
<#

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iGET�j

#>
$clientid = "���Ȃ��� Yahoo! JAPAN WebAPI �p�N���C�A���gID ��ݒ肷��"
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

��F���{��W��󂯉�́iPOST���\�b�h�AJSON���N�G�X�g/���X�|���X�j

#>
Add-Type -AssemblyName System.Web
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Yahoo AppID: $clientid")
$wc.Headers.Add("Content-Type", "application/json")
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
