# APP FOLDER #
- - - -

This is a sample for who wants to link templates.

**MICROSOFT NEEDS THE TEMPLATES PUBLISHED AT A PUBLIC HTTP/HTTPS URL. THIS IS A MUST !!!!**

Basically I use a VMSS template linking a network/loadbalancer that expose 3 resource id's and use it on VMSS template.

* **network.json** - Holds the creation of a VNet, subnet a LoadBalancer with Backend and FrontEnd Pools and a NAT pool for a inbound nat rules either.
* **deploy.json** - Holds the creation of a VMSS that uses the resource id's from the linked network template.
* **parameters.json** - Holds the VMSS parameters values. I've ommited the "parameters.json" for network.json file, presuming that you already have one created.