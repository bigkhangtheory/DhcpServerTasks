# DhcpServer

The **DhcpServer** DSC configuration is used for the deployment and configuration of Microsoft DHCP server, with scopes, options, and reservations.

<br />

## Project Information

|                  |                                                                                                                                                                                                                                                                                                      |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Source**       | https://github.com/bigkhangtheory/DhcpServerTasks/tree/master/DhcpServerTasks/DscResources/DhcpServerDhcpServer                                                                                                                                                                                      |
| **Dependencies** | [xDhcpServer][xDhcpServer], [xPSDesiredStateConfiguration][xPSDesiredStateConfiguration], [Indented.Net.IP][Indented.Net.IP]                                                                                                                                                                         |
| **Resources**    | [xDhcpServerScope][xDhcpServerScope], [DhcpServerExclusionRange][DhcpServerExclusionRange], [DhcpScopeOptionValue][DhcpScopeOptionValue], [xDhcpServerReservation][xDhcpServerReservation], [xDhcpServerAuthorization][xDhcpServerAuthorization], [Script][Script], [WindowsFeature][WindowsFeature] |

<br />

## Parameters

<br />

### Table. Attributes of `DhcpServer`

| Parameter                | Attribute | DataType         | Description                                                                     | Allowed Values |
| :----------------------- | :-------- | :--------------- | :------------------------------------------------------------------------------ | :------------- |
| **Authorization**        |           | `[Boolean]`      | Specify whether to authorize the DHCP server to serve Active Directory clients. |                |
| **EnableSecurityGroups** |           | `[Boolean]`      | Specify whether to create local DHCP security groups on the DHCP server.        |                |
| **Scopes**               |           | `[Hashtable[]]`  | Specifies a list of DHCP scopes to assign leases to cliens of the DHCP server.  |                |
| **DomainCredential**     |           | `[PSCredential]` | Specify a credential to use for DHCP server authorization.                      |                |

---

<br />

#### Table. Attributes of `Scope`

| Parameter             | Attribute  | DataType      | Description                                                                                                                                                           | Allowed Values       |
| :-------------------- | :--------- | :------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------- |
| **Name**              | *Required* | `[String]`    | Name of this DHCP Scope                                                                                                                                               |                      |
| **Subnet**            | *Required* | `[String]`    | Specify the subnet range for this DHCP scope in CIDR notation. This configuration will populate the required scope starting and ending addresses based on the subnet. |                      |
| **LeaseDuration**     |            | `[String]`    | Time interval for which an IP address should be leased, specified as the format: `Days:Hours:Minutes:Seconds`. Defaults to `08.00:00:00`.                             |                      |
| **State**             |            | `[String]`    | Specifies whether scope should be active or inactive. Defaults to `Active`.                                                                                           | `Active`, `Inactive` |
| **DnsNameProtection** |            | `[Boolean]`   | Specifies the enabled state for the DNS name protection on the DHCP scope. For more information see [DHCP DNS Name Protection](###dhcp-scope-dns-name-protection)     |                      |
| **Ensure**            |            | `[String]`    | Specify whether DHCP scope should be present or removed. Defaults to `Present`.                                                                                       | `Present`, `Absent`  |
| **ExlusionRanges**    |            | `[Hashtable]` | Specifies a list of DHCP scope exclusion ranges.                                                                                                                      |                      |
| **OptionValues**      |            | `[Hashtable]` | Specifies a list of DHCP option values at the scope level.                                                                                                            |                      |
| **Reservations**      |            | `[Hashtable]` | Specifies a list of DHCP lease assignments set for reserves DHCP clients.                                                                                             |                      |

---

<br />

##### Table. Attributes of `ExclusionRanges`

| Parameter        | Attribute | DataType   | Description                                                                               | Allowed Values      |
| :--------------- | :-------- | :--------- | :---------------------------------------------------------------------------------------- | :------------------ |
| **IPStartRange** |           | `[String]` | Starting IP address of the exclusion range.                                               |                     |
| **IPEndRange**   |           | `[String]` | Ending IP address of the exclusion range.                                                 |                     |
| **Ensure**       |           | `[String]` | Specify whether the DHCP exclusion range should be set or removed. Defaults to `Present`. | `Present`, `Absent` |

---

<br />

##### Table. Attributes of `OptionValues`

| Parameter   | Attribute | DataType     | Description                                                                  | Allowed Values      |
| :---------- | :-------- | :----------- | :--------------------------------------------------------------------------- | :------------------ |
| **OpionId** |           | `[UInt32]`   | DHCP option ID.                                                              | `1` - `255`         |
| **Value**   |           | `[String[]]` | DHCP option value.                                                           |                     |
| **Ensure**  |           | `[String]`   | Specify whether DHCP option should be set or removed. Defaults to `Present`. | `Present`, `Absent` |

---

<br />

##### Table. Attributes of `Reservations`

| Parameter     | Attribute | DataType   | Description                                                                  | Allowed Values      |
| :------------ | :-------- | :--------- | :--------------------------------------------------------------------------- | :------------------ |
| **Name**      |           | `[String]` | DHCP reservation name.                                                       |                     |
| **IPAddress** |           | `[String]` | IP address of the DHCP reservation assigned to the client.                   |                     |
| **ClientId**  |           | `[String]` | DHCP client MAC address to assign the reservation                            |                     |
| **Ensure**    |           | `[String]` | Specify whether DHCP option should be set or removed. Defaults to `Present`. | `Present`, `Absent` |

### DHCP Scope DNS Name Protection

The DHCP Server will register A/AAAA and PTR records on behalf of a DHCP client, however if there is a different client already registered with this name, the DHCP update will fail.

- Name Protection can be enabled for both DHCPv4 and DHCPv6 servers.
- When set to `true`, if there is an existing DNS record matching the name, the DNS update for the client fails instead of being overwritten.

<br />

## Example `DhcpServer`

```yaml
DhcpServer:
  Authorization: true
  EnableSecurityGroups: true
  Scopes:
    - Name:               1011-SUBNET
      Subnet:             10.101.1.0/24
      LeaseDuration:      08.00:00:00
      State:              Active
      DnsNameProtection:  true
      ExclusionRanges:
        - IPStartRange: 10.101.1.1
          IPEndRange:   10.101.1.50

        - IPStartRange: 10.101.1.51
          IPEndRange:   10.101.1.100

        - IPStartRange: 10.101.1.200
          IPEndRange:   10.101.1.254
      OptionValues:
        - OptionId: 3 # default gateway
          Value:    10.101.1.1

        - OptionId: 6 # DNS servers
          Value:
            - 10.101.1.252
            - 10.101.1.251
      Reservations:
        - Name:       server1.example.com
          IPAddress:  10.101.1.100
          ClientId:   0050568D14D8

        - Name:       server2.example.com
          IPAddress:  10.101.1.12
          ClientId:   0050568D7CE4

        - Name:       server3.example.com
          IPAddress:  10.101.1.57
          ClientId:   0050568DFC81
      #end ScopeId 10.101.1.0

    # -------------------------------------------------------------------------
    # This DHCP Scope ID is defined for VLAN 1701.
    # -------------------------------------------------------------------------
    - Name:           1701-SUBNET
      Subnet:         10.170.1.0/24
      LeaseDuration:  08.00:00:00
      ExclusionRanges:
        - IPStartRange: 10.170.1.1
          IPEndRange:   10.170.1.9

        - IPStartRange: 10.170.1.240
          IPEndRange:   10.170.1.249
      OptionValues:
        - OptionId: 3 # default gateway
          Value:    10.170.1.1
      Reservations:
        - Name:       server5.example.com
          IPAddress:  10.170.1.59
          ClientId:   005056be8693
      #end ScopeId 10.170.1.0
  DomainCredential: '[ENC=PE9ianMgVmVyc2lvbj0iMS4xLjAuMSIgeG1sbnM9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vcG93ZXJzaGVsbC8yMDA0LzA0Ij4NCiAgPE9iaiBSZWZJZD0iMCI+DQogICAgPFROIFJlZklkPSIwIj4NCiAgICAgIDxUPlN5c3RlbS5NYW5hZ2VtZW50LkF1dG9tYXRpb24uUFNDdXN0b21PYmplY3Q8L1Q+DQogICAgICA8VD5TeXN0ZW0uT2JqZWN0PC9UPg0KICAgIDwvVE4+DQogICAgPE1TPg0KICAgICAgPE9iaiBOPSJLZXlEYXRhIiBSZWZJZD0iMSI+DQogICAgICAgIDxUTiBSZWZJZD0iMSI+DQogICAgICAgICAgPFQ+U3lzdGVtLk9iamVjdFtdPC9UPg0KICAgICAgICAgIDxUPlN5c3RlbS5BcnJheTwvVD4NCiAgICAgICAgICA8VD5TeXN0ZW0uT2JqZWN0PC9UPg0KICAgICAgICA8L1ROPg0KICAgICAgICA8TFNUPg0KICAgICAgICAgIDxPYmogUmVmSWQ9IjIiPg0KICAgICAgICAgICAgPFROUmVmIFJlZklkPSIwIiAvPg0KICAgICAgICAgICAgPE1TPg0KICAgICAgICAgICAgICA8UyBOPSJIYXNoIj44MDg1MzBFQzZDOUMyNENEODIzMjEyMkNBNDAwQUQyQjA4RUYwQTA0QjlGQzM2NUQxOUY1NTY3MjdEQjNDOUJEPC9TPg0KICAgICAgICAgICAgICA8STMyIE49Ikl0ZXJhdGlvbkNvdW50Ij41MDAwMDwvSTMyPg0KICAgICAgICAgICAgICA8QkEgTj0iS2V5Ij5leUt6OUNtWjhFRUoyVmlqR1dhYVVodW9IcEtCeEd6SmZza3F1L3JicWxXZzVoVXkwYWd5QW1xZnI5WWExbDAxPC9CQT4NCiAgICAgICAgICAgICAgPEJBIE49Ikhhc2hTYWx0Ij5nQ3NLTldCTUdRMjF0Smc1QVA1UXcyRGdoWDZpTkx2cy8vZHFQbE5PNExnPTwvQkE+DQogICAgICAgICAgICAgIDxCQSBOPSJTYWx0Ij54OVhLaTVPRVg3SXRsbnQySkRPY0tJdlNZLzN1V2dOQjBjWFpaSitpWjZBPTwvQkE+DQogICAgICAgICAgICAgIDxCQSBOPSJJViI+NUVpcFhyeVBSeDA3dDI2dk1mNGlPR0dURldiT2tzVDdraHRxcjNiM1NsND08L0JBPg0KICAgICAgICAgICAgPC9NUz4NCiAgICAgICAgICA8L09iaj4NCiAgICAgICAgPC9MU1Q+DQogICAgICA8L09iaj4NCiAgICAgIDxCQSBOPSJDaXBoZXJUZXh0Ij54OUp0WXZDbXFKQmpaVitqNmQxK3VUazBEM0FiZ3cvMTRJbk5EMEN2ZXZCVTlkUG5tL091WFR4bWdGVVQzaUlMdGYzRnNxQ0VVc29wYkhSaHBPdjE5dz09PC9CQT4NCiAgICAgIDxCQSBOPSJITUFDIj5pR3FoYkYwR0w5NUF6bDFSTVhMa0twQ2VNRXcwa29QeGtJd1NzMVczWU9vPTwvQkE+DQogICAgICA8UyBOPSJUeXBlIj5TeXN0ZW0uTWFuYWdlbWVudC5BdXRvbWF0aW9uLlBTQ3JlZGVudGlhbDwvUz4NCiAgICA8L01TPg0KICA8L09iaj4NCjwvT2Jqcz4=]'
```

<br />

## Lookup Options in Datum.yml

```yaml
lookup_options:

  DhcpServer:
    merge_hash: deep
  DhcpServer\Scopes:
    merge_hash_array: UniqueKeyValTuples
    merge_options:
      tuple_keys:
        - Subnet
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
