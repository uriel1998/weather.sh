# weather.sh and forecast.sh

A bash script to get the weather and forecast from OpenWeatherMap and output 
to the terminal, Openbox, or HTML 

Additionally, a way to put that information onto an image (see the `weather_image` subdirectory).

![Output example](https://raw.githubusercontent.com/uriel1998/weather.sh/master/example_output.png "Example output")

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [How to use](#4-how-to-use)
 5. [weather_image](#5-weather_image)
 6. [TODO](#6-todo)

***

## 1. About

Weather report written in Bash.

`weather.sh` gets the current weather from 
[OpenWeatherMap](http://openweathermap.org/) and displays the 
results to the terminal, HTML, or for an OpenBox pipe menu. It will 
calculate (if appropriate) the "feel like" weather by calculating the
wind chill or heat index. A great deal of basis for this script comes 
from [BashWeather](https://github.com/jdotjdot/BashWeather),
[bash-weather](https://github.com/szantaii/bash-weather),
and many more that I forgot to save the URLs of.

`forecast.sh` gets the forecast from [OpenWeatherMap](http://openweathermap.org/) 
and likewise displays the results. OpenWeatherMap forecasts are at three hour 
intervals (0800, 1100, 1400, etc). It displays all forecasts for the next 
twenty four hours, then displays the closest time forecast for the day after 
that. For example, if it's 1136 (as I'm writing this) it shows all forecasts 
through the 1100 forecast the next day, then the 1100 forecast for each 
subsequent day. Options and `.rc` file are *the same* as for `weather.sh`.

If you wish to show both together, simply execute:

`weather.sh && forecast.sh` 

## 2. License

This project is licensed under the MIT license. For the full license, see `LICENSE`.

## 3. Prerequisites

 * OpenWeatherMap API key ([http://openweathermap.org/appid](http://openweathermap.org/appid)).
 * Bash shell ≥ 4.2.
 * `bc` basic calculator for floating point arithmetic. Can be found in the 
 `bc` package on major Linux distributions.
 * `curl` command-line tool for getting data using HTTP protocol. cURL can be 
 found in the `curl` package on major Linux distributions.
 * `grep` command-line tool used for parsing downloaded XML data. `grep` can 
 be found in the `grep` package on major Linux distributions.
 * `jq` command-line tool for parsing JSON data. `jq` can be found in the `jq` 
 package on major Linux distributions.
 * `tr` command-line tool for parsing JSON data. `tr` can be found in the `tr` 
 package on major Linux distributions.
 * `awk` command-line tool for parsing JSON data. `awk` can be found in the 
 `awk` package on major Linux distributions. 

Optional: For colors in terminal, save `bashcolors` in this repository to 
`.bashcolors` in your `$HOME` directory.

## 4. How to use

Run `weather.sh` or `forecast.sh` with the appropriate commandline switches 
(below). If  the current conditions do not qualify for the heat index or wind 
chill, it is not displayed.

### weather_sh.rc

Copy (and edit, as appropriate) the `weather_sh.rc` file to `$HOME\.config\weather_sh.rc`.   
* The first line is the OpenWeatherMap API key  
* The second line is your default location. (See note below)  
* The third line is your default degree character (either `c` or `f`)  
* The fourth line is True or False depending on whether or not you want icons displayed for the weather.
* The fifth line is whether to use `bashcolors`.

### Command-line options

`weather.sh` and `forecast.sh` can be started with the following command line 
options:

 * `-k` Specifies OpenWeatherMap API key from the command-line.
 * `-l city_name` Sets the city for manual weather lookup. (see note below)
 * `-t` Output to the terminal/stdout (default if no output is specified)
 * `-h` Output HTML formatted text
 * `-o` Output OpenBox output
 * `-y` Output Conky format (no icons)
 * `-n` Terminal output without icons
 * `-p` Specify cache/temp path *with* trailing slash
 * `-f` Use imperial (farenheit, inches Hg, mph) units; default is metric
 * `-c` Use colored output in the terminal if `.bashcolors` is in the home 
 dir. Note that if you want to alter the colors, you will have to manually
 alter the script.
 
_Note: If the OpenWeatherMap API key is specified from the command-line, it 
will override the API key set in the file._

_Note: It is **STRONGLY** recommended to use the City ID from OpenWeatherMap 
instead of a city name. Instructions on finding your city's City ID 
[here](https://www.dmopress.com/openweathermap-howto/) ._


### Calling from Conky

I have a single line config for my secondary screen with the weather config 
in it:

`Now: ${execi 300 weather.sh -y} Forecast: ${execi 300 forecast.sh -y}`

The conky output is currently limited via code to just the next five outputs.

## 5. weather_image

Please see the [weather_image](https://github.com/uriel1998/weather.sh/tree/master/weather_image) subdirectory.

## 6. Todo

 * Add in sunrise/sunset
 * HTML colored output
 * Current location instead of hardcoded 
    - this is problematic due to the way the API looks up city names.
