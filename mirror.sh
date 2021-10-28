#!/bin/bash
cd /var/www/sponsorblock || exit

function download {
  URL=sponsor.ajay.app
  # download from main server so get filenames
  curl -sL $URL/database.json?generate=false -o response.json
  EXTRAPARAM=$@
  DUMP_DATE=$(jq .lastUpdated < response.json)
  tables=$(jq -r .links[].table < response.json)
  # set $@ since posix doesn't have named variables
  for table in $tables
  do
    rsync -aztvP --zc=lz4 "$EXTRAPARAM" --append rsync://$URL/sponsorblock/"${table}"_"${DUMP_DATE}".csv latest/"${table}".csv
  done
  rm response.json
  echo "$DUMP_DATE" > latest/lastUpdate.txt
}

function validate {
  FAIL=0
  for file in latest/*.csv; do
    if ! csvlint "$file"; then
      rm "$file"
      FAIL=1
    fi
  done
  echo $FAIL
  if [ $FAIL -eq 1 ]; then
    FAIL=0
    echo "Downloading failed files"
    download --ignore-existing
  fi
}

download
validate