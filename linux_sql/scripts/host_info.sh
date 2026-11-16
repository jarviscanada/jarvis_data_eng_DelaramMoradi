# save specs as variables
lscpu_out=`lscpu`
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | grep "^Model name:" | cut -d: -f2 | xargs)
cpu_mhz=$(echo "$lscpu_out" | grep "^Model name:" | cut -d@ -f2 | xargs | awk '{print $1 * 1000}')
l2_cache=$(echo "$lscpu_out" | grep "^L2 cache:" | awk '{print $3}')
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(date "+%Y-%m-%d %H:%M:%S") # current timestamp in `2019-11-26 14:40:19` format; use `date` cmd

#construct the INSERT statement from specification variables
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem) VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

# execute the sql command
export PGPASSWORD='password'
psql -h localhost -p 5432 -U postgres -d host_agent -c "$insert_stmt"