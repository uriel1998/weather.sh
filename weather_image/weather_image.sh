#!/bin/bash



#TempDir=$(mktemp -d)
TempDir=/home/steven/tmp
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BlurVar=""

# -b add blur
# -d image directory to choose from
# -i image file to use
# -h height if sourced from pixabay
# -w height if sourced from pixabay 
# -o output file (defaults to PWD/out.jpg)
while [ $# -gt 0 ]; do
option="$1"
    case $option
    in
        -b) BlurVar="True"
        shift ;;
        -d) ImageDir="$2"
        if [ ! -d ${ImageDir} ];then
            ImageFile=""
        else
            find -H "$ImageDir" -type f  -iname ".jpg" -iname ".png" 
            ImageFile=$(fdfind . ${ImageDir} --follow --type file --extension png --extension jpg | sort -R | head -1)
            if [ ! -f ${ImageFile} ];then
                ImageFile=""
            fi
        fi
        shift
        shift ;;
        -i) ImageFile="$2"
        if [ ! -f ${ImageFile} ];then
            ImageFile=""
        fi
        shift
        shift ;;
        -w) UnsplashWidth="$2"
        shift
        shift ;;    
        -h) UnsplashHeight="$2"
        shift
        shift ;;
        -o) OutputFile="$2"
        shift
        shift ;;
    esac
done

if [ -z $UnsplashHeight ];then
    UnsplashHeight="1080"
fi
if [ -z $UnsplashWidth ];then
    UnsplashWidth="1920"
fi



################################################################################
# Wherein things get told to happen
################################################################################
main() {
	if [ -z ${ImageFile} ];then
    echo "hi"
        wget_bin=$(which wget)
        # Obtain source image
        execstring="${wget_bin} https://picsum.photos/${UnsplashWidth}/${UnsplashHeight}/?random -O $TempDir/unsplash.jpg"
        eval $execstring
	else
        cp ${ImageFile} $TempDir/unsplash.jpg
    fi
    
    if [ ! -z "$BlurVar" ];then
        # Blur, if desired. 
        convert $TempDir/unsplash.jpg -blur 0x4 $TempDir/unsplash_blur.jpg
    else
        cp $TempDir/unsplash.jpg $TempDir/unsplash_blur.jpg
    fi
    
    ImageSize=$(identify $TempDir/unsplash_blur.jpg  | awk '{print $3}')
    ImageWidth=$(echo ${ImageSize} | awk -F 'x' '{print $1}')
    ImageHeight=$(echo ${ImageSize} | awk -F 'x' '{print $2}')
    TextWidth=$(( $ImageWidth / 2 ))
    TextHeight=$(( $ImageHeight / 2 ))
    
    # Get our text and make it into an image
	DataInfo=$(${SCRIPT_DIR}/weather.sh | grep -v "Cache")
    IconData=$(echo "$DataInfo" | head -1)
    TextData=$(echo "$DataInfo" | tail -6)
    cp ${SCRIPT_DIR}/icons/"$IconData".png ${TempDir}/WeatherIcon.png
	/usr/bin/convert -background none -fill white -stroke black -strokewidth 2 -gravity Southeast -font Abydos -size "$TextWidth"x"$TextHeight" \
          caption:"$TextData" \
          -gravity Southwest \
          $TempDir/TextImage.png

    # Applying the appropriate icon to the image.  This has to be done in 
    # steps for the transparency to keep working.
    /usr/bin/composite -gravity Center $TempDir/WeatherIcon.png -gravity Southwest $TempDir/TextImage.png $TempDir/Text_Icon.png
   
   # Applying the text and icon to the base image.
    /usr/bin/composite -gravity Southeast $TempDir/Text_Icon.png $TempDir/unsplash_blur.jpg $TempDir/weather.jpg
    if [ -z $OutputFile ]; then
        cp $TempDir/weather.jpg $SCRIPT_DIR/output.jpg
    else
        cp $TempDir/weather.jpg ${OutputFile}
    fi
    
	exit 0
}

main

rm $TempDir/TextImage.png
rm $TempDir/unsplash_blur.jpg
rm $TempDir/unsplash.jpg
rm $TempDir/WeatherIcon.png
rm $TempDir/mailcontent.txt
rmdir $TempDir
#echo $TempDir

