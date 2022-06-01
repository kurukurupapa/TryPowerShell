
# 言語機能

## データ操作

文字列操作

```powershell
$number = 123
$str = "abc"
# 文字列組み立て
"${number}`t${str}"                 #=> "123     abc"
'${number}`t${str}'                 #=> "${number}`t${str}"
"$($number * 2) $($str * 2)"        #=> "246 abcabc"
"{0:D10}" -f $number                #=> "0000000123"
$number.ToString().PadLeft(10, "0") #=> "0000000123"
$str.PadRight(10, "*")              #=> "abc*******"
# 編集
" abc ".Trim()                      #=> "abc"
"abcde".TrimStart("a")              #=> "bcde"
"abcde".TrimEnd("e")                #=> "abcd"
"abcde".Replace("bc", "BC")         #=> "aBCde"
"abcde" -replace "bc", "BC"         #=> "aBCde"
"abcde" -replace "a(.+)e","A<`$1>E" #=> "A<bcd>E"
"abcde".Substring(2, 3)             #=> "cde"
"a, b, c" -split ", *"              #=> ("a","b","c")
("a","b","c") -join ","             #=> "a,b,c"
# 検索、比較
$str.IndexOf("bc")                  #=> 1
$str.LastIndexOf("bc")              #=> 1
$str.Contains("bc")                 #=> True
$str.StartsWith("ab")               #=> True
$str.EndsWith("bc")                 #=> True
$str -like "ab*"                    #=> True
$str -notlike "ab*"                 #=> False
$str -match "[a-z]+"                #=> True
$str -notmatch "[a-z]+"             #=> False
if ("abcde" -match "b(c)d") { $Matches } #=> @{0="bcd";1="c"}
2 -in 1,2,3                         #=> True
2 -notin 1,2,3                      #=> False
1,2,3 -contains 2                   #=> True
1,2,3 -notcontains 2                #=> False
```

日時

```powershell
# 日時オブジェクト
$dtObj = Get-Date                        # 現在日時
$dtObj = Get-Date "2021/01/01 01:01:01"  # "2021/1/1 0:0:0"や"2021-01-01"なども可能。
$dtObj = [Datetime]"2021/01/01 01:01:01"
$dtObj = $dtObj.AddYears(1).AddMonths(1).AddDays(1).AddHours(1).AddMinutes(1).AddSeconds(1)
# 日時文字列
$dtStr = Get-Date -Format "yyyy/MM/dd HH:mm:ss" # 現在日時
$dtStr = Get-Date -Format o                     # ISO8601（yyyy-MM-ddTHH:mm:ss.fffffffzzz）形式
$dtStr = Get-Date -Format u                     # yyyy-MM-dd HH:mm:ss 形式
$dtStr = $dtObj.ToString("yyyyMMdd HHmmss")
$dtStr = $dtObj.ToString("o")
# 2つの日時の差
$timeSpan = $dtObj - [Datetime]"2021/01/01 01:01:01"
# MakeAllMd SKIP_START
$dtObj
$dtStr
$timeSpan
# MakeAllMd SKIP_END
```

パス操作

```powershell
Test-Path "D:\tmp\subdir" -PathType Container
Test-Path "D:\tmp\subdir\dummy.txt" -PathType Leaf
Split-Path "D:\tmp\subdir\dummy.txt" -Leaf         #=> "dummy.txt"
Split-Path "D:\tmp\subdir\dummy.txt" -Parent       #=> "D:\tmp\subdir"
Join-Path "D:\tmp\subdir" "dummy.txt"
Get-Location
Set-Location "D:\tmp"
# 相対パス・絶対パス変換（パスが存在すること）
Resolve-Path ".\subdir\dummy.txt"                  #=> 絶対パス（PathInfo）
Resolve-Path "D:\tmp\subdir\dummy.txt" -Relative   #=> 相対パス（string）
# 相対パス・絶対パス変換（パスが存在しなくてもよい）
[System.IO.Directory]::GetCurrentDirectory()
[System.IO.Path]::GetFullPath(".\subdir\dummy.txt") #=> 絶対パス（string）
# PowerShellスクリプト内で自スクリプトのパス情報を取得
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$paBaseName = $psname -replace "\.ps1$", ""
```

配列

```powershell
# 作成
$arr = @("a", "b", "c")
$arr += "d"
$arr += @("e", "f")
$arr[0] = "A"
# 参照
$arr[0]
$arr[-1]
$arr.Length
$arr | %{ echo $_ }
foreach ($e in $arr) { echo $e }
# 比較
$index = $arr.IndexOf("b")
if ($arr.Contains("b")) { "処理" }
```

動的配列

```powershell
# 作成
$list1 = New-Object System.Collections.Generic.List[string]
$list1 = [System.Collections.Generic.List[string]]::new()
$list1.Add("value1")
$list1 += "value2"
$list1 += @("value3", "value4")
# 参照
$list1[0]
$list1.Length
$list1 | %{ echo $_ }
foreach ($e in $list1) { echo $e }
# 比較
$index = $list1.IndexOf("value1")
if ($list1.Contains("value1")) { "処理" }

# 作成
$list2 = New-Object System.Collections.Generic.List[PSObject]
$list2.Add(@{key1="value1"; key2="value2"})
```

連想配列

```powershell
# 作成
$hash = @{key1="value1"; key2="value2"; key3="value3"}
$hash.key4 = "value4"
$hash["key5"] = "value5"
$hash += @{"key6"="value6"}
$hash.Add("key7", "value7")
$hash.Remove("key2")
$hash.Clear()
# 参照
$hash.key1
$hash["key1"]
$hash.Count
$hash.GetEnumerator() | sort Key | %{ $_.Key + "," + $_.Value }
foreach ($e in $hash.GetEnumerator()) { $e.Key + "," + $e.Value }  # 順不同
# 比較
if ($hash.ContainsKey("key1")) { "処理" }
if ($hash.ContainsValue("value1")) { "処理" }
```

コマンドライン引数の取得

```powershell
# 引数の宣言。スクリプトの最初のほうに書く。
Param([string]$in, [string]$out)
echo "$in $out"
# $argsには、すべての引数が設定される。
$args[0]
$args.Length
```

環境変数の取得・設定

```powershell
$env:PATH
$env:PATH = "$env:PATH;C:\Users\xxx\bin"
Get-ChildItem env:
Get-ChildItem env: | ?{ $_.Value -match "PowerShell" }
```

## 制御構造

コメント

```powershell
# 一行コメント
<#
複数行コメント
#>
```

コマンドを複数行に分けて書く。
行末にバッククォート「\`」を書くことで、コマンドを次の行にも続けられる。
ただし、次の例だと、行末にパイプがあり、式が終了していないと見なされるので、「\`」を書かなくてもよい。

```powershell
Get-Process | `
  %{ $_.ProcessName } | `
  sort | `
  Get-Unique
```

関数

```powershell
function Func1($arg1, $arg2=123, [switch]$arg3) {
  return "$arg1,$arg2,$arg3"
}
Func1 "abc"           #=> "abc,123,False"
Func1 "abc" 456 -arg3 #=> "abc,456,True"

function Func2([Parameter(ValueFromPipeline=$true)]$arg1) {
  process {
    return $arg1.ToUpper()
  }
}
"abc" | Func2 #=> "ABC"
```

クラス

```powershell
class Class1 {
  $item1
  Class1($item1) {
    $this.item1 = $item1
  }
  [string] ToString() {
    return ("item1=" + $this.item1)
  }
}
$obj1 = New-Object Class1 "value1"
$obj1 = [Class1]::new("value1")
$obj1.ToString()

# 継承
class Class2 : Class1 {
  $item2
  Class2($item1, $item2) : base($item1) {
    $this.item2 = $item2
  }
  [string] ToString() {
    $result = ([Class1]$this).ToString()
    $result += ",item2=" + $this.item2
    return $result
  }
}
$obj2 = New-Object Class2("value1", "value2")
$obj2.ToString()
```

try-catch-finally

```powershell
try {
  throw "ERROR"
} catch {
  echo $_
  echo $error[0]
} finally {
  echo "finally"
}
```

パイプ

```powershell
Get-Process | %{ $_.ProcessName } | sort | Get-Unique
Get-Process | ?{ $_.CPU -ge 100 }
Get-Process | sort CPU -Descending
Get-Process | select ProcessName
"b","a","b" | select -Unique -First 3  #=> "b","a"
Get-Process | foreach -Begin { $count=0 } -Process { $count++ } -End { $count }
```

パイプ処理内で、クラスメソッドを呼び出して、出力処理を行うと思わぬ動きになったのでメモ。
以下、3パターンの出力処理で、クラスメソッドと関数での動作の違いを表す。

```powershell
class Class1 {
  [string] Method1($a) {
    $a * 1               # ←出力されない
    Write-Output $a * 2  # ←出力されない
    return $a * 3        # ←出力対象
  }
}
$obj = New-Object Class1
1..3 | %{ $obj.Method1($_) }  #=> (3,6,9)

# 関数の場合
function Func1($a) {
  $a * 1                 # ←出力対象
  Write-Output ($a * 2)  # ←出力対象
  return $a * 3          # ←出力対象
}
1..3 | %{ Func1($_) }  #=> (1,2,3,2,4,6,3,6,9)
```

外部コマンド実行

```powershell
& "D:\tmp\dummy.bat" | %{ $_ }
$result = & "D:\tmp\dummy.bat"
$lastexitcode
```

## その他

文字列をコードとして実行

```powershell
Invoke-Expression "1+1" #=> 2
```

ランダム

```powershell
$value = Get-Random 100                        # 0～99でランダムな値
$value = Get-Random -Minimum -100 -Maximum 100 # -100～99でランダムな値
$value = 1, 2, 3, 5, 8, 13 | Get-Random        # 選択肢から1つ選択
$value = "red", "yellow", "blue" | Get-Random
$arr = 1, 2, 3, 5, 8, 13 | Get-Random -Count 3 # 選択肢から複数選択
$arr = 1, 2, 3, 5, 8, 13 | Get-Random -Shuffle # シャッフル
```
