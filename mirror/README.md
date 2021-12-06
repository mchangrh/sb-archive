5 minute mirror of the SponsorBlock database (https://sponsor.ajay.app)

SponsorBlock data licenced and used under CC BY-NC-SA 4.0 from https://sponsor.ajay.app

Usage:
```
docker run --rm -it -v "${PWD}/sb-mirror:/mirror" mchangrh/sb-mirror:alpine -e "MIRROR_URL=sb-mirror.mchang.xyz"

rsync -crztvP --zc=lz4 --cc=xxh3 --append --contimeout=3 rsync://sb-mirror.mchang.xyz/sponsorblock ./sb-mirror
```