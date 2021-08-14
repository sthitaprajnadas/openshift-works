# Get all Audit logs for Admin user  
sh fetchAdminlog.sh 2>&1 | tee  adminlogs$(date "+%y%m%d_%H%M%S").log >> /dev/null  


