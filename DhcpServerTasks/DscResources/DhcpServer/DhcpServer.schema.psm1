<#
    .SYNOPSIS
        The DhcpServer DSC configuration manages IP address scopes.

    .DESCRIPTION
        The DhcpServer DSC configuration manages IP address scopes.

        An IP-address scope is a consecutive range of possible IP addresses that the DHCP server can lease to clients on a subnet.

    .PARAMETER Scopes
        [System.Collections.Hashtable[]]
        Specifies a list of DHCP Scope resources

    .PARAMETER Scopes::ScopeId
        Key - [System.String]
        ScopeId for the given scope

    .PARAMETER Scopes::Name
        Required - [System.String]
        Name of DHCP Scope

    .PARAMETER Scopes::SubnetMask
        Required - [System.String]
        Subnet mask for the scope specified in IP address format

    .PARAMETER Scopes::IPStartRange
        Required - [System.String]
        Starting address to set for this scope

    .PARAMETER Scopes::IPEndRange
        Required - [System.String]
        Ending address to set for this scope

    .PARAMETER Scopes::Description
        Write - [System.String]
        Description of DHCP Scope

    .PARAMETER Scopes::LeaseDuration
        Write - [System.String]
        Time interval for which an IP address should be leased

    .PARAMETER Scopes::State
        Write - [System.String]
        Allowed values: Active, Inactive
        Whether scope should be active or inactive

    .PARAMETER Scopes::AddressFamily
        Write - [System.String]
        Allowed values: IPv4
        Address family type

    .PARAMETER Scopes::Ensure
        Write - [System.String]
        Allowed values: Present, Absent
        Whether scope should be set or removed

    .PARAMETER Scopes::ExclusionRanges
        [System.Collection.Hashtable[]]
        Specifies a list of DHCP Scope Exclusion resources

    .PARAMETER Scopes::ExclusionRanges::IPStartRange
        Key - [System.String]
        Specifies the starting IP address of the range being excluded

    .PARAMETER Scopes::ExclusionRanges::IPEndRange
        Key - [System.String]
        The end IP address of the range being excluded

    .PARAMETER Scopes::OptionValues
        [System.Collections.Hashtable[]]
        Specifies a list of DHCP Scope Option Value resources

    .PARAMETER Scopes::OptionValues::OptionId
        Key - [System.UInt32]
        Option ID, specify an integer between 1 and 255.

    .PARAMETER Scopes::OptionValues::Value
        Write - [System.String[]]
        Option data value. Could be an array of string for a multivalued option.

    .PARAMETER Scopes::Reservations
        [System.Collections.Hashtable[]]
        Specifies a list of DHCP Scope Reservations resources

    .PARAMETER Scopes::Reservations::IPAddress
        Key - [System.String]
        IP address of the reservation for which the properties are modified

    .PARAMETER Scopes::Reservations::ClientMACAddress
        Required - [System.String]
        Client MAC Address to set on the reservation

    .PARAMETER Scopes::Reservations::Name
        Write - [System.String]
        Reservation name

    .NOTES
        Requirements
        - Target machine must be running Windows Server 2012 R2 or later.
        - Target machine must be running at minimum Windows PowerShell 5.0.

    .NOTES
        Khang M. Nguyen
        @bigkhangtheory
#>
#Requires -Module xDhcpServer
#Requires -Module 'Indented.NET.IP'


configuration DhcpServer
{
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable[]]
        $Scopes,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $DomainCredential
    )

    <#
        Import required modules
    #>
    Import-Module -Name 'Indented.NET.IP'
    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration


    <#
        Install DHCP role dependencies
    #>
    # ensure Windows DHCP feature
    WindowsFeature AddDhcp
    {
        Name   = 'DHCP'
        Ensure = 'Present'
    }
    $dependsOnAddDhcp = '[WindowsFeature]AddDhcp'

    # if credentials specified, perform DHCP authorization
    if ($DomainCredential)
    {
        xDhcpServerAuthorization "$($node.Name)_DhcpServerActivation"
        {
            Ensure               = 'Present'
            PsDscRunAsCredential = $DomainCredential
            IsSingleInstance     = 'Yes'
            DependsOn            = $dependsOnAddDhcp
        }
    }


    <#
        Enumerate DHCP scope resources
    #>
    foreach ($s in $Scopes)
    {
        # scope parameters as hashtable
        $myScope = @{}

        # remove case sensitivity of ordered Dictionary or Hashtables
        $s = @{ } + $s

        # the property 'Name' must be specified, otherwise fail
        if (-not $s.ContainsKey('Name'))
        {
            throw 'ERROR: The property Name is not defined.'
        }
        else
        {
            $myScope.Name = $s.Name
        }


        <#
            Extrapolate the Subnet into DHCP scope properties
        #>
        try
        {
            $network = Get-NetworkSummary -IPAddress $s.Subnet
        }
        catch
        {
            throw "$($_.Exception.Message)"
        }

        # set ScopeId
        $myScope.ScopeId = $network.NetworkAddress.IPAddressToString
        # set SubnetMask
        $myScope.SubnetMask = $network.Mask.IPAddressToString
        # set IPStartRange
        $myScope.IPStartRange = $network.HostRange.Split('-')[0].Trim()
        # set IPEndRange
        $myScope.IPEndRange = $network.HostRange.Split('-')[1].Trim()

        # if 'LeaseDuration' specified, validate TimeSpan format, otherwise set default
        if ($s.ContainsKey('LeaseDuration'))
        {
            # validate
            if (($s.LeaseDuration -as [System.TimeSpan] -eq $null))
            {
                throw "ERROR: LeaseDuration value $($s.LeaseDuration) is not a valid [System.TimeSpan] format."
            }
            else
            {
                $myScope.LeaseDuration = $s.LeaseDuration
            }
        }
        else
        {
            $myScope.LeaseDuration = '08.00:00:00'
        }

        # if 'State' not specified, set default to 'Active'
        if (-not $s.ContainsKey('State'))
        {
            $myScope.State = 'Active'
        }

        # if 'AddressFamily' not specified, set default to 'IPv4'
        if (-not $s.ContainsKey('AddressFamily'))
        {
            $myScope.AddressFamily = 'IPv4'
        }

        # if not specifed, ensure 'Present'
        if (-not $s.ContainsKey('Ensure'))
        {
            $myScope.Ensure = 'Present'
        }

        # this resource depends on installation of DHCP Server
        $myScope.DependsOn = $dependsOnAddDhcp

        # formulate execution name
        $executionName = "$("$($myScope.Name)_$($s.Subnet)_$($myScope.LeaseDuration)" -replace '[()-.:/\s]', '_')"


        $object = @"

        Creating DSC resource for xDhcpServerScope with the following values:

        xDhcpServerScope "$executionName"
        {
            ScopeId       = $($myScope.ScopeId)
            Name          = $($myScope.Name)
            SubnetMask    = $($myScope.SubnetMask)
            IPStartRange  = $($myScope.IPStartRange)
            IPEndRange    = $($myScope.IPEndRange)
            LeaseDuration = $($myScope.LeaseDuration)
            State         = $($myScope.State)
            AddressFamily = $($myScope.AddressFamily)
            Ensure        = $($myScope.Ensure)
            DependsOn     = $($myScope.DependsOn)
        }


"@
        Write-Host "$object" -ForegroundColor Yellow

        # create DSC resource
        $Splatting = @{
            ResourceName  = 'xDhcpServerScope'
            ExecutionName = $executionName
            Properties    = $myScope
            NoInvoke      = $true
        }
        (Get-DscSplattedResource @Splatting).Invoke($myScope)

        # set DHCP Scope resource dependency
        $dependsOnDhcpServerScope = "[xDhcpServerScope]$executionName"


        # Scope Exclusions - if specified, create DSC resource for DHCP scope exclusion ranges
        if ($s.ContainsKey('ExclusionRanges'))
        {
            # iterate through each exclusion
            foreach ($e in $s.ExclusionRanges)
            {
                # remove case sensitivity of ordered Dictionary or Hashtables
                $e = @{ } + $e

                # set the Scope ID for the exclusion range
                $e.ScopeId = $myScope.ScopeId

                # the property 'IPStartRange' must be specified and must fall within the ScopeID range
                if (-not $e.ContainsKey('IPStartRange'))
                {
                    throw 'ERROR: The property IPStartRange is not defined.'
                }
                elseif (-not (Test-SubnetMember -SubjectIPAddress $e.IPStartRange -ObjectIPAddress $myScope.ScopeId -ObjectSubnetMask $myScope.SubnetMask))
                {
                    throw "ERROR: The value $($e.IPStartRange) is not a valid address."
                }


                # the property 'IPEndRange' must be specified and must fall within the ScopeID range
                if (-not $e.ContainsKey('IPEndRange'))
                {
                    throw 'ERROR: The property IPEndRange is not defined.'
                }
                elseif (-not (Test-SubnetMember -SubjectIPAddress $e.IPEndRange -ObjectIPAddress $myScope.ScopeId -ObjectSubnetMask $myScope.SubnetMask))
                {
                    throw "ERROR: The value $($e.IPEndRange) is not a valid address."
                }

                # set the address family
                $e.AddressFamily = $myScope.AddressFamily

                # if not specifed, ensure 'Present'
                if (-not $e.ContainsKey('Ensure'))
                {
                    $e.Ensure = 'Present'
                }

                # this resource depends on DHCP scope
                $e.DependsOn = $dependsOnDhcpServerScope


                # formulate execution name
                $executionName = "Exclusion_$("$($e.IPStarRange)_$($e.IPEndRange)" -replace '[()-.:\s]', '_')"



                $object = @"

                Creating DSC resource for DhcpServerExclusionRange with the following values:

                DhcpServerExclusionRange "$executionName"
                {
                    ScopeId       = $($e.ScopeId)
                    IPStartRange  = $($e.IPStartRange)
                    IPEndRange    = $($e.IPEndRange)
                    AddressFamily = $($e.AddressFamily)
                    Ensure        = $($e.Ensure)
                    DependsOn     = $($e.DependsOn)
                }


"@
                Write-Host "$object" -ForegroundColor Yellow

                # create DSC resource
                $Splatting = @{
                    ResourceName  = 'DhcpServerExclusionRange'
                    ExecutionName = $executionName
                    Properties    = $e
                    NoInvoke      = $true
                }
                (Get-DscSplattedResource @Splatting).Invoke($e)
            }
        }

        # Scope Options - if specified, create DSC resource for DHCP scope-level options
        if ($s.ContainsKey('OptionValues'))
        {
            # iterate through each scope option
            foreach ($o in $s.OptionValues)
            {
                # remove case sensitivity of ordered Dictionary or Hashtables
                $o = @{ } + $o

                # set the Scope ID for the exclusion range
                $o.ScopeId = $myScope.ScopeId

                # the property 'OptionId' must be specified and must fall within the ScopeID range
                if (-not $o.ContainsKey('OptionId'))
                {
                    throw 'ERROR: The property OptionId is not defined.'
                }


                # the property 'OptionId' must be specified and must fall within the ScopeID range
                if (-not $o.ContainsKey('Value'))
                {
                    throw 'ERROR: The property Value is not defined.'
                }

                # if VendorClass not specified, set to Standard Class with empty string
                if (-not $o.ContainsKey('VendorClass'))
                {
                    $o.VendorClass = ''
                }
                # if UserClass not specified, set to Standard Class with empty string
                if (-not $o.ContainsKey('UserClass'))
                {
                    $o.UserClass = ''
                }

                # if 'Ensure' not specified, set to 'Present'
                if (-not $o.ContainsKey('Ensure'))
                {
                    $o.Ensure = 'Present'
                }

                # set the address family
                $o.AddressFamily = $myScope.AddressFamily

                # this resource depends on DHCP scope
                $o.DependsOn = $dependsOnDhcpServerScope


                # formulate execution name
                $executionName = "Option_$("$($o.ScopeId)_$($o.OptionId)_$($o.Value)" -replace '[()-.:\s]', '_')"



                $object = @"

                Creating DSC resource for DhcpScopeOptionValue with the following values:

                DhcpScopeOptionValue"$executionName"
                {
                    ScopeId       = $($o.ScopeId)
                    OptionId      = $($o.OptionId)
                    Value         = $($o.Value)
                    VendorClass   = $($o.VendorClass)
                    UserClass     = $($o.UserClass)
                    AddressFamily = $($o.AddressFamily)
                    Ensure        = $($o.Ensure)
                    DependsOn     = $($o.DependsOn)
                }


"@
                Write-Host "$object" -ForegroundColor Yellow


                # create DSC resource
                $Splatting = @{
                    ResourceName  = 'DhcpScopeOptionValue'
                    ExecutionName = $executionName
                    Properties    = $o
                    NoInvoke      = $true
                }
                (Get-DscSplattedResource @Splatting).Invoke($o)
            }
        } #end if ($s.OptionValues)


        # Scope Options - if specified, create DSC resource for DHCP scope-level options
        if ($s.ContainsKey('Reservations'))
        {
            # iterate through each scope option
            foreach ($r in $s.Reservations)
            {
                # remove case sensitivity of ordered Dictionary or Hashtables
                $r = @{ } + $r

                # set the Scope ID for the exclusion range
                $r.ScopeId = $myScope.ScopeId

                # the property 'Name' must be specified and must fall within the ScopeID range
                if (-not $r.ContainsKey('Name'))
                {
                    throw 'ERROR: The property Name is not defined.'
                }

                # the property 'IPAddress' must be specified and must fall within the ScopeID range
                if (-not $r.ContainsKey('IPAddress'))
                {
                    throw 'ERROR: The property IPAddress is not defined.'
                }
                elseif (-not (Test-SubnetMember -SubjectIPAddress $r.IPAddress -ObjectIPAddress $myScope.ScopeId -ObjectSubnetMask $myScope.SubnetMask))
                {
                    throw "ERROR: The value $($r.IPAddress) is not a valid address."
                }

                # the property 'OptionId' must be specified and must fall within the ScopeID range
                if (-not $r.ContainsKey('ClientMACAddress'))
                {
                    throw 'ERROR: The property ClientMACAddress is not defined.'
                }

                # if 'Ensure' not specified, set to 'Present'
                if (-not $o.ContainsKey('Ensure'))
                {
                    $o.Ensure = 'Present'
                }

                # set the address family
                $r.AddressFamily = $myScope.AddressFamily

                # this resource depends on DHCP scope
                $r.DependsOn = $dependsOnDhcpServerScope

                # formulate execution name
                $executionName = "Reservation_$("$($r.ScopeId)_$($r.IPAddress)_$($r.ClientMACAddress)" -replace '[()-.:\s]', '_')"
                # create DSC resource
                $Splatting = @{
                    ResourceName  = 'xDhcpServerReservation'
                    ExecutionName = $executionName
                    Properties    = $r
                    NoInvoke      = $true
                }
                (Get-DscSplattedResource @Splatting).Invoke($r)
            }
        } #end if ($s.OptionValues)
    }
}
