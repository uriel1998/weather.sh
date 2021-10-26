#!/bin/bash

source /home/steven/.bashrc
source /home/steven/.bash_aliases


########################################################################
# Declarations
########################################################################
declare Fortune

#create tempfile (for unsplash image)
#create tempfile2  (for text image )
#TempDir=$(mktemp -d)

TempDir=/home/steven/tmp

################################################################################
# Wherein things get told to happen
################################################################################
main() {
	bob=`wget https://picsum.photos/1920/1080/?random -O $TempDir/unsplash.jpg`
	convert $TempDir/unsplash.jpg -blur 0x3 $TempDir/unsplash_blur.jpg
	Fortune=$(/home/steven/bin/weather.sh -n | tail -6 | sed 's/°/ deg /g' | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | grep -v "Cache")
	/usr/bin/convert -background none -fill white -stroke black -strokewidth 2 -gravity Southeast -font Interstate -size 1920x400 \
          caption:"$Fortune" \
          -gravity Southwest \
          $TempDir/TextImage.png

    /usr/bin/composite -gravity Southwest $TempDir/TextImage.png $TempDir/unsplash_blur.jpg $TempDir/weather_background.jpg
        
      

	exit 0
}

main

rm $TempDir/TextImage.png
rm $TempDir/unsplash_blur.jpg
rm $TempDir/unsplash.jpg
rm $TempDir/mailcontent.txt
rmdir $TempDir
#echo $TempDir

