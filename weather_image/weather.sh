#!/bin/bash

# TODO: Add in sunrise/sunset calcuations

apiKey=""
defaultLocation=""
degreeCharacter="c"
data=0
lastUpdateTime=0
FeelsLike=0
dynamicUpdates=0
UseIcons="True"
colors="False"
CityID="True"
icondata=""

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
ConfigFile="$HOME/.config/weather_sh.rc"

if [ "$1" == "-r" ];then
    shift
    ConfigFile="$1"
    shift
fi

if [ -f "$ConfigFile" ];then
    readarray -t line < "$ConfigFile"
    apiKey=${line[0]}
    defaultLocation=${line[1]}
    degreeCharacter=${line[2]}
    UseIcons=${line[3]}
    temp=${line[4]}
    if [ "$temp" = "True" ];then
        if [ -f "$HOME/.bashcolors" ];then
            source "$HOME/.bashcolors"
            colors="True"
        else
            colors=""
        fi
    else
        colors=""
    fi
fi

while [ $# -gt 0 ]; do
option="$1"
    case $option
    in
    -k) apiKey="$2"
    shift
    shift ;;
    -l) defaultLocation="$2"
    shift
    shift ;;
    -d) dynamicUpdates=1
    shift ;;
    -f) degreeCharacter="f"
    shift ;;
    -p) CachePath="$2"
    shift
    shift ;;
    -n) UseIcons="False"
    shift ;;
    -c) 
        if [ -f "$HOME/.bashcolors" ];then
            source "$HOME/.bashcolors"
            colors="True"
        fi
    shift ;;
    esac
done

if [ -z "${CachePath}" ];then 
    dataPath="/tmp/wth-$defaultLocation.json"
else
    dataPath="${CachePath}/wth-$defaultLocation.json"
fi

if [ -z $apiKey ];then
    echo "No API Key specified in rc, script, or command line."
    exit
fi

#Is it City ID or a string?
case $defaultLocation in
    ''|*[!0-9]*) CityID="False" ;;
    *) CityID="True" ;;
esac

if [ ! -e $dataPath ];
then
    touch $dataPath
    #The API call is different if city ID is used instead of string lookup
    if [ "$CityID" = "True" ];then
        data=$(curl "http://api.openweathermap.org/data/2.5/weather?id=$defaultLocation&units=metric&appid=$apiKey" -s )
    else
        data=$(curl "http://api.openweathermap.org/data/2.5/weather?q=$defaultLocation&units=metric&appid=$apiKey" -s )
    fi
    echo $data > $dataPath
else
    data=$(cat $dataPath)
fi
lastUpdateTime=$(($(date +%s) -600))

while true; do
    lastfileupdate=$(date -r $dataPath +%s)
    if [ $(($(date +%s)-$lastfileupdate)) -ge 600 ];then
        if [ "$CityID" = "True" ];then
            data=$(curl "http://api.openweathermap.org/data/2.5/weather?id=$defaultLocation&units=metric&appid=$apiKey" -s )
        else
            data=$(curl "http://api.openweathermap.org/data/2.5/weather?q=$defaultLocation&units=metric&appid=$apiKey" -s )
        fi
        echo $data > $dataPath
    else
        if [ "$Conky" != "True" ];then 
            echo "Cache age: $(($(date +%s)-$lastfileupdate)) seconds."
        fi
    fi
    check=$(echo "$data" | grep -c -e '"cod":"40')
    check2=$(echo "$data" | grep -c -e '"cod":"30')
    sum=$(( $check + $check2 ))
    if [ $sum -gt 0 ];then
        exit 99
    fi
    if [ $(($(date +%s)-$lastUpdateTime)) -ge 600 ]; then
        lastUpdateTime=$(date +%s)
        Station=$(echo $data | jq -r .name)
        Lat=$(echo $data | jq -r .coord.lat)
        Long=$(echo $data | jq -r .coord.lon)
        Country=$(echo $data | jq -r .sys.country)

        ####################################################################
        # Current conditions (and icon)
        ####################################################################

            icons=$(echo $data | jq -r .weather[].icon | tr '\n' ' ')
            iconval=${icons%?}
            case $iconval in
                01*) icon="☀️";;
                02*) icon="🌤";;
                03*) icon="🌥";;
                04*) icon="☁";;
                09*) icon="🌧";;
                10*) icon="🌦";;
                11*) icon="🌩";;
                13*) icon="🌨";;
                50*) icon="🌫";;
            esac
        ShortWeather=$(echo $data | jq -r .weather[].main | tr '\n' ' '| awk '{$1=$1};1' )
        LongWeather=$(echo $data | jq -r .weather[].description | sed -E 's/\S+/\u&/g' | tr '\n' ' '| awk '{$1=$1};1' )

        ####################################################################
        # Temperature
        ####################################################################
        tempinc=$(echo $data | jq -r .main.temp| awk '{$1=$1};1' )   
        RawTemp=$(echo $data | jq -r .main.temp| awk '{$1=$1};1' )
        temperature=$tempinc
        if  [ "$degreeCharacter" = "f" ]; then
            temperature=$(echo "scale=2; 32+1.8*$tempinc" | bc| awk '{$1=$1};1' )
        fi
        
        ####################################################################
        # Parse Wind Info
        ####################################################################
        wind=$(echo $data | jq .wind.deg)
        winddir=$((2193-(${wind%.*}+45)/90))
        if [ $winddir -eq 2192 ]; then
            winddir=2190
        elif [ $winddir -eq 2190 ];then
            winddir=2192
        else
            :
        fi
        RawWindSpeed=$(echo $data | jq .wind.speed)
        WindSpeed=$(echo $data | jq .wind.speed)
        WindGusts=$(echo $data | jq .wind.gust)
        
        #Conversion
        if  [ "$degreeCharacter" = "f" ]; then
            WindSpeed=$(echo "scale=2; $WindSpeed*0.6213712" | bc | xargs printf "%.2f"| awk '{$1=$1};1' )
            WindGusts=$(echo "scale=2; $WindGusts*0.6213712" | bc | xargs printf "%.2f"| awk '{$1=$1};1' )
            windunit="mph"
        else
            WindGusts=$(echo "scale=2; $WindGusts*1" | bc| awk '{$1=$1};1' )
            windunit="kph"
        fi        

        Humidity=$(echo $data | jq .main.humidity| awk '{$1=$1};1' )
        CloudCover=$(echo $data | jq .clouds.all| awk '{$1=$1};1' )

        ####################################################################
        # Feels Like Calculations
        # Using the raw metric value for criteria, then converting later
        ####################################################################
        # Wind Chill
        ####################################################################
        if (( $(bc -l<<<"$RawWindSpeed > 4.5") )); then #windspeed criteria for windchill
            if (( $(bc -l<<<"$RawTemp< 11") )); then #temp criteria for windchill
                FeelsLike=1
                if [ "degreeCharacter" = "f" ];then
                    WindSpeedExp=$(echo "e(0.16*l($WindSpeed))" | bc -l )
                    FeelsLikeTemp=$(echo "scale=2; 35.74 + 0.6215*$temperature - 35.75*$WindSpeedExp + 0.4275*$temperature*$WindSpeedExp" | bc | xargs printf "%.2f"| awk '{$1=$1};1' )
                else
                    WindSpeedExp=$(echo "e(0.16*l($WindSpeed))" | bc -l )
                    FeelsLikeTemp=$(echo "scale=2; 13.12 + 0.6215*$temperature - 11.37*$WindSpeedExp + 0.3965*$temperature*$WindSpeedExp" | bc | xargs printf "%.2f"| awk '{$1=$1};1' )
                fi
            fi
        fi

        ####################################################################
        # Heat Index
        # I can only find Farenheit calcuations, so....
        ####################################################################
        if  [ "$degreeCharacter" = "c" ]; then
            HITemp=$(echo "scale=2; 32+1.8*$tempinc" | bc)
        else
            HITemp=$RawTemp
        fi
        if (( $(bc -l<<<"$HITemp> 79") )); then #temp criteria for heat index
            FeelsLike=1
            FeelsLikeTemp=$(echo "scale=2;0.5 * ($HITemp + 61.0 + (($HITemp-68.0)*1.2) + ($Humidity*0.094))" | bc| awk '{$1=$1};1' )
            if [ "$degreeCharacter" = "c" ];then
                FeelsLikeTemp=$(echo "scale=2; ($FeelsLikeTemp-32) / 1.8" | bc| awk '{$1=$1};1' )

            fi
        fi

        ####################################################################
        # Pressure Data
        ####################################################################
        pressure=$(echo $data | jq .main.pressure)
        if  [ "$degreeCharacter" = "f" ]; then
            pressure=$(echo "scale=2; $pressure/33.863886666667" | bc | awk '{$1=$1};1' )
            pressureunit="in"
        else
            pressureunit="hPa"
        fi
    fi
    #AsOf=$(date +"%Y-%m-%d %R" -d @$lastfileupdate) 
    echo "${iconval}"
    NowTime=$(date +"%H:%M")
    echo "${LongWeather} at ${NowTime}"
    
    if [ "$FeelsLike" = "1" ];then
        echo "$temperature deg ${degreeCharacter^^}, Feels $FeelsLikeTemp deg ${degreeCharacter^^}"
    else
        echo "Temp: $temperature deg ${degreeCharacter^^}"
    fi
    echo "Pressure: $pressure$pressureunit"
    echo "$WindSpeed$windunit ($WindGusts$windunit)"
    echo "Humidity: $Humidity%"
    echo "Cloud Cover: $CloudCover%"  
    if [ $dynamicUpdates -eq 0 ];then
        break
    fi    
done
