# video and timelapse tools
bash-scripts for handling video- and imagefiles for timelapsing - GoPro-Users will deserve it

running on debian linux with ffmpeg, exiv, melt and mediainfo (thanks a lot)  
* **video2img.s** generates jpg-files out of videos with exif-stamps (DateTimeOriginal) according to video run time  
* **videodial4imgs.sh** generates a video out of jpeg images and enblends a dial bottom-right with the exif date and time
* **videoslices.sh** cuts automatically video slices out of a video  
* **videofade.sh** combines the slices by fading one in another  
* **videodial4vids.sh** draws a dial over a video  

## scenario 1
make timelapse video with speedup > 30 and enblend a dial with real time and date info

1. **video2img.sh** generates every n-th frame an images with exif-timestamp out the real videoinfo
2. manually delete the jpgs you don't want to show
3. let **videodial4imgs.sh** generate the timelapsed video out of every n-th imaage with the dial in lower right corner of the video

## scenario 2
speedup videoimpression of GoPro-video

1. **videoslices.sh** cuts short scenes every n secondes
2. manually delete the slices you don't want to show
3. **videofade.sh** fades the scenes together

## scenario 3
just want to have a realtime dial enblended in a video

1. **videodial4vids.sh** uses the date/time info of the video and draws a dial at the lower right of the video

