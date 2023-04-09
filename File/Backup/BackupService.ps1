# �o�b�N�A�b�v�p�X�N���X
class BackupPath {
  $InPath = $null
  $InDir = $null
  $InName = $null
  $OutPath = $null
  $OutDir = $null
  $OutName = $null

  BackupPath($inPath) {
    # ��������؂蕶���Ȃ珜��
    $this.InPath = $inPath -replace "\\+$", ""
    # �������Ă���
    $this.InDir = Split-Path $this.InPath -Parent
    $this.InName = Split-Path $this.InPath -Leaf
  }

  # �o�b�N�A�b�v���s
  # $folder - �o�b�N�A�b�v��t�H���_�B�o�b�N�A�b�v�ΏۂƓ����t�H���_�̏ꍇ"."�B
  [void] Backup($folder) {
    $this.MakeOutPath($folder)

    # �R�s�[��f�B���N�g���쐬
    if (!(Test-Path $this.OutDir -PathType container)) {
      New-Item $this.OutDir -ItemType Directory
    }

    # �R�s�[��`�F�b�N
    if (Test-Path $this.OutPath) {
      throw "�o�b�N�A�b�v��p�X�����݂��܂��B$($this.OutPath)"
    }

    # �R�s�[���{
    Copy-Item $this.InPath -Destination $this.OutPath -Recurse
    Write-Verbose "�o�b�N�A�b�v���܂����B$($this.OutPath)"
  }

  # �o�b�N�A�b�v�p�X��g�ݗ���
  [void] hidden MakeOutPath($folder) {
    # �o�̓p�X�̑g�ݗ���
    $this.OutDir = Join-Path $this.InDir $folder
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    if (Test-Path $this.InPath -PathType container) {
      # �t�H���_
      $this.OutName = "$($this.InName)_bk${timestamp}"
    }
    elseif (Test-Path $this.InPath -PathType leaf) {
      if ($this.InPath -match "\.[^\.\\]*$") {
        # �t�@�C���E�g���q����
        $this.OutName = $this.InName -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
      }
      else {
        # �t�@�C���E�g���q�Ȃ�
        $this.OutName = "$($this.InName)_bk${timestamp}"
      }
    }
    else {
      throw "�Ώۃt�@�C��/�t�H���_��������܂���B$($this.InPath)"
    }
    $this.OutPath = Join-Path $this.OutDir $this.OutName
  }
}

# �o�b�N�A�b�v�T�[�r�X�N���X
class BackupService {
  $BackupPathArr = $null
  hidden $LogName = "BackupLog.txt"
  hidden $LogSep = "-" * 80
  
  BackupService($inPathArr) {
    $this.BackupPathArr = $inPathArr | ForEach-Object {
      [BackupPath]::new($_)
    }
  }

  # �o�b�N�A�b�v���s
  # $outFolder - �o�b�N�A�b�v��t�H���_�B�o�b�N�A�b�v�ΏۂƓ����t�H���_�̏ꍇ"."�B
  [void] Run($outFolder) {
    $this.BackupPathArr | ForEach-Object {
      $_.Backup($outFolder)
    }
  }

  # �o�b�N�A�b�v���̃R�����g����������
  [void] WriteLog($message) {
    # �o�̓f�B���N�g���̎�ނ��ƂɃ��O����������
    $this.BackupPathArr | ForEach-Object { $_.OutDir } | Sort-Object -Unique | ForEach-Object {
      # ���Y���[�v�̏o�̓f�B���N�g��
      $outDir = $_
      # ����o�̓f�B���N�g���̏o�̓p�X�ꗗ
      $arr = $this.BackupPathArr | ForEach-Object {
        if ($_.OutDir -eq $outDir) {
          $_.OutPath
        }
      } | Sort-Object
      # ���O����������
      $logPath = Join-Path $outDir $this.LogName
      $logMessage = @()
      $logMessage += $this.LogSep
      $logMessage += $arr
      $logMessage += $message
      $logMessage | Out-File $logPath -Encoding default -Append
      Write-Verbose "���O���������݂܂����B${logPath}"
    }
  }
}
