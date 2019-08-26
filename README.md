## cumulus-ansible-beginner-bgp-nclu

### Summary:

  - Cumulus Linux 3.7.8
  - Underlying Topology Converter to 4.7.0
  - Tested against Vagrant 2.2.5 on Mac and Linux. Windows is not supported
  - Tested against Virtualbox 6.0.10 on Mac 10.14
  - Tested against Libvirt 1.3.1 and Ubuntu 16.04 LTS

### Description:

This is an Ansible demo which configures two Cumulus VX switches with BGP using the Ansible NCLU module.

### Network Diagram:

![Network Diagram](https://github.com/chronot1995/cumulus-ansible-beginner-bgp-nclu/blob/master/documentation/cumulus-ansible-beginner-bgp-nclu.png)

### Install and Setup Virtualbox on Mac

Setup Vagrant for the first time on Mojave, MacOS 10.14.6

1. Install Homebrew 2.1.9 (This will also install Xcode Command Line Tools)

    https://brew.sh

2. Install Virtualbox (Tested with 6.0.10)

    https://www.virtualbox.org

I had to go through the install process twice to load the proper security extensions (System Preferences > Security & Privacy > General Tab > "Allow" on bottom)

3. Install Vagrant (Tested with 2.2.5)

    https://www.vagrantup.com

### Install and Setup Linux / libvirt demo environment:

First, make sure that the following is currently running on your machine:

1. This demo was tested on a Ubuntu 16.04 VM w/ 4 processors and 32Gb of Diagram

2. Following the instructions at the following link:

    https://docs.cumulusnetworks.com/cumulus-vx/Development-Environments/Vagrant-and-Libvirt-with-KVM-or-QEMU/

3. Download the latest Vagrant, 2.2.5, from the following location:

    https://www.vagrantup.com/

### Initializing the demo environment:

1. Copy the Git repo to your local machine:

    ```git clone https://github.com/chronot1995/cumulus-ansible-beginner-bgp-nclu```

2. Change directories to the following

    ```cumulus-ansible-beginner-bgp-nclu```

3a. Run the following for Virtualbox:

    ```./start-vagrant-vbox-poc.sh```

3b. Run the following for Libvirt:

    ```./start-vagrant-libvirt-poc.sh```

### Running the Ansible Playbook

1a. SSH into the Virtualbox oob-mgmt-server:

    ```cd vx-vbox-simulation```   
    ```vagrant ssh oob-mgmt-server```

1a. SSH into the Libvirt oob-mgmt-server:

    ```cd vx-libvirt-simulation```   
    ```vagrant ssh oob-mgmt-server```

2. Copy the Git repo unto the oob-mgmt-server:

    ```git clone https://github.com/chronot1995/cumulus-ansible-beginner-bgp-nclu```

3. Change directories to the following

    ```cumulus-ansible-beginner-bgp-nclu/automation```

4. Run the following:

    ```./provision.sh```

This will bring run the automation script and configure the two switches with BGP.

### Troubleshooting

Helpful NCLU troubleshooting commands:

- net show route
- net show bgp summary
- net show interface | grep -i UP
- net show lldp

Helpful Linux troubleshooting commands:

- ip route
- ip link show
- ip address <interface>

The BGP Summary command will show if each switch had formed a neighbor relationship:

```
cumulus@switch01:mgmt-vrf:~$ net show bgp summary

show bgp ipv4 unicast summary
=============================
BGP router identifier 10.1.1.1, local AS number 65111 vrf-id 0
BGP table version 4
RIB entries 5, using 760 bytes of memory
Peers 2, using 39 KiB of memory

Neighbor        V         AS MsgRcvd MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd
switch02(swp1)  4      65222     118     118        0    0    0 00:05:38            2
switch02(swp2)  4      65222     117     117        0    0    0 00:05:35            2

Total number of neighbors 2

```

One should see that the corresponding loopback route is installed with two next hops / ECMP:

```
cumulus@switch01:mgmt-vrf:~$ net show route

show ip route
=============
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, P - PIM, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel,
       > - selected route, * - FIB route

K>* 0.0.0.0/0 [0/0] via 10.0.2.2, vagrant, 00:06:11
C>* 10.0.2.0/24 is directly connected, vagrant, 00:06:11
C>* 10.1.1.1/32 is directly connected, lo, 00:06:11
B>* 10.2.2.2/32 [20/0] via fe80::4638:39ff:fe00:2, swp1, 00:06:02
  *                    via fe80::4638:39ff:fe00:4, swp2, 00:06:02
```

### Errata

1. To shutdown the demo, run the following command from the vx-simulation directory:

    ```vagrant destroy -f```

2. This topology was configured using the Cumulus Topology Converter found at the following URL:

    https://github.com/CumulusNetworks/topology_converter

3. The following command was used to run the Topology Converter within the vx-simulation directory:

    ```./topology_converter.py cumulus-ansible-beginner-bgp-nclu.dot -c```

After the above command is executed, the following configuration changes are necessary:

4. Within ```vx-simulation/helper_scripts/auto_mgmt_network/OOB_Server_Config_auto_mgmt.sh```

The following stanza:

echo " ### Creating cumulus user ###"
useradd -m cumulus

Will be replaced with the following:

echo " ### Creating cumulus user ###"
useradd -m cumulus -m -s /bin/bash

The following stanza:

    #Install Automation Tools
    puppet=0
    ansible=1
    ansible_version=2.6.3

Will be replaced with the following:

    #Install Automation Tools
    puppet=0
    ansible=1
    ansible_version=2.8.4

Add the following ```echo``` right before the end of the file.

    echo " ### Adding .bash_profile to auto login as cumulus user"
    echo "sudo su - cumulus" >> /home/vagrant/.bash_profile
    echo "exit" >> /home/vagrant/.bash_profile
    echo "### Adding .ssh_config to avoid HostKeyChecking"
    printf "Host * \n\t StrictHostKeyChecking no\n" >> /home/cumulus/.ssh/config

    echo "############################################"
    echo "      DONE!"
    echo "############################################"
