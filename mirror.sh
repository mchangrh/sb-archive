#!/bin/sh
MIRROR_DIR="/mnt/sb-mirror/mirror"
STAGING_DIR="/mnt/sb-mirror/staging"

prepare() {
  # set up staging dir
  rm $STAGING_DIR/*.*
  # copy files over for rsync
  cp -a $MIRROR_DIR/* $STAGING_DIR --reflink=always
}

cleanup_archive() {
  # rm files with size 0
  find $STAGING_DIR -size 0 -exec rm {} \;
  # remove "html" files
  find $STAGING_DIR -type f -exec file --mime-type {} + | awk -F: '$(NF) ~ "html" {print $1}' | xargs rm
  # files have size, move over
  mv $STAGING_DIR/* $MIRROR_DIR
  # chmod files to avoid access denied
  chmod -R 775 $MIRROR_DIR
}

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
    rsync -tvP --contimeout=10 rsync://rsync.sponsor.ajay.app:31111/sponsorblock/"${table}"_"${DUMP_DATE}".csv "${STAGING_DIR}"/"${table}".csv ||
      curl --compressed -L https://sponsor.ajay.app/database/"${table}".csv?generate=false -o "${STAGING_DIR}"/"${table}".csv
    # run to validate
    rsync -tvP --contimeout=3 rsync://rsync.sponsor.ajay.app:31111/sponsorblock/"${table}"_"${DUMP_DATE}".csv "${STAGING_DIR}"/"${table}".csv
  done
  date -d@"$(echo "$DUMP_DATE" | cut -c 1-10)" +%F_%H-%M > "${STAGING_DIR}"/lastUpdate.txt
  date -d@"$(echo "$DUMP_DATE" | cut -c 1-10)" +%F_%H-%M >> /home/sb-mirror-updates.log
  # compress sponsorTimes
  zstd "${STAGING_DIR}"/sponsorTimes.csv -f1
  gzip "${STAGING_DIR}"/sponsorTimes.csv --fast
}
prepare
download
cleanup_archive
