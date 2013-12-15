#!/bin/bash

cli_password="password"

# Check FreeSWITCH connection status
connection=`/usr/local/freeswitch/bin/fs_cli -p $cli_password -x "show calls count"`
if [ $? -ne 0 ]; then
        connection_status=2
        connection_result="Critical: Freeswitch not responding!"
        echo "$connection_status Call_Count - $connection_result"
        echo "$connection_status Calls_Per_Second - $connection_result"
        exit 1
fi

# Check existing number of calls
call_count=`echo $connection|grep total|awk '{print $1}'`

if [ $call_count -gt 500 ]; then
        call_count_status=1
        call_count_result="Possible DDoS attack"
else
        call_count_status=0
        call_count_result="Call counts looks good."
fi

# Check calls per second
cps=`/usr/local/freeswitch/bin/fs_cli -p $cli_password -x "status" | grep -o -P "(?<=\(s\) )[0-9]+(?=/)"`

if [ $cps -gt 20 ]; then
	cps_status=2
	cps_result="Possible DDos attack"
else
	cps_status=0
	cps_result="calls per second"
fi

# Build a message up
echo "$call_count_status Call_Count count=$call_count;;500;0;1000 $call_count live calls, $call_count_result"
echo "$cps_status Calls_Per_Second cps=$cps;15;20;0;30 $cps $cps_result"

exit 0