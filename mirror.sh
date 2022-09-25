#!/bin/sh
MIRROR_DIR="/var/sb-mirror/mirror"
STAGING_DIR="/var/sb-mirror/staging"

prepare() {
  # set up staging dir
  rm $STAGING_DIR/*.*
  # copy files over for rsync
  cp -a $MIRROR_DIR/* $STAGING_DIR
}

cleanup_archive() {
  # rm files with size 0
  find $STAGING_DIR -size 0 -exec rm {} \;
  # files have size, move over
  mv $STAGING_DIR/sponsorTimes.csv.zst $MIRROR_DIR
  mv $STAGING_DIR/lastUpdate.txt $MIRROR_DIR
  cp -a $STAGING_DIR/*.csv $MIRROR_DIR
  # create archive dir
  fileDate=$(date -r $STAGING_DIR/vipUsers.csv +%F_%H-%M)
  mkdir $STAGING_DIR/"$fileDate"
  # move files to archive dir
  mv $STAGING_DIR/*.csv $STAGING_DIR/"$fileDate"
  # ship to archive
  rclone move --delete-empty-src-dirs $STAGING_DIR archive:/sb-archive/"$fileDate"
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
      curl --compressed -L https://sponsor.ajay.app/download/"${table}".csv?generate=false -o "${STAGING_DIR}"/"${table}".csv
    # run to validate
    rsync -tvP --contimeout=3 rsync://rsync.sponsor.ajay.app:31111/sponsorblock/"${table}"_"${DUMP_DATE}".csv "${STAGING_DIR}"/"${table}".csv
  done
  date -d@"$(echo "$DUMP_DATE" | cut -c 1-10)" +%F_%H-%M > "${STAGING_DIR}"/lastUpdate.txt
  date -d@"$(echo "$DUMP_DATE" | cut -c 1-10)" +%F_%H-%M >> /var/log/sb-mirror-updates.log
  # compress sponsorTimes
  zstd "${STAGING_DIR}"/sponsorTimes.csv -f1
}
prepare
download
cleanup_archive