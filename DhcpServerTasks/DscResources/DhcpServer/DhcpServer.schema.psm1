configuration DhcpServer
{
    param
    (
        [hashtable[]]
        $Scopes,

        [pscredential]
        $DomainCredential
    )

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    # ensure Windows DHCP feature
    WindowsFeature AddDhcp
    {
        Name   = 'DHCP'
        Ensure = 'Present'
    }

    # if credentials specified, perform DHCP authorization
    if ($DomainCredential)
    {
        xDhcpServerAuthorization "$($node.Name)_DhcpServerActivation" {
            Ensure               = 'Present'
            PsDscRunAsCredential = $DomainCredential
            IsSingleInstance     = 'Yes'
        }
    }

    foreach ($s in $Scopes)
    {
        # remove case sensitivity of ordered Dictionary or Hashtables
        $s = @{ } + $s

        # if not specifed, ensure 'Present'
        if (-not $s.ContainsKey('Ensure'))
        {
            $s.Ensure = 'Present'
        }

        # formulate execution name
        $executionName = "$($node.Name)_$($s.ScopeId -replace '[-().:\s]', '_')"

        # configure DSC resource for DHCP scope
        xDhcpServerScope "$executionName"
        {
            ScopeId       = $s.ScopeId
            Name          = $s.Name
            SubnetMask    = $s.SubnetMask
            IPStartRange  = $s.IPStartRange
            IPEndRange    = $s.IPEndRange
            LeaseDuration = $s.LeaseDuration
            State         = $s.State
            AddressFamily = $s.AddressFamily
            Ensure        = $s.Ensure
            DependsOn     = '[WindowsFeature]AddDhcp'
        }
        $dependsOnDhcpServerScope = "[xDhcpServerScope]$executionName"


        # Scope Exclusions - if specified, create DSC resource for DHCP scope exclusion ranges
        if ($null -ne $s.ScopeExclusions)
        {
            $myScopeExclusions = $s.ScopeExclusions

            # iterate through each exclusion
            foreach ($exclusion in $myScopeExclusions)
            {
                # formulate execution name
                $executionName = "$($node.Name)_$($exclusion.IPEndRange -replace '[-().:\s]', '_')"
                
                # if 'Ensure' not specified, set to 'Present'
                if ($null -eq $exclusion.Ensure)
                {
                    $exclusion.Ensure = 'Present'
                }

                # create DSC resource
                DhcpServerExclusionRange "$executionName"
                {
                    ScopeId       = $s.ScopeId
                    IPStartRange  = $exclusion.IPStartRange
                    IPEndRange    = $exclusion.IPEndRange
                    AddressFamily = $s.AddressFamily
                    Ensure        = $exclusion.Ensure
                    DependsOn     = $dependsOnDhcpServerScope
                }
                
            }
        }


        # Scope Options - if specified, create DSC resource for DHCP scope-level options
        if ($null -ne $s.ScopeOptions)
        {
            $myScopeOptions = $s.ScopeOptions

            # iterate through each scope option
            foreach ($option in $myScopeOptions)
            {
                # formulate execution name
                $executionName = "$($node.Name)_option_$($option.OptionId)"

                # if VendorClass not specified, set to Standard Class with empty string
                if ($null -eq $option.VendorClass)
                {
                    $option.VendorClass = ''
                }
                # if UserClass not specified, set to Standard Class with empty string
                if ($null -eq $option.UserClass)
                {
                    $option.UserClass = ''
                }

                # if 'Ensure' not specified, set to 'Present'
                if ($null -eq $option.Ensure)
                {
                    $option.Ensure = 'Present'
                }

                # create DSC resource
                DhcpScopeOptionValue "$executionName"
                {
                    ScopeId       = $s.ScopeId
                    OptionId      = $option.OptionId
                    Value         = $option.Value
                    VendorClass   = $option.VendorClass
                    UserClass     = $option.UserClass
                    AddressFamily = $s.AddressFamily
                    Ensure        = $option.Ensure
                    DependsOn     = $dependsOnDhcpServerScope
                }
            }
        }


        # Scope Reservations - if specified, create DSC Resource for DHCP scope-level reservations
        if ($null -ne $s.ScopeReservations)
        {
            $myScopeReservations = $s.ScopeReservations

            # iterate through each scope reservation
            foreach ($reservation in $myScopeReservations)
            {
                # validate MAC address format
                if ($($reservation.ClientMacAddress).Length -ne 12)
                {
                    throw 'ERROR: ScopeReservations:ClientMacAddress should be formatted with 12 numeric characters only.'
                }

                # formulate execution name
                $executionName = "$($node.Name)_$($s.ScopeId -replace '[-().:\s]', '_')_$($reservation.Name -replace '[-().:\s]', '_')"

                # if 'Ensure' not specified, set to 'Present'
                if ($null -eq $reservation.Ensure)
                {
                    $reservation.Ensure = 'Present'
                }

                # create DSC resource
                xDhcpServerReservation "$executionName"
                {
                    ScopeId          = $s.ScopeId
                    IpAddress        = $reservation.IpAddress
                    ClientMacAddress = $reservation.ClientMacAddress
                    Name             = $reservation.Name
                    AddressFamily    = $s.AddressFamily
                    Ensure           = $reservation.Ensure
                    DependsOn        = $dependsOnDhcpServerScope
                }
            }
        }
    }
}
