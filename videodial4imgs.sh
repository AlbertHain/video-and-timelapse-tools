#!/bin/bash
# create timelapsevideo with moving big and little hands

######################################
uses=3		# every n-th image
######################################
if [ $# -gt 0 ]; then                               # work within directory
    filepath=${1%/*};
    filename=${1##*/};
    if [ "$filepath" != "$filename" ]; then
        cd $filepath;
    fi
fi

processdir="interval_"$uses
if [ ! -d $processdir ]; then
	mkdir $processdir
fi
prefix="clocked"

fontcolor="'#000000'"
fontshadow="'#888888'"
transparency="'#888888'"
if [ $# -gt 0 ]; then						# use dimensions of first image for videofile
	imgwidth=`identify -format "%w" "$1"`
	imgheight=`identify -format "%h" "$1"`
fi;
destinationframerate=30
font="/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf"
fontsize=`echo "scale=0; $imgheight/50" | bc`

dialsize=`echo "scale=0; $imgheight/5" | bc`
fontsize=`echo "scale=0; $dialsize/8" | bc`

radius=`echo "scale=0; $dialsize/2" | bc`
mhandlength=`echo "scale=0; $dialsize*0.45/1" | bc`
hhandlength=`echo "scale=0; $dialsize*0.3/1" | bc`
mhandwidth=`echo "scale=0; $dialsize/60" | bc`
hhandwidth=`echo "scale=0; $dialsize/40" | bc`
dialx=`echo "scale=0; ($imgwidth-1.1*$dialsize)/1" |bc`		# just division takes care of trailing numbers
dialy=`echo "scale=0; ($imgheight-1.1*$dialsize)/1" |bc`
datex=`echo "scale=0; $radius/2" |bc`
datey=`echo "scale=0; $radius*3/2" |bc`

xoffset1=1710
yoffset1=20
xoffset2=$xoffset1+2
yoffset2=$yoffset1-2

dialplate=$processdir"/dialplate.png"
dialalpha=$processdir"/dialalpha.png"
bighand=$processdir"/bighand.png"
littlehand=$processdir"/littlehand.png"
hour_r=$processdir"/hour_r.png"
minute_r=$processdir"/minute_r.png"
dial2=$processdir"/dial2.png"
dial=$processdir"/dial.png"

s_dialplate="convert -size "$dialsize"x"$dialsize" xc:transparent -fill grey -stroke black "
s_dialplate+="-strokewidth "$mhandwidth" -draw 'circle "$radius","$radius" "$radius","$mhandwidth"' "$dialplate
eval ${s_dialplate}

# s_dialalpha="convert -size "$dialsize"x"$dialsize" xc:transparent -fill '#444444' alpha set"
s_dialalpha="convert -size "$dialsize"x"$dialsize" xc:transparent -fill $transparency"
s_dialalpha+=" -draw 'circle "$radius","$radius" "$radius","$mhandwidth"' "$dialalpha
eval ${s_dialalpha}
# convert $dialalpha alpha on

# bighand 6:00 Nullstellung rectangle-Koordinaten ul or
s_bighand="convert -size "$dialsize"x"$dialsize" xc:transparent -fill black -stroke black "
s_bighand+="-draw 'roundrectangle "$[$radius-$hhandwidth]","$[$radius-$hhandlength]" "
s_bighand+=$[$radius+$hhandwidth]","$[$radius+$hhandwidth]" $hhandwidth,$hhandwidth' "$bighand
eval ${s_bighand}

# littlehand 6:00 Nullstellung rectangle-Koordinaten ul or
s_littlehand="convert -size "$dialsize"x"$dialsize" xc:transparent -fill black -stroke black "
s_littlehand+="-draw 'roundrectangle "$[$radius-$mhandwidth]","$[$radius-$mhandlength]" "
s_littlehand+=$[$radius+$mhandwidth]","$[$radius+$mhandwidth]" $mhandwidth,$mhandwidth' "$littlehand
eval ${s_littlehand}

#
# convert -size 80x80 xc:transparent -fill black -stroke black -draw "roundrectangle 38,10 42,40 2,2" $bighand
# convert -size 80x80 xc:transparent -fill black -stroke black -draw "roundrectangle 39,3 41,40 2,2"  $littlehand

if [ $# -gt 0 ]; then
	sourcetype=${1##*.}
	case "$sourcetype" in
		jpg|JPG ) destinationtype="jpg";;
		tif|TIF ) destinationtype="tif";;
	esac
    counter=0
    intervall=$uses
    while [ $# -gt 0 ]; do
		if [ $intervall -eq $uses ]; then                  # we got the n-th image
			sourcename=${1##*/};                              # we are already in the working directory
	    	counterstring="$(printf "%05d" $counter)";
			processedname=$processdir"/"$prefix$counterstring"."$destinationtype
       		echo -ne $sourcename" -> "$processedname"\r"
         	cp "$sourcename" "$processedname"

############ fetch datetime ################
            datetime=$(exiftool -b -DateTimeOriginal "$sourcename" 2> /dev/null);        # usually 2005:04:11 19:06:52.
            year=$(echo     "$datetime" | cut -c 1-4)              # 4-digits to check for correct year
            month=$(echo    "$datetime" | cut -c 6-7)
            day=$(echo      "$datetime" | cut -c 9-10)
            hour=$(echo   "$datetime" | cut -c 12-13)
            minute=$(echo   "$datetime" | cut -c 15-16)
            second=$(echo  "$datetime" | cut -c 18-19)
############ create date label ################
            datdial=$day"."$month"."${year#20}" "$hour":"$minute
 			text=$day"."$month"."${year#20}

 			stext="mogrify -font $font -pointsize $fontsize "
 	        stext+=" -fill $fontcolor -draw \"text $datex,$datey '$text'\""
 	        stext+=" $dial2 "
############ create time-hands ################
			hourangle=`echo "scale=2; (($hour+($minute/60))*360/12)/1" | bc`;
			minuteangle=`echo "scale=2; ($minute*6 + $second/10)/1" | bc`;

			convert $littlehand -distort SRT $minuteangle -transparent white $minute_r
			convert $bighand -distort SRT $hourangle -transparent white $hour_r

			composite -gravity center $hour_r $dialplate $dial
			composite -alpha set -gravity center $minute_r $dial $dial2

			eval ${stext}

			transparent="convert $dial2 $dialalpha -alpha off -compose CopyOpacity -composite $dial"
 			eval ${transparent}

 			composite -alpha set -geometry +$dialx+$dialy $dial "$sourcename" "$processedname"

############ dial finished ################
			counter=$[$counter+1];					               # next used image
			intervall=0;							               # start over at 0
		fi
		intervall=$[$intervall+1];					               # next interval-image
		shift
	done
	                                                               # cleanup
	rm $dialplate
	rm $dialalpha
	rm $bighand
	rm $littlehand
	rm $hour_r
	rm $minute_r
	rm $dial2
	rm $dial
	##### create the video out of the images
	videoname="../video_"$uses".mp4"
	if [ -f "$videoname" ]; then          # file exists?
		echo -e "\E[1;33;40m "$videoname" already in use, attach date-time to filename\E[0m";
		datetime=$(date +%y-%m-%d_%H%M%S)				# 16-12-23_184533
		videoname=${videoname%.*}"_"$datetime".mp4";
    fi
	ffmpeg -v quiet -stats -r 30 -i $processdir/$prefix%05d.jpg -r $destinationframerate -vf format=yuv420p -crf 23 $videoname
# you probably cleanup automatically
# 	rm $processdir/$prefix*.jpg
# 	rmdir $processdir

else
echo "generates a timelapsevideo out of images, enblends a dial based ont the exif-dates given (AD 2017-08-05)"
echo "Syntax: timelapse *.jpg"
fi
