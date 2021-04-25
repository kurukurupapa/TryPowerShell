<#

# HTTP�N���C�A���g

HTTP�A�N�Z�X���邽�߂̃N���C�A���g�@�\�́AInvoke-WebRequest�R�}���h���b�g�AInvoke-RestMethod�R�}���h���b�g�Ƃ��Ē񋟂���Ă��܂����B
�������APowerShell 3.0 �ȍ~�ł��B
�Â����ł́A�����̃R�}���h���b�g���g���Ȃ��̂ŁA�ւ��� .NET Framework ���g�����ƂŁA�����ł��܂����B

��v�R�}���h���b�g/�N���X

- Invoke-WebRequest�R�}���h���b�g�FPowerShell 3.0 �ȍ~
- Invoke-RestMethod�R�}���h���b�g�FPowerShell 3.0 �ȍ~
- HttpClient�N���X�F.NET Framework 4.5 �ȍ~�i�Ȃ̂ŁAPowerShell 4.0 �ȍ~�BInvoke-WebRequest/Invoke-RestMethod�R�}���h���b�g�ŊT�˓������Ƃ��ł���Ǝv�����̂ō��񖢎g�p�B�j
- WebClient�N���X�F.NET Framework 1.1 �ȍ~�i�Ȃ̂ŁA�ǂ�PowerShell�o�[�W�����ł��g�p�\�BHttpWebRequest/HttpWebResponse�N���X��菭���֗��B�j
- HttpWebRequest/HttpWebResponse�N���X�F.NET Framework 1.1 �ȍ~�i�Ȃ̂ŁA�ǂ�PowerShell�o�[�W�����ł��g�p�\�BWebClient�N���X���ׂ������Ƃ��ł���B�j

��L�̂悤�ɁAHTTP�A�N�Z�X���邽�߂̃R�}���h���b�g��N���X���F�X�p�ӂ���Ă��܂��B
�����A�ǂ���g���΂悢�̂������Ă��܂����̂ł����A��ʂ�G���Ă݂āA���̂悤�Ɏg��������΂悢�̂��ȁA�Ǝv���܂����B

- PowerShell 3.0 �ȍ~�̊�
  - API���R�[������Ȃ�AInvoke-RestMethod�R�}���h���b�g
  - Web�y�[�W���擾����Ȃ�AInvoke-WebRequest�R�}���h���b�g
- PowerShell 2.0 �ȑO�̊�
  - ��{�AWebClient�N���X
  - ���N�G�X�g/���X�|���X���ׂ������䂵�����Ȃ�AHttpWebRequest/HttpWebResponse�N���X

## Invoke-WebRequest�R�}���h���b�g GET���\�b�h

��FGoogle�����iGET���\�b�h�AKeyValue�����N�G�X�g�AHTML���X�|���X�j

#>
$url = 'https://www.google.com/search'
$params = @{"q"="Powershell"}

# �����P�D�R���e���c�����X�|���X�I�u�W�F�N�g�Ƃ��Ď擾
$res = Invoke-WebRequest $url -Body $params
# MakeMd SKIP_START
$res.GetType().FullName  #=> "Microsoft.PowerShell.Commands.HtmlWebResponseObject"
$res.StatusCode.ToString() + " " + $res.StatusDescription 
$res.Headers
$res.Content.Substring(0, 1000) #�擪�����\�����Ă݂�
# MakeMd SKIP_END

# �����Q�D�R���e���c���t�@�C���ɕۑ�
Invoke-WebRequest $url -Body $params -OutFile 'D:\tmp\out.txt'
# MakeMd SKIP_START
Get-Content 'D:\tmp\out.txt' | Select-Object -First 5
# MakeMd SKIP_END

# �⑫�D�G���[�l��
try {
  $res = Invoke-WebRequest 'https://www.google.com/���݂��Ȃ��y�[�W'
  $res.StatusCode.ToString() + " " + $res.StatusDescription 
  $res.Headers
  $res.Content
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

# �⑫�D���X�|���XHTML�����
$res = Invoke-WebRequest 'https://weather.yahoo.co.jp/weather/jp/13/4410.html'
$res.ParsedHtml.title
$res.ParsedHtml.getElementById("wrnrpt").innerText
$res.ParsedHtml.getElementsByName("description") | %{ $_.GetAttribute("content") }
$res.ParsedHtml.getElementsByTagName("title") | %{ $_.innerText }
<#

- Invoke-WebRequest�ɁA-SessionVariable�p�����[�^��ݒ肷��ƃZ�b�V��������ϐ��ɕۑ��ł��āA����Invoke-WebRequest���s���ɁA-WebSession�p�����[�^��ݒ肵�ăZ�b�V�������������p�����A�N�Z�X���ł���炵���B

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iGET���\�b�h�AKeyValue�����N�G�X�g�AXML���X�|���X�j

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

��FYahoo! JAPAN ���{��`�ԑf���WebAPI�iPOST���\�b�h�AKeyValue�����N�G�X�g�AXML���X�|���X�j

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

��F���{��W��󂯉�́iPOST���\�b�h�AJSON���N�G�X�g/���X�|���X�j

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
