# sb-archive
historical archive of the SponsorBlock database (Licenced under CC BY-NC-SA 4.0 from https://sponsor.ajay.app)

Available over:  
https (CloudFlare) `https://sb-archive.mchang.xyz/`  
http (Direct) `http://qc.mchang.xyz/`  
rsync `rsync://qc.mchang.icu/sponsorblock`  
sb-mirror:
```sh
docker run --rm -it -v "${PWD}/sb-mirror:/mirror" -e MIRROR_URL=qc.mchang.icu mchangrh/sb-mirror:latest
```

Will try to preserve files as long as I can, will move older backups to GSuite if necessary 

Backups taken once daily @ midnight UTC, server is on a 100M connection so please be kind.
