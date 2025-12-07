The variables on top are the ones you need to update to your situation:

- BASE_URL="https://domain.nl:9200"
- FILENAME="filebeat-8.19.1-2025"
- USERDATA="username:password"
- IPADDRESS="127.0.0.1"
- MONTH="01"
- STARTDATE=1
- ENDDATE=31

```Then you can run the script with bash ./elastic-cleaner.sh```

If you don't know the name of your files, you can use the Console of DevTools (item Management) in Kibana to retrieve the data:

```
GET _cat/indices?v&s=index:asc
```

If you do not have the option to place the .sh file on the server and/or run the script, you can do it manually in the Console of DevTools.

```
POST [FILENAME]/_delete_by_query?conflicts=abort
{
  "query": {
    "term": {
      "web.access.remote_ip": "[IP-ADDRESS]"
    }
  }
}
```

This causes marking the documents in the index as "deleted". Then you want to really delete them. You do this by making the index read-only and then call the delete-function:

```
PUT [FILENAME]/_settings
{ "index.blocks.write": true }

POST [FILENAME]/_forcemerge?only_expunge_deletes=true&wait_for_completion=false
```

This process can take some time, you monitor the progress by calling this function:

```
GET /_tasks?actions=indices:admin/forcemerge&detailed=true
```

When processing is finished the result is:

```
{\"nodes\":{}}
```