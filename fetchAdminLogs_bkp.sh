#!/bin/sh
# usage - sh fetchadminlog.sh 2>&1 | tee  adminlogs$(date "+%y%m%d_%H%M%S").log 
rm -rf adminlogs*.log  # Remove all old logs.Clears the working dir.
for node in $(oc get nodes -o name);   # Iterating over each node in the cluster
do
    for logfile in $(oc adm node-logs ${node} --path=kube-apiserver | grep '.log')  # iterating over each log file in the node
    do
      OUTPUT="$(oc adm node-logs ${node} --path=kube-apiserver/${logfile} | jq  2>/dev/null)"  # added 2>/dev/null to ignore error
      if [ ! -z "${OUTPUT}" ]  # This to ignore the log files which dont have admin logs
      then
        echo "====================== Node : ${node} ======== File : ${logfile}=========================" 
        oc adm node-logs ${node} --path=kube-apiserver/${logfile} | jq 'select(.user.username == "admin")'
        #echo ${OUTPUT}    # yields same result as above but does not render the json properly
        echo "===================End Node : ${node} ======== File : ${logfile}=========================" 
      fi
    done
done
