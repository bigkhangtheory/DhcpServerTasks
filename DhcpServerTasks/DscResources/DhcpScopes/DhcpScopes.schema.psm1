configuration DhcpScopes
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
        if (-not $s.ContainsKey('Ensure'))
        {
            $s.Ensure = 'Present'
        }

        $executionName = "$($node.Name)_$($s.ScopeId -replace '[-().:\s]', '_')"

        $Splatting = @{
            ResourceName  = 'xDhcpServerScope'
            ExecutionName = $executionName
            Properties    = $s
            NoInvoke      = $true
        }
        (Get-DscSplattedResource @Splatting).Invoke($s)
    }
}
