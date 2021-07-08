configuration DhcpScopeExclusions
{
    param
    (
        [Parameter(Mandatory)]
        [hashtable[]]
        $Scopes
    )

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    foreach ($s in $Scopes)
    {
        $executionName = "$($node.Name)_$($s.ScopeId -replace '[-().:\s]', '_')"

        $Splatting = @{
            ResourceName  = 'DhcpServerExclusionRange'
            ExecutionName = $executionName
            Properties    = $s
            NoInvoke      = $true
        }
        (Get-DscSplattedResource @Splatting).Invoke($s) 
    }
}