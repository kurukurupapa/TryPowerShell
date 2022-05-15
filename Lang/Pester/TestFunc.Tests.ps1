$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "TestFunc" {
  It "does something useful" {
    $true | Should Be $false
  }
}

Describe 'Demonstrating Code Coverage' {
  It 'Calls FunctionOne with no switch parameter set' {
    FunctionOne | Should Be 'SwitchParam was not set'
  }

  It 'Calls FunctionTwo' {
    FunctionTwo | Should Be 'I get executed'
  }
}
