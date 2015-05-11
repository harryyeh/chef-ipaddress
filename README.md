# DESCRIPTION

Chef's Cookbook to change an IP address on a node server and set it to static
based on attributes defined in a JSON file. This has been tested and verified
working on Ubuntu 12.04, and Centos 7. On Ubuntu, this recipe will edit
`/etc/network/interfaces`, and `/etc/sysconfig/network-scripts/ifcfg-<name>` on
Centos.

Direct Link to the project on Github:

http://github.com/harryyeh/chef-ipaddress

# REQUIREMENTS

## Platform:

The cookbook aims to be platform independent, but it's tested on Ubuntu 12.04, and CentOS 7.

# USAGE:

Add your cookbook to the chef server. Make sure you have the following data bag setup.

```shell
knife cookbook upload chef-ipaddress
```

You will need a databag in chef named "servers" the following is a sample data bag:

```json
{
    "id": "server1",
    "interfaces": {
        "eth0": {
            "address": "192.168.1.2",
            "netmask": "255.255.255.0",
            "gateway": "192.168.1.1",
            "dns-nameservers": "192.168.1.1 192.168.1.2",
            "dns-search": "test-domain.com"
        },
        "eth1": {
            "address": "192.168.2.2",
            "netmask": "255.255.255.0"
        }
    }
}
```

For a Centos server, you would want something like this:

```json
{
    "id": "server1",
    "interfaces": {
        "eth0": {
            "device": "eth0",
            "bootproto": "none",
            "onboot": "yes",
            "ipaddr": "192.168.1.2",
            "netmask": "255.255.255.0",
            "gateway": "192.168.1.1",
            "dns1": "192.168.1.1",
            "dns2": "192.168.1.3"
        },
        "eth1": {
            "device": "eth1",
            "bootproto": "none",
            "onboot": "yes",
            "ipaddr": "192.168.2.3",
            "netmask": "255.255.255.0",
            "gateway": "192.168.2.1",
            "dns1": "192.168.2.1",
            "dns2": "192.168.2.2"
        }
    }
}
```

Note - this recipe will not attempt to do any sort of error checking for you.
It will only copy what you have listed in your `data bag` to the relevant config files.

Assume you have a file called server1.json use the knife command to add this databag to chef before you add this to the run list. The json file name must match the name of the nodename in chef or this will not work. Or you have to set the attribute set_hostname below when you add it to the run list.

```shell
knife data bag from file servers server1.json
```

## Notes

By default, the cookbook will _not_ restart the networking service.
If you want Chef to restart your network service,
set `default['chef_ipaddress']['restart_networking']` to `true`.

# ATTRIBUTES

set_hostname - this parameter only needs to be set if you are doing a bootstrap
restart_networking - (default false) controls whether or not networking will be restarted

# LICENSE

chef-ipaddress - Changing the ip address on a linux system using chef.

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | Harry Yeh (<devops@cometcomputing.com>)
| **Author:**          | Tim Terhorst (<mynamewastaken+git@gmail.com>)
| **Copyright:**       | Copyright (c) 2008-2012 Comet Computing.
| **License:**         | Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
