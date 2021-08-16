#!/bin/sh
for node in $(oc get nodes -o name);   # Iterating over each node in the cluster
do
	echo "====================== Node : ${node} ========"
	oc adm node-logs ${node} --path=kube-apiserver/

done
