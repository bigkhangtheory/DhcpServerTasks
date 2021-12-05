<#
    .DESCRIPTION
        The DhcpServerOptionDefinitions DSC configuration manages definitions and types for DHCP lease options.

    .PARAMETER OptionDefinitions
        [System.Collections.Hashtable[]]
        Specify a list of DHCP option definitions and types.

    .PARAMETER OptionId
        Key - UInt32
        Option ID, specify a number between 1 and 255.

    .PARAMETER VendorClass
        Key - String
        Vendor class. Use an empty string for standard option class.

    .PARAMETER Name
        Required - String
        Option name.

    .PARAMETER Type
        Required - String
        Allowed values: Byte, Word, Dword, DwordDword, IPv4Address, String, BinaryData, EncapsulatedData
        Option data type.

    .PARAMETER Multivalued
        Write - Boolean
        Whether option is multivalued or not.

    .PARAMETER Description
        Write - String
        Option description.

    .PARAMETER AddressFamily
        Key - String
        Allowed values: IPv4
        Class address family. Currently needs to be IPv4.

    .PARAMETER Ensure
        Write - String
        Allowed values: Present, Absent
        Whether the DHCP server class should exist.

    .NOTES
        Requirements

        - Target machine must be running Windows Server 2012 R2 or later.
        - Target machine must be running at minimum Windows PowerShell 5.0.
#>
#Requires -Module xDhcpServer


configuration DhcpServerOptionDefinitions
{
    param
    (
        [Parameter()]
        [System.Collections.Hashtable[]]
        $OptionDefinitions
    )

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    # ensure Windows DHCP feature
    WindowsFeature AddDhcp
    {
        Name   = 'DHCP'
        Ensure = 'Present'
    }
    $dependsOnAddDhcp = '[WindowsFeature]AddDhcp'

    if ($PSBoundParameters.ContainsKey('OptionDefinitions'))
    {
        foreach ($definition in $OptionDefinitions)
        {
            # remove case sensitivity of ordered Dictionary or Hashtables
            $definition = @{ } + $definition

            # the property 'OptionId' must be specified, otherwise fail
            if (-not $definition.ContainsKey('OptionId'))
            {
                throw 'ERROR: The property OptionId is not defined.'
            }

            # the property 'Type' must be specified, otherwise fail
            if (-not $definition.ContainsKey('Type'))
            {
                throw 'ERROR: The property Type is not defined.'
            }

            # if 'VendorClass' not specified, set to Standard Class with empty string
            if (-not $definition.ContainsKey('VendorClass'))
            {
                $definition.VendorClass = ''
            }

            # if 'MultiValued' not specified, default to $false
            if (-not $definition.ContainsKey('MultiValued'))
            {
                $definition.MultiValued = $false
            }

            # if 'AddressFamily' not specified, default to IPv4
            if (-not $definition.ContainsKey('AddressFamily'))
            {
                $definition.AddressFamily = 'IPv4'
            }

            # if not specified, ensure 'Present'
            if (-not $definition.ContainsKey('Ensure'))
            {
                $definition.Ensure = 'Present'
            }

            # this resource depends on installation of DHCP server
            $definition.DependsOn = $dependsOnAddDhcp

            # formulate execution name
            $executionName = "$("$($node.Name)_$($definition.OptionId)_$($definition.Type)_$($definition.Name)" -replace '[-().:\s]', '_')"

            # create DSC configuration for DHCP Server option definition
            $Splatting = @{
                ResourceName  = 'xDhcpServerOptionDefinition'
                ExecutionName = $executionName
                Properties    = $definition
                NoInvoke      = $true
            }
            (Get-DscSplattedResource @Splatting).Invoke($definition)

        } #end foreach
    } #end if
} #end configuration
