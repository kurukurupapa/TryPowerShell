function Format-DebugString {
    param(
        [object]$InputObject
    )
    process {
        if ($null -eq $InputObject) {
            return '$null'
        }

        # �z���R���N�V�����̏ꍇ
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $typeName = $InputObject.GetType().FullName
            $count = @($InputObject).Count
            $content = ($InputObject | ForEach-Object { "'$_'" }) -join ', '
            return "[$typeName](${count}��): $content"
        }
        return $InputObject.ToString()
    }
}
