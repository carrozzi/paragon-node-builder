# paragon-node-builder
   The paragon node OVA is built using Hashicorp Packer with the VMware ISO builder.  I used vmware Fusion in the build process but it should work in Workstation without changes and ESXi with some modification.  
   I went with a desktop product as I found it easier to compact the image size down after building.
   This image can be used both to install Paragon Automation as well as run as a Paragon node. If deploying as an installer, you can reduce the resources used after the fact(default is 32G RAM and 12 CPU cores). All prerequisite packages that are needed for offline installation are installed.

   ## Prerequisites
   * Hashicorp [Packer](https://www.packer.io)
   * VMWare Fusion or Workstation(or possibly Player as well as long as you have the VIX API)
   * VMWare OVFtool

## Instructions
1) If you are using this image as an installer, download Paragon Automation 22.1 and copy into the files directory.
2) Any files that you put in the files directory will be copied into /tmp of the resulting image.
3) Make sure ovftool is in your path. It wasn't by default on my Mac.
4) Run ```packer build template.json```. This will take some time.
5) You will find the OVA file in the output-pa-node-centos7 directory.

## Additional Info
* This builder creates a second blank disk for CEPH to use. I am working on a single disk builder.
* esxitemplate.json connects to an ESXI server to build the VM
* vboxtemplate.json also builds an OVA but using Virtualbox instead of VMware, but hasn't been tested yet
* qemutemplate.json builds a qcow2 file for use with KVM/EVE-NG/GNS3/etc

## Usage
* In addition to root, there is also a paragon user, and both passwords are set to Paragon1(although it is pretty easy to change)
* If using as an installer, you don't need to know much else. Docker is installed, and the installer should run just fine.
* In general, though, if you are doing this without Internet access(offline), there are a couple things to be aware of:
    1) The VMs have to have a default route set. Ansible determines the primary network interface by looking for the default route.
    2) There has to be a NTP server on the network.  The installation will fail if the VM is not showing NTP sync.
    3) For Docker and containerd, the builder installs the current version at build time. As this is not the version the installer is expecting, you need to tell the installer what version you have.  The file /tmp/config.txt is created during build with the proper settings. When going through the install process, after you have done ```run -c ... conf``` or edited the config.yml directly, but before deploying to the cluster, add the two lines in config.txt to the end of your config.yml.
    4) When deploying, make sure to add -e offline_mode=true to the end of the command(mentioned in the documentation for RHEL 8.4 offline install)
