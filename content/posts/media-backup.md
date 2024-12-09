---
title: "Media Backup"
date: 2022-03-23T08:55:17-04:00
draft: false
author: "Tom Ratcliff"
toc: true
summary: Store and copy your DVDs for archival
tags: ["media", "dvd", "ffmpeg"]
categories: ["Backup"]
---

## Backup Media From DVD to Filesystem

1. Get sector size and count of the DVD
```bash
sudo isosize -x /dev/sr0
```

2. Write the contents of the DVD to an ISO
```bash
sudo dd if=/dev/sr0 of=dvd.iso bs=2048 count=2131422 status=progress
```

![Imgur](https://i.imgur.com/lPTXDLV.png)

3. Mount the ISO and inspect the contents

```bash
sudo mount -o loop dvd.iso /mnt/iso
ls /mnt/iso/VIDEO_TS/
```

![Imgur](https://i.imgur.com/GifzsfV.png)

4. Use FFmpeg to convert VOB to preferred format

> For lossless

```bash
ffmpeg -i VTS_01_1.VOB -c:a copy -c:v libx265 -preset ultrafast -x265-params lossless=1 ~/mycoolvid.mkv
```

> For compressed choose a suitable crf (higher the more compressed, lower closer to lossless)

```bash
ffmpeg -i VTS_01_1.VOB -c:a copy -c:v libx265 -preset ultrafast -crf 21 ~/mycoolvid.mkv
```

> If there's multiple .VOBs, you can concat them with a shell script and then use ffmpeg (ie: shows to movie)

```bash
ls -1 *VOB | tr '\n' '|'
ffmpeg -i concat:"VTS_01_1.VOB|VTS_02_1.VOB|VTS_03_1.VOB|VTS_04_1.VOB|VTS_05_1.VOB|VTS_06_1.VOB|VTS_07_1.VOB|VTS_08_1.VOB|VTS_09_1.VOB|VTS_10_1.VOB|VTS_11_1.VOB|VTS_12_1.VOB|VTS_13_1.VOB|VTS_14_1.VOB|VTS_15_1.VOB|VTS_16_1.VOB|VTS_17_1.VOB" -c:a copy -c:v libx265 -preset ultrafast -crf 21 ~/mycoolvid.mkv
```
![Imgur](https://i.imgur.com/t6TKLqk.png)

**Script to bulk process**
> :warning: this will remove the original content (copy of mkv)
```bash
#!/bin/bash
IFS=$'\n'
for i in $(find . -iname '*mkv'); do
  ffmpeg -i $i -target ntsc-dvd movie.mp4
  dvdauthor --title --video=ntsc -o dvd -f movie.mp4
  dvdauthor -o dvd -T
  mkisofs -dvd-video -o "${i%.mkv}.iso" dvd/
  rm -r dvd
  rm $i
  rm movie.mp4
done
```

## Backup Media from Filesytem to DVD

1. Convert file (if needed)

```bash
ffmpeg -i my_movie.avi -target ntsc-dvd movie.mpg
```

2. Create DVD folder for AUDIO_TS & VIDEO_TS

```bash
dvdauthor --title --video=ntsc -o dvd -f movie.mpg
```

3. Create Titles

```bash
dvdauthor -o dvd -T
```

4. Make an ISO of the directory

```bash
mkisofs -dvd-video -o dvd.iso dvd/
```

5. Burn image to DVD

```bash
wodim -v dev=/dev/sr0 -eject dvd.iso
```
