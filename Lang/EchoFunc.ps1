# Windows PowerShell
# �����܂��̓p�C�v���C�����͂��󂯕t����X�N���v�g�̗��K�ł��B

function U-Echo() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)] #�p�C�v���C�����͂��󂯎��B�K�{�B
        [ValidateNotNull()] #NULL�s��
        [string[]]$InputString
    )
    process {
        $InputString | %{
            "Echo:[$_]"
        }
    }
}
