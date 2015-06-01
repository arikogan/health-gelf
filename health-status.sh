#!/bin/sh

VERSION="1.1"
HOST=`hostname --long`
MESSAGE="Server Health Status"
TIMESTAMP=`date +%s`
LEVEL=1

GRAYLOG_SERVER=graylog.fxempiredev.com
GRAYLOG_PORT=12306

CPU=`grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'`

LOAD=`uptime | awk -F "load average:" '{print $2}' | cut -f 1 -d,`

MEMORY_TOTAL=`grep "MemTotal:" /proc/meminfo | awk '{msum+=$2} END {printf "%.0f",msum}'`
MEMORY_FREE=`grep "MemFree:" /proc/meminfo | awk '{mfree+=$2} END {printf "%.0f",mfree}'`
MEMORY_FREE_PERC=`awk "BEGIN { print "$MEMORY_FREE*100/$MEMORY_TOTAL" }"`
MEMORY_USED_PERC=`awk "BEGIN { print "100-$MEMORY_FREE*100/$MEMORY_TOTAL" }"`

SWAP_TOTAL=`grep "SwapTotal:" /proc/meminfo | awk '{ssum+=($2/1024)/1024} END {printf "%.0f",ssum}'`
SWAP_FREE=`grep "SwapFree:" /proc/meminfo | awk '{sfree+=($2/1024)/1024} END {printf "%.0f",sfree}'`
SWAP_FREE_PERC=`awk "BEGIN { print "$SWAP_FREE*100/$SWAP_TOTAL" }"`
SWAP_USED_PERC=`awk "BEGIN { print "100-$SWAP_FREE*100/$SWAP_TOTAL" }"`

MSG="{\"version\": \"$VERSION\""
MSG="$MSG,\"host\":\"$HOST\""
MSG="$MSG,\"short_message\":\"$MESSAGE\""
# MSG="$MSG,\"full_message\":\"\""
MSG="$MSG,\"timestamp\":$TIMESTAMP"
MSG="$MSG,\"level\":$LEVEL"

MSG="$MSG,\"_cpu\":$CPU"
MSG="$MSG,\"_load\":$LOAD"
MSG="$MSG,\"_free_memory_perc\":$MEMORY_FREE_PERC"
MSG="$MSG,\"_used_memory_perc\":$MEMORY_USED_PERC"
MSG="$MSG,\"_free_swap_perc\":$SWAP_FREE_PERC"
MSG="$MSG,\"_user_swap_perc\":$SWAP_USED_PERC"

MSG="$MSG}"

# echo $MSG
echo $MSG | gzip -cf | nc -w 1 -u $GRAYLOG_SERVER $GRAYLOG_PORT