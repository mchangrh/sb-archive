This is an archival mirror of the SponsorBlock database

Source: https://sponsor.ajay.app/database

For licence and usage details, please see the above reference.

Archives are taken once a day from https://sb.ltn.fi/database at midnight UTC and then archived with zstd in mirror

once size becomes a considerable issue, they will be moved off-site or archived with a higher compression level.

Usage:
```
docker run --rm -it -v "${PWD}/sb-mirror:/mirror" -e "MIRROR_URL=sb-mirror.mchang.xyz" mchangrh/sb-mirror:alpine

rsync -crztvP --zc=lz4 --cc=xxh3 --append --contimeout=3 --exclude='*.txt' rsync://sb-archive.mchang.xyz/sponsorblock ./sb-mirror
```