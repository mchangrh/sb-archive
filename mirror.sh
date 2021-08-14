#!/bin/bash
cd /var/www/sponsorblock || exit

function download {
  cd latest || exit
  wget -N --header='Accept-Encoding: gzip' https://sb.ltn.fi/database/categoryVotes.csv
  wget -N --header='Accept-Encoding: gzip' https://sb.ltn.fi/database/lockCategories.csv
  wget -N --header='Accept-Encoding: gzip' https://sb.ltn.fi/database/noSegments.csv
  wget -N --header='Accept-Encoding: gzip' https://sb.ltn.fi/database/sponsorTimes.csv
  wget -N --header='Accept-Encoding: gzip' https://sb.ltn.fi/database/userNames.csv
  wget -N --header='Accept-Encoding: gzip' https://sb.ltn.fi/database/vipUsers.csv
  wget -N --header='Accept-Encoding: gzip' https://sb.ltn.fi/database/warnings.csv
  cd ..
}

function archive {
  # get date
  fileDate=$(date -r latest/vipUsers.csv +%F_%R)
  tar --zstd -cf "mirror/$fileDate.tar.zst" latest/*
}

download
archive