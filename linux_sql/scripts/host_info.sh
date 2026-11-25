psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# save specs as variables
lscpu_out=`lscpu`
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | grep "^Model name:" | cut -d: -f2 | xargs)
cpu_mhz=$(echo "$lscpu_out" | grep "^Model name:" | cut -d@ -f2 | xargs | awk '{print $1 * 1000}')
l2_cache=$(echo "$lscpu_out" | grep "^L2 cache:" | awk '{print $3}')
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}') # in kB
timestamp=$(date "+%Y-%m-%d %H:%M:%S") # current timestamp in `2019-11-26 14:40:19` format; use `date` cmd

#construct the INSERT statement from specification variables
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem) VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

# execute the sql command
export PGPASSWORD="$psql_password"
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
