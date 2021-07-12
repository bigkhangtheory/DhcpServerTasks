configuration DhcpServerOptions
{
    param
    (
        [hashtable[]]
        $Options
    )

    <#
    AddressFamily = [string]{ IPv4 }
    OptionId = [UInt32]
    UserClass = [string]
    VendorClass = [string]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [PsDscRunAsCredential = [PSCredential]]
    [Value = [string[]]]
#>

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    # ensure Windows DHCP feature
    WindowsFeature AddDhcp 
    {
        Name   = 'DHCP'
        Ensure = 'Present'
    }

    # iterate through each DHCP server option
    foreach ($option in $Options)
    {
        # remove case sensitivity of ordered Dictionary or Hashtables
        $option = @{ } + $option

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

        # this configuration supports 'IPv4' only
        if ($null -eq $option.AddressFamily)
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
        $executionName = "$($node.Name)_$($option.OptionId)"

        # create DSC configuration for DHCP server-wide option value
        $Splatting = @{
            ResourceName  = 'DhcpServerOptionValue'
            ExecutionName = $executionName
            Properties    = $option
            NoInvoke      = $true
        }
        (Get-DscSplattedResource @Splatting).Invoke($option)
    }
}
