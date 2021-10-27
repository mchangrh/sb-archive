#!/bin/bash
cd /var/www/sponsorblock || exit

function archive {
  # get date
  fileDate=$(date -r latest/vipUsers.csv +%F_%H-%M)
  tar --zstd -cf "mirror/$fileDate.tar.zst" latest/*
}

archive