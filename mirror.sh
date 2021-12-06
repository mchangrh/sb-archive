#!/bin/sh
MIRROR_DIR="/root/sb-mirror/mirror"

download() {
  # get filenames
  curl -sL https://sponsor.ajay.app/database.json?generate=false -o response.json
  DUMP_DATE=$(jq .lastUpdated < response.json)
  # set $@ since posix doesn't have named variables
  set -- $(jq -r .links[].table < response.json)
  rm response.json

  for table in "$@"
  do
    echo "Downloading $table.csv"
    rsync -cztvP --zc=lz4 --cc=xxh3 --append --contimeout=10 rsync://rsync.sponsor.ajay.app/sponsorblock/"${table}"_"${DUMP_DATE}".csv "${MIRROR_DIR}"/"${table}".csv ||
      curl --compressed -L https://sponsor.ajay.app/download/"${table}".csv?generate=false -o "${MIRROR_DIR}"/"${table}".csv
    # run to validate
    rsync -cztvP --zc=lz4 --cc=xxh3 --append --contimeout=3 rsync://rsync.sponsor.ajay.app/sponsorblock/"${table}"_"${DUMP_DATE}".csv "${MIRROR_DIR}"/"${table}".csv
  done
  date -d@"$(echo "$DUMP_DATE" | cut -c 1-10)" +%F_%H-%M > "${MIRROR_DIR}"/lastUpdate.txt
}

download