# ���[�e�B���e�B�֐�

function ReadUserInput($message, $dialog) {
  $str = $null
  if (!$dialog) {
    $str = Read-Host $message
    # ��accessToken�\��t�����Ƃ��ɁA���X�A������������̂Œ��ӁB
  } else {
    $str = ShowInputDialog $message
  }
  return $str
}

function ShowInputDialog($message, $title) {
  Add-Type -AssemblyName System.Windows.Forms
  $form = New-Object System.Windows.Forms.Form -Property @{
    Text = $title
    Width = 300
    Height = 200
  }
  $form.Controls.Add(($textBox = New-Object System.Windows.Forms.TextBox -Property @{
    AutoSize = $false
    Dock = [System.Windows.Forms.DockStyle]::Fill
  }))
  $form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = $message
    Dock = [System.Windows.Forms.DockStyle]::Top
  }))
  $form.Controls.Add(($button = New-Object System.Windows.Forms.Button -Property @{
    Text = "OK"
    Dock = [System.Windows.Forms.DockStyle]::Bottom
  }))
  $button.Add_Click({
    $form.Tag = $textBox.Text
    $form.Close()
  })
  $form.ShowDialog() | Out-Null
  $form.Dispose()
  return $form.Tag
}

# HTTP�A�N�Z�X�G���[���̃G���[����\��
function PrintWebException($e) {
  try {
    Write-Host $e
    Write-Host "$($e.Exception.Status.value__) $($e.Exception.Status.ToString())"
    $stream = $e.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader $stream
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    Write-Host $reader.ReadToEnd()
    $stream.Close()
  } catch {
    Write-Host "PrintWebException ERROR: $_"
  }
}

# �ȈՓI�Ƀf�[�^���Í����t�@�C���Ƃ��ĕۑ�/�ǂݍ��݂ł���悤�ɂ����B�i���܂�ǂ��Ȃ�������������Ȃ��j
function SaveSecretObject($path, $obj) {
  $jsonStr = ConvertTo-Json $obj -Compress
  ConvertTo-SecureString $jsonStr -AsPlainText -Force | ConvertFrom-SecureString | Set-Content $path
  Write-Verbose "Saved $path"
}
function LoadSecretObject($path) {
  $ss = Get-Content $path | ConvertTo-SecureString
  $jsonStr = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss))
  $jsonObj = ConvertFrom-Json $jsonStr
  Write-Verbose "Loaded $path"
  return $jsonObj
}

function ToCamelCase($snakeCase) {
  return ([regex]"_([a-z])").Replace($snakeCase, {$args[0].Groups[1].Value.ToUpper()})
}
