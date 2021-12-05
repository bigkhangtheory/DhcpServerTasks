configuration DhcpServerOptions
{
    param
    (
        [Parameter()]
        [System.Collections.Hashtable[]]
        $Options
    )

    <#
        Import required modules
    #>
    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration


    # ensure Windows DHCP feature
    WindowsFeature AddDhcp
    {
        Name   = 'DHCP'
        Ensure = 'Present'
    }
    $dependsOnAddDhcp = '[WindowsFeature]AddDhcp'


    if ($PSBoundParameters.ContainsKey('Options'))
    {
        # iterate through each DHCP server option
        foreach ($option in $Options)
        {
            # remove case sensitivity of ordered Dictionary or Hashtables
            $option = @{ } + $option

            # the property 'OptionId' must be specified, otherwise fail
            if (-not $option.ContainsKey('OptionId'))
            {
                throw 'ERROR: The property OptionId is not defined.'
            }

            # the property 'Value' must be specified, otherwise fail
            if (-not $option.ContainsKey('Value'))
            {
                throw 'ERROR: The property Value is not defined.'
            }

            # if VendorClass not specified, set to Standard Class with empty string
            if (-not $option.ContainsKey('VendorClass'))
            {
                $option.VendorClass = ''
            }

            # if UserClass not specified, set to Standard Class with empty string
            if (-not $option.ContainsKey('UserClass'))
            {
                $option.UserClass = ''
            }

            # this configuration supports 'IPv4' only
            if (-not $option.ContainsKey('AddressFamily'))
            {
                $option.AddressFamily = 'IPv4'
            }

            # if not specifed, ensure 'Present'
            if (-not $option.ContainsKey('Ensure'))
            {
                $option.Ensure = 'Present'
            }

            # this configuration depends on Windows DHCP server
            $option.DependsOn = '[WindowsFeature]AddDhcp'

            # formulate execution name
            $executionName = "$("$($node.Name)_$($option.OptionId)_$($option.Valud)" -replace '[-().:\s]', '_')"

            # create DSC configuration for DHCP server-wide option value
            $Splatting = @{
                ResourceName  = 'DhcpServerOptionValue'
                ExecutionName = $executionName
                Properties    = $option
                NoInvoke      = $true
            }
            (Get-DscSplattedResource @Splatting).Invoke($option)
        } #end foreach
    } #end if
} #end configuration
