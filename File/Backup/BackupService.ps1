# �o�b�N�A�b�v�T�[�r�X�N���X
class BackupService {
  $inDir
  $inName
  $inPath
  $outDir
  $outName
  $outPath
  $logName = "BackupLog.txt"
  $logSep = "-" * 80
  
  BackupService($inPath) {
    # ��������؂蕶���Ȃ珜��
    $this.inPath = $inPath -replace "\\+$", ""
    # �������Ă���
    $this.inDir = Split-Path $this.inPath -Parent
    $this.inName = Split-Path $this.inPath -Leaf
  }

  # �o�b�N�A�b�v�p�X��g�ݗ���
  # $folder - �o�b�N�A�b�v��t�H���_�B�o�b�N�A�b�v�ΏۂƓ����t�H���_�̏ꍇ"."�B
  [void] MakeOutPath($folder) {
    $this.outDir = Join-Path $this.inDir $folder
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    if (Test-Path $this.inPath -PathType container) {
      # �t�H���_
      $this.outName = "$($this.inName)_bk${timestamp}"
    }
    elseif (Test-Path $this.inPath -PathType leaf) {
      if ($this.inPath -match "\.[^\.\\]*$") {
        # �t�@�C���E�g���q����
        # $outpath = $path -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
        $this.outName = $this.inName -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
      }
      else {
        # �t�@�C���E�g���q�Ȃ�
        # $outpath = $path + "_bk${timestamp}"
        $this.outName = "$($this.inName)_bk${timestamp}"
      }
    }
    else {
      throw "�Ώۃt�@�C��/�t�H���_��������܂���B$($this.inPath)"
    }
    $this.outPath = Join-Path $this.outDir $this.outName
  }

  # �o�b�N�A�b�v���s
  [void] Backup() {
    # �R�s�[��f�B���N�g���쐬
    if (!(Test-Path $this.outDir -PathType container)) {
      New-Item $this.outDir -ItemType Directory
    }

    # �R�s�[��`�F�b�N
    if (Test-Path $this.outPath) {
      throw "�o�b�N�A�b�v��p�X�����݂��܂��B$($this.outPath)"
    }

    # �R�s�[���{
    Copy-Item $this.inPath -Destination $this.outPath -Recurse
    Write-Verbose "�o�b�N�A�b�v���܂����B$($this.outPath)"
  }
  
  # �o�b�N�A�b�v���̃R�����g����������
  [void] WriteLog($message) {
    $logPath = Join-Path $this.outDir $this.logName
    $this.logSep, $this.outPath, $message | Out-File $logPath -Encoding default -Append
  }
}
