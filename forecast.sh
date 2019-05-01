#!/bin/bash

# TODO: Add in sunrise/sunset calcuations

########################################################################
# Setting Defaults
########################################################################

apiKey=""
defaultLocation=""
OpenBox="False"
Terminal="False"
HTML="False"
degreeCharacter="c"
data=0
lastUpdateTime=0
FeelsLike=0
dynamicUpdates=0
UseIcons="True"

########################################################################
# Reading in rc 
########################################################################

if [ -f "$HOME/.config/weather_sh.rc" ];then
    readarray -t line < "$HOME/.config/weather_sh.rc"
    apiKey=${line[0]}
    defaultLocation=${line[1]}
    degreeCharacter=${line[2]}
    UseIcons=${line[3]}
fi

########################################################################
# Reading in options
########################################################################

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
    -t) Terminal="True"
    shift ;;
    -h) HTML="True"
    shift ;;
    -o) OpenBox="True"
    shift ;;    
    -f) degreeCharacter="f"
    shift ;;
    esac
done

if [ -z $apiKey ];then
    echo "No API Key specified in rc, script, or command line."
    exit
fi

########################################################################
# Do we need a new datafile? If so, get it.
########################################################################

dataPath="/tmp/fore-$defaultLocation.json"
if [ ! -e $dataPath ];then
    touch $dataPath
    data=$(curl "http://api.openweathermap.org/data/2.5/forecast?q=$defaultLocation&units=metric&appid=$apiKey")
    echo $data > $dataPath
else
    data=$(cat $dataPath)
fi

lastUpdateTime=$(($(date +%s) -600))

while true; do
    lastfileupdate=$(date -r $dataPath +%s)
    if [ $(($(date +%s)-$lastfileupdate)) -ge 600 ];then
        data=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?q=$defaultLocation&units=metric&appid=$apiKey")
        echo $data > $dataPath
    fi
    if [ $(($(date +%s)-$lastUpdateTime)) -ge 600 ]; then
        lastUpdateTime=$(date +%s)
        

        ########################################################################
        # Location Data
        ########################################################################
        Station=$(echo $data | jq -r .city.name)
        #Lat=$(echo $data | jq -r .coord.lat)
        #Long=$(echo $data | jq -r .coord.lon)
        #Country=$(echo $data | jq -r .sys.country)
        NumEntries=$(echo $data |jq -r .cnt)
        let i=0
       
        while [ $i -lt $NumEntries ]; do 
            # Get the date...unix format
            NixDate[$i]=$(echo $data | jq -r  .list[$i].dt  | tr '\n' ' ')
            ####################################################################
            # Current conditions (and icon)
            ####################################################################
            if [ "$UseIcons" = "True" ];then
                icons[$i]=$(echo $data | jq -r .list[$i].weather[] | jq -r .icon | tr '\n' ' ')
                iconval=${icons[$i]%?}
                case $iconval in
                    01*) icon[$i]="☀️";;
                    02*) icon[$i]="🌤";;
                    03*) icon[$i]="🌥";;
                    04*) icon[$i]="☁";;
                    09*) icon[$i]="🌧";;
                    10*) icon[$i]="🌦";;
                    11*) icon[$i]="🌩";;
                    13*) icon[$i]="🌨";;
                    50*) icon[$i]="🌫";;
                esac
            else
                icon[$i]=""
            fi
            ShortWeather[$i]=$(echo $data | jq -r .list[$i].weather[] | jq -r .main | tr '\n' ' '| awk '{$1=$1};1' )
            LongWeather[$i]=$(echo $data | jq -r .list[$i].weather[] | jq -r .description | sed -E 's/\S+/\u&/g' | tr '\n' ' '| awk '{$1=$1};1' )
            Humidity[$i]=$(echo $data | jq -r .list[$i].main.humidity | tr '\n' ' '| awk '{$1=$1};1' )
            CloudCover[$i]=$(echo $data | jq -r .list[$i].clouds.all | tr '\n' ' '| awk '{$1=$1};1' )

            ####################################################################
            # Parse Wind Info
            ####################################################################
            WindSpeed[$i]=$(echo $data | jq -r .list[$i].wind.speed | tr '\n' ' ' | awk '{$1=$1};1' )

            #Conversion
            if  [ "$degreeCharacter" = "f" ]; then
                WindSpeed[$i]=$(echo "scale=2; ${WindSpeed[$i]}*0.6213712" | bc | xargs printf "%.2f" | awk '{$1=$1};1' )
                windunit="mph"
            else
                windunit="kph"
            fi        

            ####################################################################
            # Temperature
            ####################################################################
            tempinc[$i]=$(echo $data | jq -r .list[$i].main.temp | tr '\n' ' ')
            temperature[$i]=$tempinc[$i]
            if  [ "$degreeCharacter" = "f" ]; then
                temperature[$i]=$(echo "scale=2; 32+1.8*${tempinc[$i]}" | bc)
            fi
            i=$((i + 1))
        done
    fi


    AsOf=$(date +"%Y-%m-%d %R" -d @$lastfileupdate) 
        #echo "Station: $Station, $Country $Lat / $Long"
        echo "As Of: $AsOf "  
        let i=0
        while [ $i -lt 40 ]; do 
            #echo "$i $NumEntries"
            ShortDate=$(date +"%m/%d@%R" -d @${NixDate[$i]})
            printf "%-12s %-2s%-20s %-15s %-14s %-14s %-14s\n" "$ShortDate:" "${icon[$i]} " "${LongWeather[$i]}" "Temp:${temperature[$i]}°${degreeCharacter^^}" "Wind:${WindSpeed[$i]}$windunit" "Humidity:${Humidity[$i]}%" "Cloud Cover:${CloudCover[$i]}%"
            
            i=$((i + 1))
        done
    if [ $dynamicUpdates -eq 0 ];then
        break
    fi    
done
