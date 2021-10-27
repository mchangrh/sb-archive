#!/bin/bash
cd /var/www/sponsorblock || exit

function download {
  URL=sponsor.ajay.app
  # download from main server so get filenames
  curl -s -L $URL/database.json?generate=false -o response.json
  DUMP_DATE=$(cat response.json | jq .lastUpdated)
  tables=$(cat response.json | jq -r .links[].table)
  # set $@ since posix doesn't have named variables
  for table in $tables
  do
    rsync -ztvP --zc=lz4 --append rsync://$URL/sponsorblock/${table}_${DUMP_DATE}.csv latest/${table}.csv
  done
  rm response.json
  echo $DUMP_DATE > lastUpdate.txt
}

download