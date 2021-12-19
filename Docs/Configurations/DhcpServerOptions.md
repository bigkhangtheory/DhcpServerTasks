# DhcpServerOptions

The **DhpServerOptions** DSC configuration manages an option value on server level.

<br />

## Project Information

|                  |                                                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------------------ |
| **Source**       | https://github.com/bigkhangtheory/DhcpServerTasks/tree/master/DhcpServerTasks/DscResources/DhcpServerOptions |
| **Dependencies** | [xDhcpServer][xDhcpServer], [xPSDesiredStateConfiguration][xPSDesiredStateConfiguration]                     |
| **Resources**    | [DhcpServerOptionValue][DhcpServerOptionValue], [[xWindowsFeature][xWindowsFeature]                          |

<br />

## Parameters

<br />

### Table. Attributes of `DhcpServerOptions`

| Parameter   | Attribute | DataType      | Description                                                | Allowed Values |
| :---------- | :-------- | :------------ | :--------------------------------------------------------- | :------------- |
| **Options** |           | `[Hashtable]` | Specifies a list of DHCP option values at the scope level. |                |

---

<br />

##### Table. Attributes of `Options`

| Parameter   | Attribute  | DataType     | Description                                                                  | Allowed Values      |
| :---------- | :--------- | :----------- | :--------------------------------------------------------------------------- | :------------------ |
| **OpionId** | *Required* | `[UInt32]`   | DHCP option ID.                                                              | `1` - `255`         |
| **Value**   | *Required* | `[String[]]` | DHCP option value.                                                           |                     |
| **Ensure**  |            | `[String]`   | Specify whether DHCP option should be set or removed. Defaults to `Present`. | `Present`, `Absent` |

---

<br />

## Example `DhcpServerOptions`

```yaml
DhcpServerOptions:
  Options:
    - OptionId: 6
      Value:
        - 172.16.2.1
        - 172.16.1.74

    - OptionId: 15
      Value: example.com
```

<br />

## Lookup Options in Datum.yml

```yaml
lookup_options:

  DhcpServerOptions:
    merge_hash: deep
  DhcpServerOptions\Options:
    merge_hash_array: UniqueKeyValTuples
    merge_options:
      tuple_keys:
        - OptionId
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