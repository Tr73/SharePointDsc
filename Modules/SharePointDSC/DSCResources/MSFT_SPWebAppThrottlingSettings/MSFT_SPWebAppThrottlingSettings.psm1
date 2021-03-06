function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $Url,
        [parameter(Mandatory = $false)] [System.UInt32]  $ListViewThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $AllowObjectModelOverride, 
        [parameter(Mandatory = $false)] [System.UInt32]  $AdminThreshold,
        [parameter(Mandatory = $false)] [System.UInt32]  $ListViewLookupThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $HappyHourEnabled,
        [parameter(Mandatory = $false)] [Microsoft.Management.Infrastructure.CimInstance] $HappyHour,
        [parameter(Mandatory = $false)] [System.UInt32]  $UniquePermissionThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $RequestThrottling,
        [parameter(Mandatory = $false)] [System.Boolean] $ChangeLogEnabled,
        [parameter(Mandatory = $false)] [System.UInt32]  $ChangeLogExpiryDays,
        [parameter(Mandatory = $false)] [System.Boolean] $EventHandlersEnabled,
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )

    Write-Verbose -Message "Getting web application '$url' throttling settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments @($PSBoundParameters,$PSScriptRoot) -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]
        
        $wa = Get-SPWebApplication -Identity $params.Url -ErrorAction SilentlyContinue
        if ($null -eq $wa) { return $null }

        Import-Module (Join-Path $ScriptRoot "..\..\Modules\SharePointDSC.WebApplication\SPWebApplication.Throttling.psm1" -Resolve)

        $result = Get-SPDSCWebApplicationThrottlingSettings -WebApplication $wa
        $result.Add("Url", $params.Url)
        $result.Add("InstallAccount", $params.InstallAccount)
        return $result
    }
    return $result
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $Url,
        [parameter(Mandatory = $false)] [System.UInt32]  $ListViewThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $AllowObjectModelOverride, 
        [parameter(Mandatory = $false)] [System.UInt32]  $AdminThreshold,
        [parameter(Mandatory = $false)] [System.UInt32]  $ListViewLookupThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $HappyHourEnabled,
        [parameter(Mandatory = $false)] [Microsoft.Management.Infrastructure.CimInstance] $HappyHour,
        [parameter(Mandatory = $false)] [System.UInt32]  $UniquePermissionThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $RequestThrottling,
        [parameter(Mandatory = $false)] [System.Boolean] $ChangeLogEnabled,
        [parameter(Mandatory = $false)] [System.UInt32]  $ChangeLogExpiryDays,
        [parameter(Mandatory = $false)] [System.Boolean] $EventHandlersEnabled,
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )

    Write-Verbose -Message "Setting web application '$Url' throttling settings"
    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments @($PSBoundParameters,$PSScriptRoot) -ScriptBlock {
        $params = $args[0]
        $ScriptRoot = $args[1]

        $wa = Get-SPWebApplication -Identity $params.Url -ErrorAction SilentlyContinue
        if ($null -eq $wa) {
            throw "Web application $($params.Url) was not found"
            return
        }

        Import-Module (Join-Path $ScriptRoot "..\..\Modules\SharePointDSC.WebApplication\SPWebApplication.Throttling.psm1" -Resolve)
        Set-SPDSCWebApplicationThrottlingSettings -WebApplication $wa -Settings $params
        $wa.Update()

        # Happy hour settings
        if ($params.ContainsKey("HappyHour") -eq $true) {
            # Happy hour settins use separate update method so use a fresh web app to update these
            $wa2 = Get-SPWebApplication -Identity $params.Url
            Set-SPDSCWebApplicationHappyHourSettings -WebApplication $wa2 -Settings $params.HappyHour
        }
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String]  $Url,
        [parameter(Mandatory = $false)] [System.UInt32]  $ListViewThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $AllowObjectModelOverride, 
        [parameter(Mandatory = $false)] [System.UInt32]  $AdminThreshold,
        [parameter(Mandatory = $false)] [System.UInt32]  $ListViewLookupThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $HappyHourEnabled,
        [parameter(Mandatory = $false)] [Microsoft.Management.Infrastructure.CimInstance] $HappyHour,
        [parameter(Mandatory = $false)] [System.UInt32]  $UniquePermissionThreshold,
        [parameter(Mandatory = $false)] [System.Boolean] $RequestThrottling,
        [parameter(Mandatory = $false)] [System.Boolean] $ChangeLogEnabled,
        [parameter(Mandatory = $false)] [System.UInt32]  $ChangeLogExpiryDays,
        [parameter(Mandatory = $false)] [System.Boolean] $EventHandlersEnabled,
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )

    $CurrentValues = Get-TargetResource @PSBoundParameters
    Write-Verbose -Message "Testing for web application '$Url' throttling settings"
    if ($null -eq $CurrentValues) { return $false }

    Import-Module (Join-Path $PSScriptRoot "..\..\Modules\SharePointDSC.WebApplication\SPWebApplication.Throttling.psm1" -Resolve)
    return Test-SPDSCWebApplicationThrottlingSettings -CurrentSettings $CurrentValues -DesiredSettings $PSBoundParameters
}


Export-ModuleMember -Function *-TargetResource

