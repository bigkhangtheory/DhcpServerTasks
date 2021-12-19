# DhcpServerOptionDefinitions

The **DhcpServerOptionDefinitions** DSC configuration manages definitions and types for DHCP lease options.

<br />

## Project Information

|                  |                                                                                                                        |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Source**       | https://github.com/bigkhangtheory/DhcpServerTasks/tree/master/DhcpServerTasks/DscResources/DhcpServerOptionDefinitions |
| **Dependencies** | [xDhcpServer][xDhcpServer], [xPSDesiredStateConfiguration][xPSDesiredStateConfiguration]                               |
| **Resources**    | [xDhcpServerOptionDefinition][xDhcpServerOptionDefinition], [[WindowsFeature][WindowsFeature]                          |

<br />

## Parameters

<br />

### Table. Attributes of `DhcpServerOptionDefinitions`

| Parameter             | Attribute  | DataType        | Description                                          | Allowed Values |
| :-------------------- | :--------- | :-------------- | :--------------------------------------------------- | :------------- |
| **OptionDefinitions** | *Required* | `[Hashtable[]]` | Specify a list of DHCP option definitions and types. |                |

---

<br />

### Table. Attributes of `OptionDefinitions`

| Parameter       | Attribute  | DataType    | Description                                                                                   | Allowed Values                                                                                   |
| :-------------- | :--------- | :---------- | :-------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------- |
| **OpionId**     | *Required* | `[UInt32]`  | DHCP option ID to define.                                                                     | `1` - `255`                                                                                      |
| **Name**        | *Required* | `[String]`  | Name of the DHCP option to define.                                                            |                                                                                                  |
| **Type**        | *Required* | `[String]`  | DHCP Option data type.                                                                        | `Byte`, `Word`, `Dword`, `DwordDword`, `IPv4Address`, `String`, `BinaryData`, `EncapsulatedData` |
| **Desription**  |            | `[String]`  | Description of the defined Option ID.                                                         |                                                                                                  |
| **MultiValued** |            | `[Boolean]` | Whether option is multivalued or not.                                                         |                                                                                                  |
| **Ensure**      |            | `[String]`  | Specify whether the DHCP service binding should be present or removed. Defaults to `Present`. | `Present`, `Absent`                                                                              |

---

<br />

## Example `DhcpServerOptionDefinitions`

```yaml
DhcpServerOptionDefinitions:
  OptionDefinitions:
    - OptionId: 60
      Name: PXEClientType
      Type: String
      Description: PXE Support
      MultiValued: false
```

<br />

## Lookup Options in Datum.yml

```yaml
lookup_options:

  DhcpServerOptionDefinitions:
    merge_hash: deep
  DhcpServerOptionDefinitions\OptionDefinitions:
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
