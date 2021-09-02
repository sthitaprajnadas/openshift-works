#!/bin/bash

########################
echo "FileIntegrity CR status";
#oc get fileintegrities $(oc get fileintegrities --namespace=openshift-file-integrity | grep -v NAME | awk '{ print $1}') -o jsonpath="{ .status.phase }'
oc get fileintegrities/worker-fileintegrity  -o jsonpath="{ .status.phase }" --namespace=openshift-file-integrity

   
sleep 1

echo  "FileIntegrityNodeStatuses";

#rm -rf fileintegritynodes
#pe  "oc get fileintegritynodestatuses.fileintegrity.openshift.io $(oc get fileintegritynodestatuses --namespace=openshift-file-integrity | grep -v NAME | awk '{ print $1}') -ojsonpath='{.items[*].results}' | jq -r"

echo "FileIntegrityNodeStatus CR failed condition status";

oc get fileintegritynodestatuses.fileintegrity.openshift.io  --namespace=openshift-file-integrity -ojsonpath='{.items[*].results}' > nodes.json
jq '.[].resultConfigMapName' nodes.json > failed
sed -i 's/\"//g'  failed
while IFS= read -r line; do
    if [ $line != 'null' ]
	then
		 oc describe cm $line
	fi
done < failed

echo "check events";
oc get events --field-selector reason=NodeIntegrityStatus --namespace=openshift-file-integrity
echo "checked successfully";