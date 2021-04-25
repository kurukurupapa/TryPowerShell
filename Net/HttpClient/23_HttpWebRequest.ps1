<#

## HttpWebRequest/HttpWebResponse GET���\�b�h

��FGoogle�����iGET���\�b�h�j

#>
$url = 'https://www.google.com/search?q=Powershell'
$req = [System.Net.WebRequest]::Create($url)
$res = $req.GetResponse()
echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
$stream = $res.GetResponseStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
echo $reader.ReadToEnd()
$res.Close()  # $stream.Close(),$reader.Close()�ł��ǂ����A3�Ƃ����s���Ă��ǂ��B

# �G���[���l������ꍇ
try {
  $url = 'https://www.google.com/���݂��Ȃ��y�[�W'
  $req = [System.Net.WebRequest]::Create($url)
  $res = $req.GetResponse()
  echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
  $stream = $res.GetResponseStream()
  $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
  echo $reader.ReadToEnd()
  $res.Close()
} catch {
  # �X�e�[�^�X�R�[�h
  echo $_.Exception.InnerException.Response.StatusCode.value__
  # ���X�|���X�{�f�B
  $stream = $_.Exception.InnerException.Response.GetResponseStream()
  $reader = New-Object System.IO.StreamReader $stream
  $reader.BaseStream.Position = 0
  $reader.DiscardBufferedData()
  echo $reader.ReadToEnd()
  $stream.Close()  # $reader.Close()�ł��ǂ����A2�Ƃ����s���Ă��ǂ��B
}
<#

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iGET���\�b�h�j

#>
$clientid = "���Ȃ��� Yahoo! JAPAN WebAPI �p�N���C�A���gID ��ݒ肷��"
$url = "https://jlp.yahooapis.jp/MAService/V1/parse" +
  "?appid=" + $clientid +
  "&results=ma,uniq" +
  "&uniq_filter=9|10" +
  "&sentence=��ɂ͓�H�j���g��������B"
$url = [Uri]::EscapeUriString($url)
$req = [System.Net.WebRequest]::Create($url)
$res = $req.GetResponse()
echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
$stream = $res.GetResponseStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
echo $reader.ReadToEnd()
$res.Close()
<#

## HttpWebRequest/HttpWebResponse POST���\�b�h

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iPOST���\�b�h�AKeyValue�����N�G�X�g�j

#>
# �f�[�^����
Add-Type -AssemblyName System.Web
$url = "https://jlp.yahooapis.jp/MAService/V1/parse"
$postStr = "results=ma,uniq" +  
  "&uniq_filter=" + [System.Web.HttpUtility]::UrlEncode("9|10") + 
  "&sentence=" + [System.Web.HttpUtility]::UrlEncode("��ɂ͓�H�j���g��������B")
$postBytes = [System.Text.Encoding]::UTF8.GetBytes($postStr)
# ���N�G�X�g���M
$req = [System.Net.WebRequest]::Create($url)
$req.Method = "POST"
$req.UserAgent = "Yahoo AppID: $clientid"
$req.ContentType = "application/x-www-form-urlencoded"
$req.ContentLength = $postBytes.Length
$stream = $req.GetRequestStream()
$stream.Write($postBytes, 0, $postBytes.Length)
$stream.Close()
# ���X�|���X��M
$res = $req.GetResponse()
echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
$stream = $res.GetResponseStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
echo $reader.ReadToEnd()
$res.Close()
<#

��F���{��W��󂯉�́iPOST���\�b�h�AJSON���N�G�X�g�j

#>
Add-Type -AssemblyName System.Web
$url = 'https://jlp.yahooapis.jp/DAService/V2/parse'
$postStr = '{"id":"123","jsonrpc":"2.0","method":"jlp.daservice.parse","params":{' +
  '"q":"�����̒�ɂ͓�H�{�����܂�"' +
  '}}'
$postBytes = [System.Text.Encoding]::UTF8.GetBytes($postStr)
# ���N�G�X�g���M
$req = [System.Net.WebRequest]::Create($url)
$req.Method = "POST"
$req.UserAgent = "Yahoo AppID: $clientid"
$req.ContentType = "application/json"
$req.ContentLength = $postBytes.Length
$stream = $req.GetRequestStream()
$stream.Write($postBytes, 0, $postBytes.Length)
$stream.Close()
# ���X�|���X��M
$res = $req.GetResponse()
echo ($res.StatusCode.value__.ToString() + " " + $res.StatusDescription)
$stream = $res.GetResponseStream()
$reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
echo $reader.ReadToEnd()
$res.Close()
