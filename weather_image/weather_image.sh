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
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
            #cp ${SCRIPT_DIR}/${icons%?}.png 

################################################################################
# Wherein things get told to happen
################################################################################
main() {
	
    
    # Obtain source image
    bob=`wget https://picsum.photos/1920/1080/?random -O $TempDir/unsplash.jpg`
	
    # Blur, if desired.
    convert $TempDir/unsplash.jpg -blur 0x3 $TempDir/unsplash_blur.jpg

    # Get our text and make it into an image
	DataInfo=$(${SCRIPT_DIR}/weather.sh | grep -v "Cache")
    IconData=$(echo "$DataInfo" | head -1)
    TextData=$(echo "$DataInfo" | tail -6)
    cp ${SCRIPT_DIR}/icons/"$IconData".png ${TempDir}/WeatherIcon.png
	/usr/bin/convert -background none -fill white -stroke black -strokewidth 2 -gravity Southeast -font Abydos -size 800x400 \
          caption:"$TextData" \
          -gravity Southwest \
          $TempDir/TextImage.png

    # Applying the appropriate icon to the image.  This has to be done in 
    # steps for the transparency to keep working.
    
    /usr/bin/composite -gravity Center $TempDir/WeatherIcon.png -gravity Southwest $TempDir/TextImage.png $TempDir/Text_Icon.png
   
   # Applying the text and icon to the base image.
   
    /usr/bin/composite -gravity Southeast $TempDir/Text_Icon.png $TempDir/unsplash_blur.jpg $TempDir/weather.jpg
    
        
      

	exit 0
}

main

rm $TempDir/TextImage.png
rm $TempDir/unsplash_blur.jpg
rm $TempDir/unsplash.jpg
rm $TempDir/mailcontent.txt
rmdir $TempDir
#echo $TempDir

