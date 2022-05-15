# PowerShell用の単体テストツール Pester を使ってみる

# 動作確認
# Visual Studio Code なら、実行したい行を選択して、F8キーで実行できる。

Set-Location "Lang\Pester"
New-Fixture -Name TestFunc
Invoke-Pester
Invoke-Pester .\TestFunc.Tests.ps1 -CodeCoverage .\TestFunc.ps1

# 参考サイト
# [Pester で PowerShell のファンクション テスト](http://www.vwnet.jp/windows/PowerShell/2018073001/Pester.htm)
# [pester/Pester: Pester is the ubiquitous test and mock framework for PowerShell.](https://github.com/pester/Pester)
