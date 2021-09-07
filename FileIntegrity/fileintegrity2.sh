#!/bin/bash

########################
rm -rf operator.txt
echo "Checking fileintegrity operator is deployed or not , if not it  will install fileintegrity operator.."
oc get deploy -nopenshift-file-integrity > operator.txt
if [ -s operator.txt ];
then
    echo "Fileintegrity operator is Installed!!!"
else
    # creating the CatalogSource and optionally verify it's been created successfuly
    echo "Creating the CatalogSource and optionally verify it's been created successfuly";
    oc create -f https://raw.githubusercontent.com/openshift/file-integrity-operator/master/deploy/olm-catalog/catalog-source.yaml && oc get catalogsource -nopenshift-marketplace

    echo " ";
    echo "Creating  openshift-file-integrity  namespace";
    sleep 2
    #  create the target namespace
    oc create -f https://raw.githubusercontent.com/openshift/file-integrity-operator/master/deploy/ns.yaml

    echo " ";
    echo "Creating  openshift-file-integrity operator-group";
    # time for creating the operator-group
    sleep 5
    # install the operator
    oc create -f https://raw.githubusercontent.com/openshift/file-integrity-operator/master/deploy/olm-catalog/operator-group.yaml

    echo " ";
    echo "Creating  openshift-file-integrity subcription";
    oc create -f https://raw.githubusercontent.com/openshift/file-integrity-operator/master/deploy/olm-catalog/subscription.yaml
    # time for creating the subscription
    sleep 3

    echo " ";
    echo "Wait to get sub-ip-csv";
    sleep 20
    oc get sub -nopenshift-file-integrity && oc get ip -nopenshift-file-integrity && oc get csv -nopenshift-file-integrity

    echo "Wait for operator to be installed.....";
    sleep 40
    # viewing pod list and deployment list of openshift-file-integrity namespace
    oc get pods -nopenshift-file-integrity && oc get deploy -nopenshift-file-integrity
    echo "Fileintegrity operator installed successfully"
fi

#remove the file examplefileintegrity.txt if exist
rm -rf examplefileintegrity.txt

echo "Checking fileintegrity object is installed or not , if not it  will install fileintegrity object.."
# viewing the fileintegrities of namespace openshift-file-integrity and save the output in a file called examplefileintegrity.txt
oc get fileintegrities -n openshift-file-integrity > examplefileintegrity.txt
# check if the file examplefileintegrity.txt is empty or not.. if it is empty then Fileintegrity object is not installed
if [ -s examplefileintegrity.txt ];
then
    echo "Fileintegrity object is Installed!!!";
else
    # file is empty .. so installing fileintegrity object
    echo "There is no such object  Installing fileIntegrity object...." && oc create -f https://raw.githubusercontent.com/sthitaprajnadas/openshift-works/main/FileIntegrity/fileintegrity.yaml
fi

echo "Waiting for Fileintegrity to be ready.....";
#time for installation of fileintegrity
sleep 120

echo "File integrity Installed successfuly";

echo " ";
echo "FileIntegrity CR status";
# viewing the fileintegrities installed in openshift-file-integrity namespace
oc get fileintegrities/example-fileintegrity  -o jsonpath="{ .status.phase }" --namespace=openshift-file-integrity
 
sleep 5
echo " ";

echo  "FileIntegrityNodeStatuses";
# viewing the fileintegrities and fileintegritynodestatuses installed in openshift-file-integrity namespace
oc get fileintegrities -n openshift-file-integrity && oc get fileintegritynodestatuses.fileintegrity.openshift.io --namespace=openshift-file-integrity -ojsonpath='{.items[*].results}' | jq

#rm -rf fileintegritynodes
#pe  "oc get fileintegritynodestatuses.fileintegrity.openshift.io $(oc get fileintegritynodestatuses --namespace=openshift-file-integrity | grep -v NAME | awk '{ print $1}') -ojsonpath='{.items[*].results}' | jq -r"
echo " ";
echo "FileIntegrityNodeStatus CR failed condition status";

# viewing the fileintegritynodestatuses installed in openshift-file-integrity namespace and saving the output in a file named nodes.json
oc get fileintegritynodestatuses.fileintegrity.openshift.io  --namespace=openshift-file-integrity -ojsonpath='{.items[*].results}' > nodes.json

# saving the failed fileintegrity node details in file "failed"
jq '.[].resultConfigMapName' nodes.json > failed

#  removing the quotes from failed fileintegrity node list
sed -i 's/\"//g'  failed

# checking for failed fileintegrity node list line by line
while IFS= read -r line; do
    if [ $line != 'null' ]
	then
        # describing the failed fileintegrity node
		 oc describe cm $line
	fi
done < failed

echo " ";
echo "Check events:  reason=FileIntegrityStatus";
# viewing the events for FileIntegrityStatus from namespace openshift-file-integrity 
oc get events --field-selector reason=FileIntegrityStatus --namespace=openshift-file-integrity 

echo " ";
echo "Check events:  reason=NodeIntegrityStatus ";

echo " ";
# viewing the events for NodeIntegrityStatus from namespace openshift-file-integrity 
oc get events --field-selector reason=NodeIntegrityStatus --namespace=openshift-file-integrity 

echo "FileIntegrity object attributes"
oc explain fileintegrity.spec --namespace=openshift-file-integrity && oc explain fileintegrity.spec.config --namespace=openshift-file-integrity

echo "default File Integrity Operator configuration"

oc describe cm/example-fileintegrity --namespace=openshift-file-integrity

echo "FileIntegrity custom resource "
oc annotate fileintegrities/example-fileintegrity file-integrity.openshift.io/re-init= -n openshift-file-integrity


echo "Checked successfully";
