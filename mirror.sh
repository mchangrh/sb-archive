#!/bin/bash
cd /var/www/sponsorblock || exit

function download {
  cd latest || exit
  wget -N https://sb.ltn.fi/database/categoryVotes.csv
  wget -N https://sb.ltn.fi/database/noSegments.csv
  wget -N https://sb.ltn.fi/database/userNames.csv
  wget -N https://sb.ltn.fi/database/vipUsers.csv
  wget -N https://sb.ltn.fi/database/warnings.csv
  wget -N https://sb.ltn.fi/database/lockCategories.csv
  wget -N https://sb.ltn.fi/database/sponsorTimes.csv
  cd ..
}

function archive {
  # get date
  fileDate=$(date -r latest/vipUsers.csv +%F_%H-%M)
  tar --zstd -cf "mirror/$fileDate.tar.zst" latest/*
}

download
archive
