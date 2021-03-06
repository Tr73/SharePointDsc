# SharePointDSC

Build status: [![Build status](https://ci.appveyor.com/api/projects/status/aj6ce04iy5j4qcd4/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xsharepoint/branch/master)

Discuss SharePointDSC now: [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/PowerShell/xSharePoint?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

The SharePointDSC PowerShell module (formerly known as xSharePoint) provides DSC resources that can be used to deploy and manage a SharePoint farm. 

Please leave comments, feature requests, and bug reports in the issues tab for this module.

If you would like to modify SharePointDSC module, please feel free.  
As specified in the license, you may copy or modify this resource as long as they are used on the Windows Platform.
Please refer to the [Contribution Guidelines](https://github.com/PowerShell/SharePointDSC/wiki/Contributing%20to%20SharePointDSC) for information about style guides, testing and patterns for contributing to DSC resources.

## Installation

To manually install the module, download the source code and unzip the contents of the \Modules\SharePointDSC directory to the $env:ProgramFiles\WindowsPowerShell\Modules folder 

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0) run the following command:

    Find-Module -Name SharePointDSC -Repository PSGallery | Install-Module

To confirm installation, run the below command and ensure you see the SharePoint DSC resoures available:

    Get-DscResource -Module SharePointDSC


## Requirements 
The minimum PowerShell version required is 4.0, which ships in Windows 8.1 or Windows Server 2012R2 (or higher versions).
The preferred version is PowerShell 5.0 or higher, which ships with Windows 10 or Windows Server 2016. 
This is discussed [on the SharePointDSC wiki](https://github.com/PowerShell/SharePointDSC/wiki/Remote%20sessions%20and%20the%20InstallAccount%20variable), but generally PowerShell 5 will run the SharePoint DSC resources faster and with improved verbose level logging.

## Documentation and examples

For a full list of resources in SharePointDSC and examples on their use, check out the [SharePointDSC wiki](https://github.com/PowerShell/SharePointDSC/wiki).
You can also review the "examples" directory in the SharePointDSC module for some general use scenarios for all of the resources that are in the module.

## Changelog

A full list of changes in each version can be found in the [change log](CHANGELOG.md)

## Project Throughput
[![Throughput Graph](https://graphs.waffle.io/PowerShell/xSharePoint/throughput.svg)](https://waffle.io/PowerShell/xSharePoint/metrics)
