# Windows PowerShell
# 引数またはパイプライン入力を受け付けるスクリプトの練習です。

function U-Echo() {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)] #パイプライン入力を受け取る。必須。
        [ValidateNotNull()] #NULL不可
        [string[]]$InputString
    )
    process {
        $InputString | %{
            "Echo:[$_]"
        }
    }
}
