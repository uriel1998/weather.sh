#!/bin/bash

TempDir=$(mktemp -d)
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BlurVar=""
FD_FIND=$(which fdfind)
# Going to do programmer style counting, starting at 0 here.
NumOutput=1 
OccasionalRandom=""
RandoRun=""
FontFamily=""
ExplicitConfigFilePath=""

get_image () {
    if [ -d "$ImageDir" ];then
        if [ -f "$FD_FIND" ];then
            ImageFile=$(fdfind . "$ImageDir" --follow --type file --extension png --extension jpg | shuf -n 1 )
        fi
        if [ ! -f "${ImageFile}" ];then
            ImageFile=$(find "$ImageDir" -type f  -iname "*.jpg" -or -iname "*.png" -printf '%h\n' | shuf -n 1 )
        fi
    fi
    if [ ! -f "${ImageFile}" ];then
        ImageFile=""
    fi
}


print_help (){

    echo " # USAGE: weather_images.sh [options]"
    echo " Defaults are to source the image from pixabay and output to "
    echo " out.jpg in the script's directory with Interstate font."
    echo " ## TOGGLES:"
    echo " -b : add blur"
    echo " -r : occasionally mix in random image from internet (every third)"
    echo " -help | -? : show help text"
    echo " ## SWITCHES THAT NEED MORE INPUT AFTER THEM " 
    echo " -n ### : the number of output images to make (autonumbered)"
    echo " -d [directory] : image directory to choose from"
    echo " -i [file] : specific image file to use"
    echo " -h ### : height if sourced from pixabay"
    echo " -w ### : height if sourced from pixabay "
    echo " -o [full path] : specify output file "
    echo " -f [font family] : specify font family to use "
    echo " -c [full path] : specify config file "
    exit 0
    
}

check_fonts (){

    fontexists=""
    if [ -n "$FontFamily" ];then 
        case "$FontFamily" in  
        *\ * )
            echo " "
            echo "There is a space in your font family. Because of the way imagemagick"
            echo "and this script handle fonts, please use the *filename* of the font, by typing "
            echo "fc-list | grep -i \"$FontFamily\" and choosing the filename. "
            echo "We are now going to try to choose a random font from that family."
            echo " "
            FontFamily=$(fc-list | grep -i "$FontFamily" | grep -E ".ttf|.otf" | shuf -n 1 | awk -F ':' '{print $1}')
            fontexists=$(fc-list | grep -ci "$FontFamily")
            ;;
        *)
            fontexists=$(fc-list | grep -ci "$FontFamily")
            ;;
        esac
    fi
    if [ -z "$fontexists" ];then
        FontFamily="Interstate"
        fontexists=$(fc-list | grep -ci "$FontFamily")
        if [ -z "$fontexists" ];then
            FontFamily="Ubuntu"
            fontexists=$(fc-list | grep -ci "$FontFamily")
            if [ -z "$fontexists" ];then
                FontFamily="Arial"
                fontexists=$(fc-list | grep -ci "$FontFamily")
                
                # I've tried what was given with no dice, so I'm picking one at random
                if [ -z "$fontexists" ];then
                    FontFamily=$(fc-list | shuf -n 1 | awk -F ':' '{ print $2 }' | awk '{$1=$1;print}')
                fi
            fi
        fi
    fi
    echo "Using font $FontFamily."
}

while [ $# -gt 0 ]; do
option="$1"
    case $option
    in
        -c) 
            ExplicitConfigFilePath="$2"
            if [ ! -f "${ExplicitConfigFilePath}" ];then
                ExplicitConfigFilePath=""
            fi
            shift
            shift ;;
        -f)           
            FontFamily="$2"
            shift
            shift;;
        -r) 
            OccasionalRandom=true
            shift ;;
        -b) 
            BlurVar="True"
            shift ;;
        -n) 
            NumOutput="$2"
            shift
            shift;;
        -d) 
            ImageDir="$2"
            if [ ! -d "${ImageDir}" ];then
                ImageFile=""
            else
                get_image
                if [ ! -f "${ImageFile}" ];then
                    ImageFile=""
                fi
            fi
            shift
            shift ;;
        -i) 
            ImageFile="$2"
            if [ ! -f "${ImageFile}" ];then
                ImageFile=""
            fi
            shift
            shift ;;
        -w) 
            UnsplashWidth="$2"
            shift
            shift ;;  
        "-?"|"-help") 
            print_help
            ;;
        -h) 
            UnsplashHeight="$2"
            if [ -z "$UnsplashHeight" ];then
                print_help
            fi
            shift
            shift ;;
        -o)
            OutputFile="$2"
            shift
            shift ;;
    esac
done

if [ -z "${UnsplashHeight}" ];then
    UnsplashHeight="1080"
fi
if [ -z "${UnsplashWidth}" ];then
    UnsplashWidth="1920"
fi

check_fonts

################################################################################
# Wherein things get told to happen
################################################################################
main() {
    
    LOOP=$(printf "%03g" "$1")
    ForcePull="$2"
    if [ -z "$ImageFile" ];then 
        if [ -n "$ForcePull" ];then
            ImageFile=""
        else
            get_image
        fi
    fi
	if [ -z "${ImageFile}" ];then
        wget_bin=$(which wget)
        # Obtain source image
        execstring="${wget_bin} https://picsum.photos/${UnsplashWidth}/${UnsplashHeight}/?random -qO ${TempDir}/unsplash.jpg"
        eval "$execstring"
	else
        cp "${ImageFile}" "${TempDir}"/unsplash.jpg
    fi
    
    if [ -n "$BlurVar" ];then
        # Blur, if desired. 
        convert "${TempDir}"/unsplash.jpg -blur 0x4 "${TempDir}"/unsplash_blur.jpg
    else
        cp "${TempDir}"/unsplash.jpg "${TempDir}"/unsplash_blur.jpg
    fi
    
    ImageSize=$(identify "${TempDir}"/unsplash_blur.jpg  | awk '{print $3}')
    ImageWidth=$(echo "${ImageSize}" | awk -F 'x' '{print $1}')
    ImageHeight=$(echo "${ImageSize}" | awk -F 'x' '{print $2}')
    # because otherwise the text gets squashed
    if [ "$ImageWidth" -le 1366 ];then
        TextWidth=$(( "$ImageWidth" / 3 ))
        TextWidth=$(( "$TextWidth" * 2 ))
    else
        TextWidth=$(( "$ImageWidth" / 2 ))
    fi
    TextHeight=$(( "$ImageHeight" / 2 ))
    
    
    
    # Get our text and make it into an image
    if [ -n "$ExplicitConfigFilePath" ];then
        DataInfo=$("${SCRIPT_DIR}"/weather_image_helper.sh -r "$ExplicitConfigFilePath" | grep -v "Cache")
    else
        DataInfo=$("${SCRIPT_DIR}"/weather_image_helper.sh | grep -v "Cache")
    fi
    # Sometimes it feeds us two icons worth of data; take the first.
    IconData=$(echo "$DataInfo" | awk '{print $1}' | head -1)
    TextData=$(echo "$DataInfo" | tail -6)
    cp "${SCRIPT_DIR}"/icons/"$IconData".png "${TempDir}"/WeatherIcon.png
	/usr/bin/convert -background none -fill white -stroke black -strokewidth 2 -gravity Southeast -font "${FontFamily}" -size "$TextWidth"x"$TextHeight" \
          caption:"$TextData" \
          -gravity Southwest \
          "${TempDir}"/TextImage.png

    # Applying the appropriate icon to the image.  This has to be done in 
    # steps for the transparency to keep working.
    /usr/bin/composite -gravity Center "${TempDir}"/WeatherIcon.png -gravity Southwest "${TempDir}"/TextImage.png "${TempDir}"/Text_Icon.png
   
   # Applying the text and icon to the base image.
    /usr/bin/composite -gravity Southeast "${TempDir}"/Text_Icon.png "${TempDir}"/unsplash_blur.jpg "${TempDir}"/weather.jpg
    if [ -z "${OutputFile}" ]; then
        cp "${TempDir}"/weather.jpg "${SCRIPT_DIR}"/output_"${LOOP}".jpg
    else
        if [ "$NumOutput" = 1 ];then
            cp "${TempDir}"/weather.jpg "${OutputFile}"
        else
            OutExt="${OutputFile##*.}"
            Out_File="${OutputFile%.*}"
            cp "${TempDir}"/weather.jpg "${Out_File}"_"${LOOP}"."${OutExt}"
        fi
    fi
    ImageFile=""

}

################################### CONTROL PORTION ##########################

    n=0
    NumOutput=$(( "$NumOutput" ))
    while [ $n -lt "$NumOutput" ]; do
        if [ "$OccasionalRandom" = "true" ] && [ $n -ne 0 ];then
            RandoRun=""
            if ! (( "$n" % 3 )) ; then
                # forcing random pull
                RandoRun="true"
                ImageFile=""
            fi
        fi
        printf "%s" "#"
        main $n $RandoRun
        n=$(( n+1 ))
    done
    printf "\n"

rm "${TempDir}"/TextImage.png
rm "${TempDir}"/unsplash_blur.jpg
rm "${TempDir}"/unsplash.jpg
rm "${TempDir}"/WeatherIcon.png
rm -rf "${TempDir}"
