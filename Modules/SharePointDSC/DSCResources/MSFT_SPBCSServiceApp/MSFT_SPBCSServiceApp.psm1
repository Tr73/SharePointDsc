function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String] $Name,
        [parameter(Mandatory = $true)]  [System.String] $ApplicationPool,
        [parameter(Mandatory = $false)] [System.String] $DatabaseName,
        [parameter(Mandatory = $false)] [System.String] $DatabaseServer,
        [parameter(Mandatory = $false)] [ValidateSet("Present","Absent")] [System.String] $Ensure = "Present",
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )
    Write-Verbose -Message "Getting BCS service app '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]
        
        $serviceApps = Get-SPServiceApplication -Name $params.Name -ErrorAction SilentlyContinue 
        $nullReturn = @{
            Name = $params.Name
            ApplicationPool = $params.ApplicationPool
            DatabaseName = $null
            DatabaseServer = $null
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        } 
        if ($null -eq $serviceApps) { 
            return $nullReturn 
        }
        $serviceApp = $serviceApps | Where-Object { $_.TypeName -eq "Business Data Connectivity Service Application" }

        If ($null -eq $serviceApp) { 
            return $nullReturn
        } else {
            $returnVal =  @{
                Name = $serviceApp.DisplayName
                ApplicationPool = $serviceApp.ApplicationPool.Name
                DatabaseName = $serviceApp.Database.Name
                DatabaseServer = $serviceApp.Database.Server.Name
                Ensure = "Present"
                InstallAccount = $params.InstallAccount
            }
            return $returnVal
        }
    }
    return $result
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]  [System.String] $Name,
        [parameter(Mandatory = $true)]  [System.String] $ApplicationPool,
        [parameter(Mandatory = $false)] [System.String] $DatabaseName,
        [parameter(Mandatory = $false)] [System.String] $DatabaseServer,
        [parameter(Mandatory = $false)] [ValidateSet("Present","Absent")] [System.String] $Ensure = "Present",
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )

    $result = Get-TargetResource @PSBoundParameters

    if ($result.Ensure -eq "Absent" -and $Ensure -eq "Present") {
        # The service app doesn't exist but should
        
        Write-Verbose -Message "Creating BCS Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
            $params = $args[0]
            

            New-SPBusinessDataCatalogServiceApplication -Name $params.Name `
                                                        -ApplicationPool $params.ApplicationPool `
                                                        -DatabaseName $params.DatabaseName `
                                                        -DatabaseServer $params.DatabaseServer
        }
    }
    
    if ($result.Ensure -eq "Present" -and $Ensure -eq "Present") {
        # The service app exists but has the wrong application pool
        
        if ($ApplicationPool -ne $result.ApplicationPool) {
            Write-Verbose -Message "Updating BCS Service Application $Name"
            Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
                $params = $args[0]
                

                $appPool = Get-SPServiceApplicationPool -Identity $params.ApplicationPool

                Get-SPServiceApplication -Name $params.Name `
                    | Where-Object { $_.TypeName -eq "Business Data Connectivity Service Application" } `
                    | Set-SPBusinessDataCatalogServiceApplication -ApplicationPool $appPool
            }
        }
    }
    
    if ($Ensure -eq "Absent") {
        # The service app should not exit
        Write-Verbose -Message "Removing BCS Service Application $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
                $params = $args[0]
                
                $appService =  Get-SPServiceApplication -Name $params.Name | Where-Object { $_.TypeName -eq "Business Data Connectivity Service Application"  }
                Remove-SPServiceApplication $appService -Confirm:$false
            }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]  [System.String] $Name,
        [parameter(Mandatory = $true)]  [System.String] $ApplicationPool,
        [parameter(Mandatory = $false)] [System.String] $DatabaseName,
        [parameter(Mandatory = $false)] [System.String] $DatabaseServer,
        [parameter(Mandatory = $false)] [ValidateSet("Present","Absent")] [System.String] $Ensure = "Present",
        [parameter(Mandatory = $false)] [System.Management.Automation.PSCredential] $InstallAccount
    )
    
    $PSBoundParameters.Ensure = $Ensure
    
    Write-Verbose -Message "Testing for BCS Service Application '$Name'"
    $CurrentValues = Get-TargetResource @PSBoundParameters
    
    return Test-SPDSCSpecificParameters -CurrentValues $CurrentValues -DesiredValues $PSBoundParameters -ValuesToCheck @("ApplicationPool", "Ensure")
}

Export-ModuleMember -Function *-TargetResource
