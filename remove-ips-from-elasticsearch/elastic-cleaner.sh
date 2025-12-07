BASE_URL="https://domain.nl:9200"
FILENAME="filebeat-8.19.1-2025"
USERDATA="username:password"
IPADDRESS="127.0.0.1"
MONTH="01"
STARTDATE=1
ENDDATE=31
function remove_zabbixips {
  day="$1"
  url="$BASE_URL/$FILENAME.$MONTH.$day/_delete_by_query?conflicts=abort"
  output=$(curl -k -sS -u "$USERDATA" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -X POST $url -d '{"query": {"term": {"web.access.remote_ip": "$IPADDRESS"}}}')
  deleteCount=$(echo $output | cut -d',' -f4 | cut -d':' -f2)
  echo "Deleted records for date 2025.$MONTH.$1 : IP $IPADDRESS = $deleteCount"
  if [ $deleteCount1 -ne 0 ];
  then
    remove_zabbixips "$1"
  else
    echo "No records to delete for date $MONTH.$day"
  fi
}

function readonlyindex {
 url="$BASE_URL/$FILENAME.$MONTH.$1/_settings"
 output=$(curl -k -sS -u "$USERDATA" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -X PUT $url -d '{"index.blocks.write": true}')
 echo $output
}

function forcemerge {
 url="$BASE_URL/$FILENAME.$MONTH.$1/_forcemerge?only_expunge_deletes=true&wait_for_completion=false"
 output=$(curl -k -sS -u "$USERDATA" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -X POST $url)
 echo $output    
}

function getmergestatus {
 url="$BASE_URL/_tasks?actions=indices:admin/forcemerge&detailed=true"
 output=$(curl -k -sS -u "$USERDATA" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -X GET $url)
 echo $output   
 if [[ $output == "{\"nodes\":{}}" ]];
 then
 {
   echo "FINISHED"
 }
 else
 {
   sleep 1m
   getmergestatus
 }
 fi
}

m=$STARTDATE
while [ $m -lt $ENDDATE ]
do
{
  if [[ $m -lt 10 ]];
 then
   day="0$m"
 else
   day="$m"
 fi
  remove_zabbixips "$day"
  sleep 30s
  readonlyindex "$day"
  sleep 30s
  forcemerge "$day"
  sleep 2m
  getmergestatus
  m=$((m+1))
}
done
echo "DONE"