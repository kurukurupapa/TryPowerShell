function Format-DebugString {
    param(
        [object]$InputObject
    )
    process {
        if ($null -eq $InputObject) {
            return '$null'
        }

        # 配列やコレクションの場合
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $typeName = $InputObject.GetType().FullName
            $count = @($InputObject).Count
            $content = ($InputObject | ForEach-Object { "'$_'" }) -join ', '
            return "[$typeName](${count}件): $content"
        }
        return $InputObject.ToString()
    }
}
