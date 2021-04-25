<#

# �G���R�[�f�B���O

HTTP�A�N�Z�X����Ƃ��ɕK�v�ƂȂ�G���R�[�f�B���O�ɂ��āA�������Ă����܂��B

## �e�L�X�g�̃G���R�[�f�B���O

.NET Framwork �� Encoding�N���X���g�p���āA�e�L�X�g�̃G���R�[�f�B���O��ύX���邱�Ƃ��ł��܂����B

- .NET Framework 1.1 �ȍ~
- [Encoding �N���X (System.Text) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.text.encoding?view=net-5.0)

#>
$enc = [System.Text.Encoding]::UTF8
$enc = [System.Text.Encoding]::GetEncoding("SJIS")
# �w�肵���G���R�[�f�B���O�ɕϊ�����������̃o�C�g�z����擾
$bytes = $enc.GetBytes("���{��e�L�X�g�ł�")
# �o�C�g�z����w�肵���G���R�[�f�B���O�Ƃ��ĉ��߂��ĕ�������擾
$str = $enc.GetString($bytes)
# MakeMd SKIP_START
# ���ʊm�F
$bytes
$str
# MakeMd SKIP_END
<#

## �p�[�Z���g�G���R�[�f�B���O

����2��ނ�����B

- �p�[�Z���g�G���R�[�f�B���O�ɂ�镄���� �F URL�̃p�X�����𕄍�����������B���p�X�y�[�X���u%20�v�ƂȂ�BRFC3986�B
- application/x-www-form-urlencoded�ɂ�镄���� �F HTTP��POST���\�b�h�ő��M���镶����ɑ΂��镄���������B���p�X�y�[�X���u+�v�ƂȂ�B

�p�[�Z���g�G���R�[�f�B���O�ɂ�镄�����́A.NET Framework �� Uri�N���X���g�p���āA�����ł��܂����B

- .NET Framework 2.0 �ȍ~�iPowerShell 2.0 �ȍ~�j
- .NET Framework 4.0�ȑO��4.5�ȍ~�ŁA�G���R�[�h�Ώۂ̋L���������قȂ�B

#>
$url = 'https://www.google.com/search?q=Powershell ���{��'
# ������S�̂��G���R�[�h
$encstr = [Uri]::EscapeDataString($url)      #=> "https%3A%2F%2Fwww.google.com%2Fsearch%3Fq%3DPowershell%20%E6%97%A5%E6%9C%AC%E8%AA%9E"
$decstr = [Uri]::UnescapeDataString($encstr)
# MakeMd SKIP_START
$encstr
$decstr
# MakeMd SKIP_END
# �\�񕶎��ȊO���G���R�[�h
$encstr = [Uri]::EscapeUriString($url)       #=> "https://www.google.com/search?q=Powershell%20%E6%97%A5%E6%9C%AC%E8%AA%9E"
$decstr = [Uri]::UnescapeDataString($encstr)
# MakeMd SKIP_START
$encstr
$decstr
# MakeMd SKIP_END
<#

application/x-www-form-urlencoded�ɂ�镄�����́A.NET Framework �� HttpUtility�N���X���g�p���āA�����ł��܂����B

- .NET Framework 1.1 �ȍ~�iPowerShell 1.0 �ȍ~�j

#>
Add-Type -AssemblyName System.Web
$str = "POST�f�[�^ abc :/?&=<>"
# �G���R�[�h�B�f�t�H���g��UTF8���g�p�B�K�v�Ȃ��2������Encoding���w�肷��B
$encstr = [System.Web.HttpUtility]::UrlEncode($str)  #=> "POST%e3%83%87%e3%83%bc%e3%82%bf+abc+%3a%2f%3f%26%3d%3c%3e"
# �f�R�[�h�B�f�t�H���g��UTF8���g�p�B�K�v�Ȃ��2������Encoding���w�肷��B
$decstr = [System.Web.HttpUtility]::UrlDecode($encstr)
# MakeMd SKIP_START
$encstr
$decstr
# MakeMd SKIP_END
