configuration DhcpServerOptionDefinitions
{
    param
    (
        [hashtable[]]
        $OptionDefinitions
    )

    <#
    AddressFamily = [string]{ IPv4 }
    Name = [string]
    OptionId = [UInt32]
    Type = [string]{ BinaryData | Byte | Dword | DwordDword | EncapsulatedData | IPv4Address | String | Word }
    VendorClass = [string]
    [DependsOn = [string[]]]
    [Description = [string]]
    [Ensure = [string]{ Absent | Present }]
    [Multivalued = [bool]]
    [PsDscRunAsCredential = [PSCredential]]
#>

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    # ensure Windows DHCP feature
    WindowsFeature AddDhcp
    {
        Name   = 'DHCP'
        Ensure = 'Present'
    }
    
    foreach ($definition in $OptionDefinitions)
    {
        # remove case sensitivity of ordered Dictionary or Hashtables
        $definition = @{ } + $definition

        # if 'VendorClass' not specified, set to Standard Class with empty string
        if ($null -eq $definition.VendorClass)
        {
            $definition.VendorClass = ''
        }
        
        # if not specified, ensure 'Present' 
        if (-not $definition.ContainsKey('Ensure'))
        {
            $definition.Ensure = 'Present'
        }

        # formulate execution name
        $executionName = "$($node.Name)_$($serverOption.OptionId)"

        # create DSC configuration for DHCP Server option definition
        xDhcpServerOptionDefinition "$executionName"
        {
            OptionId = $definition.OptionId
            VendorClass = $definition.VendorClass
            Name = $definition.Name
            Type = $definition.Type 
            MultiValued = $definition.MultiValued
            Description = $definition.Description
            AddressFamily = 'IPv4'
            Ensure = $definition.Ensure
            DependsOn = '[WindowsFeature]AddDhcp'
        }
    }
}
