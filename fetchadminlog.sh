#!/bin/sh
# usage:  sh fetchadminlog.sh | tee -a adminlogs$(date "+%y%m%d_%H%M%S").log >/dev/null

rm -rf adminlogs*.log  # Remove all old logs.Clears the working dir.
for node in $(oc get nodes -o name);   # Iterating over each node in the cluster
do
    oc adm node-logs ${node} --path=kube-apiserver >/dev/null 2>&1    #Aug 17: To first check if node is accessible.
    if [ $? -eq 0 ]; then  #Aug 17: Check if previous command gave no error (i.e. node is accessible).If it is then for those process logfiles


      for logfile in $(oc adm node-logs ${node} --path=kube-apiserver | grep '.log')  # iterating over each log file in the node
      do
        OUTPUT="$(oc adm node-logs ${node} --path=kube-apiserver/${logfile} | jq 'select(.user.username == "admin")'  2>/dev/null)"  # added 2>/dev/null to ignore error

        if [ ! -z "${OUTPUT}" ]  # This to ignore the log files which dont have admin logs
        then
          echo "====================== Node : ${node} ======== File : ${logfile}=========================" 
          oc adm node-logs ${node} --path=kube-apiserver/${logfile} | jq 'select(.user.username == "admin")'
          #echo ${OUTPUT}    # yields same result as above but does not render the json properly
          echo "===================End Node : ${node} ======== File : ${logfile}=========================" 
        fi
      done
    else    # Aug 17: If node is inaccessible , then print it and move to next node
      echo "======================Node : ${node} is not accessible=========================" 
    fi
done
