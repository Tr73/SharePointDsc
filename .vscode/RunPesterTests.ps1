Import-Module (Join-Path $PSScriptRoot "..\Tests\SharePointDSC.TestHarness.psm1"  -Resolve) -Force

$DscTestsPath = Join-Path $PSScriptRoot "..\Modules\SharePointDSC\DscResource.Tests" -Resolve
if ((Test-Path $DscTestsPath) -eq $false) {
    Write-Warning "Unable to locate DscResource.Tests repo at '$DscTestsPath', common DSC resource tests will not be executed"
    Invoke-SPDSCTests -CalculateTestCoverage $false
} else {
    Invoke-SPDSCTests -DscTestsPath $DscTestsPath -CalculateTestCoverage $false
}

