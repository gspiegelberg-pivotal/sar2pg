#!/bin/bash
#
# Load into sar PostgreSQL database
#
# Works for 
# * RHEL/CentOS 6 sysstat 9.0.x
# * RHEL/CentOS 7 sysstat 10.x

. parse_config.sh

usage() {
	cat << EOMSG
usage: sar_parse -g GROUP -f SAR_REPORT
	-f SAR_REPORT          sar report from /var/log/sa
	-g GROUP_NAME          name of group to create/use
EOMSG
	exit $1
}

options="f:g:"

sar_report=""
group_name=""

while getopts $options opt
do
	case "$opt" in
	f)
		sar_report="$OPTARG"
		;;
	g)
		group_name="$OPTARG"
		;;
	*)
		echo "unrecognized flag $opt"
		usage 1
		;;
	esac
done

if [ -z "$sar_report" ]; then
	echo "-f SAR_REPORT required"
	usage 1
fi

if [ -z "$group_name" ]; then
	echo "-g GROUP_NAME required"
	usage 1
fi


PSQL="/usr/bin/psql -qAt -d $dbname -p $dbport -U $dbuser -h $dbhost"

tmpfile=`mktemp`
chmod a+r $tmpfile

#hosts
headline=`head -1 "$sar_report"`
kernel=$( echo $headline | awk '{print $2}' )
host=$( echo $headline | awk -F'[()]' '{print $2}'  )
sar_date=$( echo $headline | awk '{print $4}' )

group_id=$( $PSQL -c "SELECT id FROM groups WHERE name='${group_name}'" )
if [[ -z "$group_id" ]]; then
	echo "creating group ${group_name}..."
	group_id=$( $PSQL -c "INSERT INTO groups (name) VALUES ('${group_name}') RETURNING id;" )
fi

host_id=$( $PSQL -c "SELECT h.id FROM hosts h JOIN group_host gh ON (h.id=gh.host_id) WHERE h.name='${host}' AND gh.group_id = ${group_id}" )

if [[ -z "$host_id" ]]; then
	echo "creating host ${host}..."
	host_id=$( $PSQL -c "INSERT INTO hosts (name,kernel) VALUES ('${host}','${kernel}') RETURNING id;" )

	echo "adding host ${host} to group ${group_name}..."
	$PSQL -c "INSERT INTO group_host (group_id,host_id) VALUES ( ${group_id}, ${host_id} );"
fi


# Check if file has been loaded
is_file_loaded=$( $PSQL -c "SELECT count(*) FROM file_tracking WHERE host_id=${host_id} AND sar_date='${sar_date}';" )
if [ $is_file_loaded -eq 1 ]; then
	printf "sar data for host %s on date %s already present, exiting\n" "$host" "$sar_date"
	exit 0
fi



declare -A sar_segs

# [TABLE]="regex of first line in section"
sar_segs=( 
	[cpu]="12:00:01 AM     CPU      \%us"
	[procs]="12:00:01 AM    proc\/s   cswc"
	[swap]="12:00:01 AM  pswpin\/s pswpou"
	[pages]="12:00:01 AM  pgpgin\/s pgpgou"
	[disk_io]="12:00:01 AM       tps      r"
	[memory_stats]="12:00:01 AM   frmpg\/s   bufp"
	[memory_usage]="12:00:01 AM kbmemfree kbmemu"
	[memory_swapped]="12:00:01 AM kbswpfree kbswpu"
	[hugepages]="12:00:01 AM kbhugfree kbhugu"
	[file_inode]="12:00:01 AM dentunusd   file"
	[loadavg]="12:00:01 AM   runq-sz  plist"
	[disk_stats]="12:00:01 AM       DEV       tps"
	[network_stats]="12:00:01 AM     IFACE   rxpc"
	[network_errors]="12:00:01 AM     IFACE   rxer"
	[nfs_client]="12:00:01 AM    call\/s retran"
	[nfs_server]="12:00:01 AM   scall\/s badcal"
	[sockets]="12:00:01 AM    totsck    tcp"
)

for table in "${!sar_segs[@]}"
do
  echo "Loading: $table"

	start_marker="${sar_segs[$table]}"

	awk -v sar_date="$sar_date" '/^'"$start_marker"'/,/^Average:/ {
	if (length($0)>0)
		printf("%s %s\n",sar_date,$0);
	}' "$sar_report" | \
		egrep -v "Average|^$|12:00:01 AM|CPU" | \
		sed -e 's/^ //g' -e 's/ \+/|/g' | \
		awk -v hostid=$host_id '{print hostid"|"substr($0,1,10)" "substr($0,12,8)" "substr($0,21)}' > $tmpfile

	$PSQL -c "\\COPY ${table} FROM '${tmpfile}' WITH CSV DELIMITER '|';"

	rm -f $tmpfile
done


$PSQL -c "REFRESH MATERIALIZED VIEW summary WITH DATA;"
