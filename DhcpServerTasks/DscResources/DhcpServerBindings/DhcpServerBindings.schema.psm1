<#
    .SYNOPSIS
        The DhcpServerBindings DSC configuration manages network bindings on the server level.
    .DESCRIPTION
        The DhcpServerBindings DSC configuration manages network bindings on the server level.

    .PARAMETER NetAdapters
        [System.Collections.Hashtable[]]
        Specify a list of Network Adapters to bind the DHCP service.

    .PARAMETER NetAdapters::InterfaceAlias
        Key - [System.String]
        Specifies the alias name for the network interface to manage.

    .PARAMETER NetAdapaters::Ensure
        Write - [System.String]
        Allowed values: Present, Absent
        Specifies if the interface alias should be set or removed. Defaults to 'Present'.

    .NOTES
        Requirements

        - Target machine must be running Windows Server 2012 R2 or later.
        - Target machine must be running at minimum Windows PowerShell 5.0.
#>
#Requires -Module xDhcpServer


configuration DhcpServerBindings
{
    param
    (
        [Parameter()]
        [System.Collections.Hashtable[]]
        $NetAdapters
    )

    <#
        Import required modules
    #>
    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -Module PsDesiredStateConfiguration

    # ensure Windows DHCP feature
    WindowsFeature AddDhcp
    {
        Name   = 'DHCP'
        Ensure = 'Present'
    }
    $dependsOnAddDhcp = '[WindowsFeature]AddDhcp'


    # if specified, begin creating DSC resource for DhcpServerBinding
    if ($PSBoundParameters.ContainsKey('NetAdapters'))
    {
        # enumerate each NetAdapter
        foreach ($netAdapter in $NetAdapters)
        {
            # remove case sensitivity of ordered dictionary or hashtables
            $netAdapter = @{ } + $netAdapter

            # the property 'InterfaceAlias' must be specified, otherwise fail
            if (-not $netAdapter.ContainsKey('InterfaceAlias'))
            {
                throw 'ERROR: The property InterfaceAlias is not defined.'
            }

            # if not specified, ensure 'Present'
            if (-not $netAdapter.ContainsKey('Ensure'))
            {
                $netAdapter.Ensure = 'Present'
            }

            # create execution name for the resource
            $executionName = "$("$($node.Name)_$($netAdapter.InterfaceAlias)_$($netAdapter.Ensure)" -replace '[-().:\s]', '_')"

            # create DSC resource
            $Splatting = @{
                ResourceName  = 'DhcpServerBinding'
                ExecutionName = $executionName
                Properties    = $netAdapter
                NoInvoke      = $true
            }
            (Get-DscSplattedResource @Splatting).Invoke($netAdapter)
        } #end foreach
    } #end if
} #end configuration