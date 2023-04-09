# �o�b�N�A�b�v�T�[�r�X�N���X
class BackupService {
  $InPathArr = $null
  $OutHashArr = $null
  hidden $LogName = "BackupLog.txt"
  hidden $LogSep = "-" * 80
  
  BackupService($inPathArr) {
    $this.InPathArr = $inPathArr
  }

  # �o�b�N�A�b�v���s
  # $outFolder - �o�b�N�A�b�v��t�H���_�B�o�b�N�A�b�v�ΏۂƓ����t�H���_�̏ꍇ"."�B
  [void] Run($outFolder) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $this.OutHashArr = $this.InPathArr | ForEach-Object {
      $this.GetOutHash($_, $outFolder, $timestamp)
    }
    $this.OutHashArr | ForEach-Object {
      $this.Backup($_)
    }
  }

  # �o�b�N�A�b�v�p�X��g�ݗ���
  [Hashtable] hidden GetOutHash($inPath, $outFolder, $timestamp) {
    # ���̓p�X�̐��`
    # ��������؂蕶���Ȃ珜��
    $inPath = $inPath -replace "\\+$", ""
    # �������Ă���
    $inDir = Split-Path $inPath -Parent
    $inName = Split-Path $inPath -Leaf

    # �o�̓p�X�̑g�ݗ���
    $outDir = Join-Path $inDir $outFolder
    if (Test-Path $inPath -PathType container) {
      # �t�H���_
      $outName = "${inName}_bk${timestamp}"
    }
    elseif (Test-Path $inPath -PathType leaf) {
      if ($inPath -match "\.[^\.\\]*$") {
        # �t�@�C���E�g���q����
        $outName = $inName -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
      }
      else {
        # �t�@�C���E�g���q�Ȃ�
        $outName = "${inName}_bk${timestamp}"
      }
    }
    else {
      throw "�Ώۃt�@�C��/�t�H���_��������܂���B${inPath}"
    }
    $outPath = Join-Path $outDir $outName

    return @{
      InPath  = $inPath;
      InDir   = $inDir;
      InName  = $inName;
      OutPath = $outPath;
      OutDir  = $outDir;
      OutName = $outName;
    }
  }

  # �o�b�N�A�b�v���s
  [void] hidden Backup($outHash) {
    # �R�s�[��f�B���N�g���쐬
    if (!(Test-Path $outHash.OutDir -PathType container)) {
      New-Item $outHash.OutDir -ItemType Directory
    }

    # �R�s�[��`�F�b�N
    if (Test-Path $outHash.OutPath) {
      throw "�o�b�N�A�b�v��p�X�����݂��܂��B$($outHash.OutPath)"
    }

    # �R�s�[���{
    Copy-Item $outHash.InPath -Destination $outHash.OutPath -Recurse
    Write-Verbose "�o�b�N�A�b�v���܂����B$($outHash.OutPath)"
  }
  
  # �o�b�N�A�b�v���̃R�����g����������
  [void] WriteLog($message) {
    $this.OutHashArr | ForEach-Object {
      $logPath = Join-Path $_.OutDir $this.LogName
      $this.LogSep, $_.OutPath, $message | Out-File $logPath -Encoding default -Append
    }
  }
}
