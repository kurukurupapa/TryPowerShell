# PowerShell�p�̒P�̃e�X�g�c�[�� Pester ���g���Ă݂�

# ����m�F
# Visual Studio Code �Ȃ�A���s�������s��I�����āAF8�L�[�Ŏ��s�ł���B

Set-Location "Lang\Pester"
New-Fixture -Name TestFunc
Invoke-Pester
Invoke-Pester .\TestFunc.Tests.ps1 -CodeCoverage .\TestFunc.ps1

# �Q�l�T�C�g
# [Pester �� PowerShell �̃t�@���N�V���� �e�X�g](http://www.vwnet.jp/windows/PowerShell/2018073001/Pester.htm)
# [pester/Pester: Pester is the ubiquitous test and mock framework for PowerShell.](https://github.com/pester/Pester)
