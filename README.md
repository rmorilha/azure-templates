# Azure Templates #
- - - -

## Developed by Renan Morilha as a sample for basic users of ARM Templates (I am one too :D ) ##

This project creates:

* 1 Key Vault with secret
* 1 VNet
* 1 Subnet
* 1 Public IP Address
* 1 Load Balancer and its rules for http port 80/tcp
* 1 Virtual Machine Scale Set with 2 CentOS 7.5 VMs
* 1 Storage Account v2


##This project was created assuming a PHP/WEB application based on httpd/nginx webserver is about to run at the VMSS's Machines. ##


**PS's and Tips**

* IF put the storage template with network_app template or link the network template on the storage one, I could add storage network ACLs on it to limit the storage access only by the VMSS network (vnet) for a better security. In this case I've prefered to let it be accessible to all networks to let it be reusable as a template script like keyvault is already demonstrating.
* I've decided to put VMSS deploy with network to demonstrate the inner resources links.
* Kept an "app" folder with no use as a sample to use the template linking feature with a template URI and inline parameters considering that the linked template (network.json) have the "outputs" tag defined correctly.
* The Shell Script(deploy.sh) have a **-d** option that receives a boolean to enable/disable debug so you can see the commands outputs to debug with more details. For further investigations and a dry-run use 'az group deployment validate -g <resource_group_name> --template-file "<path_to_json_file>" --parameters "<path_to_parameter_json>"'
* To customize your preferences, edit the deploy.sh variables and the parameters.json around the folders.
* The LoadBalancer adds a NAT rule for port 22, using port 50000/tcp.