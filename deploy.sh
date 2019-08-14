#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

usage() { echo "Usage: $0 -i <subscriptionId> -l <location> -g <resourceGroupName> -D <deployName>" 1>&2; exit 1; }

# Variables
declare subscriptionId=""
declare resourceGroupName=""
declare deployName=""
declare location=""
declare debug=""

resourceGroupName="rmorilha-rg"
deployName="rmorilha-nl"
location="uksouth"
debug="false"

# Initialize parameters specified from command line
while getopts ":i:d:l:g:D:" arg; do
	case "${arg}" in
		i)
			subscriptionId=${OPTARG}
			;;
		d)
			debug="true"
			;;
		l)
			location=${OPTARG}
			;;
		g)
			resourceGroupName=${OPTARG}
			;;
		D)
			deployName=${OPTARG}
			;;
		esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [[ -z "$subscriptionId" ]]; then
	echo "Your subscription ID can be looked up with the CLI using: az account show --out json "
	echo "Enter your subscription ID:"
	read subscriptionId
	[[ "${subscriptionId:?}" ]]
fi
if [[ -z "$resourceGroupName" ]]; then
	echo "You need to designate a Resource Group Name. Even if you already have one "
	echo "Enter your Resource Group Name:"
	read resourceGroupName
	[[ "${resourceGroupName:?}" ]]
fi
if [[ -z "$deployName" ]]; then
	echo "You need to designate a Deploy Name. "
	echo "Enter your Deploy Name:"
	read deployName
	[[ "${deployName:?}" ]]
fi
if [[ -z "$location" ]]; then
	echo "You need to designate a location site. It can be looked up with the CLI using: az account list-locations"
	echo "Enter your location site:"
	read location
	[[ "${location:?}" ]]
fi

#templateFile Path - template file to be used
rgFilePath=ResourceGroup
folders=(keyvault network_app storage)


if [ -z "$subscriptionId" ] || [ -z "$resourceGroupName" ] || [ -z "$deployName" ] || [ -z "$location" ]; then
	echo "Either one of subscriptionId, resourceGroupName, deployName or location is empty"
	usage
fi

#login to azure using your credentials
if [ $debug == "true" ];
then
	set -x
	az account show
else
	set +x
	az account show 1> /dev/null
fi

if [ $? != 0 ];
then
	az login
fi

#set the default subscription id
az account set --subscription $subscriptionId

set +e

#Check for existing RG
az group show --name $resourceGroupName 1> /dev/null

if [ $? != 0 ]; then
	echo "Resource group with name" $resourceGroupName "could not be found. Creating new resource group.."
	set -e
	(
		if [ $debug == "true" ];
		then
			set -x
		else
			set +x
		fi
		az deployment create --name $deployName --location $location --template-file "$PWD/$rgFilePath/deploy.json" --parameters "$PWD/${rgFilePath}/parameters.json" 1> /dev/null
	)
	else
	echo "Using existing resource group..."
fi
if [ $? != 0 ];
then
	echo "Resource Group Failed !"
	exit 1
fi;

for f in ${folders[@]}; do
	#Start deployment
	echo "Starting $f deployment..."
	(
		if [ $debug == "true" ];
		then
			set -x
		else
			set +x
		fi

		az group deployment create --name $deployName --resource-group "$resourceGroupName" --template-file "$PWD/${f}/deploy.json" --parameters "$PWD/${f}/parameters.json" 1> /dev/null
	)
	if [ $?  == 0 ];
	then
		echo "Template $f has been successfully deployed"
	fi;
done

## TODO: Put all parameters.json files together ? (Got less duplicated code but mess with modularity)
## TODO: Export Templates on a public URL to link templates and improve reusability?
## TODO: IF put the storage template with network_app template or link the network template on the storage one, I could add storage network ACLs on it to limit the storage access only by the VMSS network (vnet) for a better security. In this case I've prefered to let it be accessible to all networks to let it be reusable as a template script like keyvault is already demonstrating.
## TODO: Was decided to put VMSS deploy with network to demonstrate the inner resources links.
## TODO: Kept an "app" folder with no use as a sample to use the template linking feature with a template URI and inline parameters considering that the linked template have the "outputs" tag defined correctly.
## TODO: This Shell Script have a -d option to enable debug so you can see the commands outputs to debug with more details. For further investigations and a dry-run use 'az group deployment validate -g <resource_group_name> --template-file "<path_to_json_file>" --parameters "<path_to_parameter_json>"'

if [ $?  == 0 ];
 then
	echo "All templates has been successfully deployed"
fi