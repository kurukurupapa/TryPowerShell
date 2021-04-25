<#

## Invoke-RestMethod�R�}���h���b�g

### GET���\�b�h

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iGET�j

#>
$clientid = "���Ȃ��� Yahoo! JAPAN WebAPI �p�N���C�A���gID ��ݒ肷��"
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
  $xmldoc = Invoke-RestMethod "https://jlp.yahooapis.jp/���݂��Ȃ��y�[�W" -Body $params
  Write-Output $xmldoc.OuterXml
} catch {
  # �X�e�[�^�X�R�[�h
  echo $_.Exception.Response.StatusCode.value__
  # ���X�|���X�{�f�B
  $stream = $_.Exception.Response.GetResponseStream()
  $reader = New-Object System.IO.StreamReader $stream
  $reader.BaseStream.Position = 0
  $reader.DiscardBufferedData()
  echo $reader.ReadToEnd()
  $reader.Close()  # Close��$reader��$stream�̈�����Ăяo���΂悢�B�����Ăяo���Ă��Q�͂Ȃ�
  $stream.Close()
}
<#

### POST���\�b�h

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
