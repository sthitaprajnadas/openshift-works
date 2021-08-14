# Get all Audit logs for Admin user  
sh fetchAdminlog.sh 2>&1 | tee  adminlogs$(date "+%y%m%d_%H%M%S").log >> /dev/null  

This just outputs the admin logs in below JSON format.
```
{
  "kind": "Event",  
  "apiVersion": "audit.k8s.io/v1",
  "level": "Metadata",
  "auditID": "eba53191-a0b3-4234-96a6-c8d8a5284de1",
  "stage": "ResponseComplete",
  __"requestURI": "/api/v1/nodes/crc-pkjt4-master-0/proxy/logs/kube-apiserver/audit-2021-08-14T07-53-24.208.log",
  "verb": "get",__
  "user": {
    "username": "admin",
    "uid": "f5381d86-0e64-419b-81fc-90be5df24a70",
    "groups": [
      "system:authenticated:oauth",
      "system:authenticated"
    ],
    "extra": {
      "scopes.authorization.openshift.io": [
        "user:full"
      ]
    }
  },
  "sourceIPs": [
    "172.17.0.40"
  ],
  "userAgent": "oc/4.7.0 (linux/amd64) kubernetes/95881af",
  "objectRef": {
    "resource": "nodes",
    "name": "crc-pkjt4-master-0",
    "apiVersion": "v1",
    "subresource": "proxy"
  },
  __"responseStatus": {
    "metadata": {},
    "code": 200
  },__
  "requestReceivedTimestamp": "2021-08-14T07:54:50.505138Z",
  "stageTimestamp": "2021-08-14T07:54:52.409419Z",
  "annotations": {
    "authorization.k8s.io/decision": "allow",
    "authorization.k8s.io/reason": "RBAC: allowed by ClusterRoleBinding \"cluster-admin-0\" of ClusterRole \"cluster-admin\" to User \"admin\""
  }
}
```



