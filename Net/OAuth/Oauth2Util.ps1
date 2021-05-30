# PowerShell�W���@�\�� OAuth 2.0 �N���C�A���g���쐬���Ă݂�
# ���[�e�B���e�B�֐�

. (Join-Path $PSScriptRoot "OauthUtil.ps1")
$OAUTH2_CODE_MSG = "������ʂɕ\�����ꂽ�R�[�h�A�܂��͊���/�J�ڃG���[��ʂ�URL����code�̒l����͂��Ă��������B"
$OAUTH2_USER_AGENT = "PsOauth2Client"

function Oauth2_ReadUserCode($message=$OAUTH2_CODE_MSG, $dialog) {
  return ReadUserInput $message $dialog
}

function Oauth2_AddResponse($base, $response) {
  $response.psobject.properties | ForEach-Object {
    $name = ToCamelCase $_.Name
    if ($base -is [Object]) {
      Add-Member -InputObject $base -MemberType NoteProperty -Name $name -Value $_.Value -Force
    } else {
      $base[$name] = $_.Value
    }
  }
  return $base
}
