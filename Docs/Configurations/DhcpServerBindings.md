# DhcpServerBindings

The **DhcpServerBindings** DSC configuration manages network bindings on the server level.

<br />

## Project Information

|                  |                                                                                                               |
| ---------------- | ------------------------------------------------------------------------------------------------------------- |
| **Source**       | https://github.com/bigkhangtheory/DhcpServerTasks/tree/master/DhcpServerTasks/DscResources/DhcpServerBindings |
| **Dependencies** | [xDhcpServer][xDhcpServer], [xPSDesiredStateConfiguration][xPSDesiredStateConfiguration]                      |
| **Resources**    | [DhcpServerBinding][DhcpServerBinding], [WindowsFeature][WindowsFeature]                                      |

<br />

## Parameters

<br />

### Table. Attributes of `DhcpServerBindings`

| Parameter       | Attribute  | DataType        | Description                                                     | Allowed Values |
| :-------------- | :--------- | :-------------- | :-------------------------------------------------------------- | :------------- |
| **NetAdapters** | *Required* | `[Hashtable[]]` | Specifies a list of network adapters to serve DHCP leases from. |                |

---

<br />

### Table. Attributes of `NetAdapters`

| Parameter          | Attribute  | DataType   | Description                                                                                   | Allowed Values      |
| :----------------- | :--------- | :--------- | :-------------------------------------------------------------------------------------------- | :------------------ |
| **InterfaceAlias** | *Required* | `[String]` | Specifies the alias name for the network interface to manage.                                 |                     |
| **Ensure**         |            | `[String]` | Specify whether the DHCP service binding should be present or removed. Defaults to `Present`. | `Present`, `Absent` |

---

<br />

## Example `DhcpServerBindings`

```yaml
DhcpServerBindings:
NetAdapters:
   - InterfaceAlias: Ethernet0
     Ensure: Present

   - InterfaceAlias: Ethernet1
     Ensure: Present

```

<br />

## Lookup Options in Datum.yml

```yaml
lookup_options:

  DhcpServerBindings:
    merge_hash: deep

```

<br />

[Indented.Net.IP]: https://github.com/indented-automation/Indented.Net.IP
[xDhcpServer]: https://github.com/dsccommunity/xDhcpServer
[xPSDesiredStateConfiguration]: https://github.com/dsccommunity/xPSDesiredStateConfiguration
[DhcpScopeOptionValue]: https://github.com/dsccommunity/xDhcpServer
[xDhcpServerAuthorization]: https://github.com/dsccommunity/xDhcpServer
[DhcpServerBinding]: https://github.com/dsccommunity/xDhcpServer
[DhcpServerExclusionRange]: https://github.com/dsccommunity/xDhcpServer
[xDhcpServerOptionDefinition]: https://github.com/dsccommunity/xDhcpServer
[DhcpServerOptionValue]: https://github.com/dsccommunity/xDhcpServer
[xDhcpServerReservation]: https://github.com/dsccommunity/xDhcpServer
[xDhcpServerScope]: https://github.com/dsccommunity/xDhcpServer
[Script]: https://github.com/dsccommunity/xPSDesiredStateConfiguration
[WindowsFeature]: https://github.com/dsccommunity/xPSDesiredStateConfiguration
