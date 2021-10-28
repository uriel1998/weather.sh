# weather_image.sh 

Uses a compatible variant of [weather.sh](https://uriel1998.github.io/weather.sh/) in order to create an image suitable 
for backgrounds and screensavers with the time and weather embedded in it.

![Output example](https://raw.githubusercontent.com/uriel1998/weather.sh/master/example_output.png "Example output")

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [How to use](#4-how-to-use)
 5. [TODO](#5-todo)

***

## 1. About

I have several applications that show screensavers of images, optionally from a 
directory.  Which is great.  But that doesn't have things like the time or 
current weather on them.

The ones I'd seen *with* that functionality had a tendency to crash after a 
couple of hours.  

So building off the weather.sh script, I've hacked together a script that will 
embed the data onto a single image or a series of images.  After configuring 
your screensaver (or whatever) to source images from a specific directory,

![Configure Xscreensaver Example]( "Example of configuring Xscreensaver")

then you run `weather_image.sh` so that it outputs images to that directory 
every so often (like, uh, once a minute) and overwrites the older ones.  You 
can source *your* images from a directory, a single file, or have it pull 
random images from [pixabay](pixabay.com).  This program uses the cached data
from `weather.sh` to minimize API calls if you're running both.

## 2. License

This project is licensed under the MIT license. For the full license, see `LICENSE`.

## 3. Prerequisites

 * All the prereqs for [weather.sh](https://uriel1998.github.io/weather.sh/), as well as...
 * `shuf` to shuffle output. Can be found in the `coreutils` package on major 
 Linux distributions.  
 * `imagemagick` image manipulation. Can be found in the `imagemagick-*` 
 package on major Linux distributions.  
 * `wget` command-line tool for getting data using HTTP protocol. cURL can be 
 found in the `wget` package on major Linux distributions.  
 * An appropriate font.

## 4. How to use

Run `weather_images.sh` or `forecast.sh` with the appropriate commandline 
switches (below). 

### weather_sh.rc

If you already have a working installation of [weather.sh](https://uriel1998.github.io/weather.sh/), 
then you can skip this section.

Copy (and edit, as appropriate) the `weather_sh.rc` file to `$HOME\.config\weather_sh.rc`.   
* The first line is the OpenWeatherMap API key  
* The second line is your default location. (See note below)  
* The third line is your default degree character (either `c` or `f`)  
* The fourth line is True or False depending on whether or not you want icons displayed for the weather.

### Command-line options

By default, `weather_image.sh` :

* sources all images from pixabay 
* outputs file(s) to `out.jpg` in the *script directory*.
* attempts to use the following fonts, in this order: [Interstate](https://dafontfamily.com/interstate-font-free-download/), [Ubuntu](https://www.1001freefonts.com/ubuntu.font), and [Arial](https://www.cufonfonts.com/font/arial).

Please note that while `weather_image.sh` will do its best to find an appropriate 
size and placement for the icon, some font families will work better than others. 

`weather_image.sh` can be started with the following command line 
options:

 * `-b` : add blur  
 * `-r` : occasionally mix in random image from pixabay (hardcoded to every third for now) 
 * `-help` or `-?` : show help text
 * `-n ###` : the number of output images to make (autonumbered)
 * `-d [directory]` : image directory to choose from
 * `-i [file]` : specific image file to use
 * `-h ###` : height if sourced from pixabay
 * `-w ###` : height if sourced from pixabay 
 * `-o [full path]` : specify output file 
 * `-f [font family name]` : specify font family to use
 
## 5. Todo

 * Options for how often images are sourced from the internet
 * Variable for font, perhaps?  It's on line 157...
