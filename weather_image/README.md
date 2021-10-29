# weather_image.sh 

Uses a compatible variant of [weather.sh](https://uriel1998.github.io/weather.sh/) in order to create an image suitable 
for backgrounds and screensavers with the time and weather embedded in it.

![Output example](https://github.com/uriel1998/weather.sh/raw/master/weather_image/ubuntu_font.jpg "Example output")

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [How to use](#4-how-to-use)
 5. [TODO](#5-todo)
 6. [Screenshots](#6-screenshots)

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

![Configure Xscreensaver Example](https://github.com/uriel1998/weather.sh/raw/master/weather_image/xscreensaver_setup.png "Example of configuring Xscreensaver")

then you run `weather_image.sh` so that it outputs images to that directory 
every so often (like, uh, once a minute) and overwrites the older ones.  You 
can source *your* images from a directory, a single file, or have it pull 
random images from [pixabay](pixabay.com).  This program uses the cached data
from `weather.sh` to minimize API calls if you're running both.

## 2. License

This project's *code* and *documentation* is licensed under the MIT license. For the full license, see `LICENSE`.

The *artwork* in the `icons` subdirectory is from the (free for commercial use) 
[Weather Color icon set by Sihan Liu](https://www.iconfinder.com/iconsets/weather-color-2).  

## 3. Prerequisites

 * All the prereqs for [weather.sh](https://uriel1998.github.io/weather.sh/), as well as...
 * `shuf` to shuffle output. Can be found in the `coreutils` package on major 
 Linux distributions.  
 * `imagemagick` image manipulation. Can be found in the `imagemagick-*` 
 package on major Linux distributions.  
 * `wget` command-line tool for getting data using HTTP protocol. Can be 
 found in the `wget` package on major Linux distributions.  
 * `fc-list` command-line tool for listing fonts on the system. `fc-list` can be 
 found in the `fontconfig` package on major Linux distributions.  
 * `find` command-line tool for finding files on the system. `find` can be 
 found in the `findutils` package on major Linux distributions.  
 * OPTIONAL: `fd-find` as a drop-in for `find`.  `fd-find` can be found in the 
 `fd-find` package on major Linux distributions.  This program looks for the 
 binary to be named `fdfind`, *not* `fd` (Debian style).
 * An appropriate font.  
 
## 4. How to use

Once installed, run `weather_images.sh` with the appropriate commandline 
switches (below). 

### Installation

Clone the repository locally from the main directory.  If you do not wish to clone the whole repository, 
go to the directory you wish to clone into, and perform the following (solution from 
[here](https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository):

```
    git clone --depth 1 --filter=blob:none --sparse https://github.com/uriel1998/weather.sh 
    cd weather.sh
    git sparse-checkout set weather_image

```

Set up `weather_sh.rc`

### weather_sh.rc

If you already have a working installation of [weather.sh](https://uriel1998.github.io/weather.sh/), 
then you can skip to "Command-line options".

Copy (and edit, as appropriate) the `weather_sh.rc` file to `$HOME\.config\weather_sh.rc`.   
* The first line is the OpenWeatherMap API key  
* The second line is your default location. (See note below)  
* The third line is your default degree character (either `c` or `f`)  
* The fourth line is True or False depending on whether or not you want icons displayed for the weather.
* The fifth line has no effect with `weather_image.sh`, only for `weather.sh`.


### Command-line options

By default, `weather_image.sh` :

* sources all images from pixabay 
* outputs file(s) to `out.jpg` in the *script directory*.
* attempts to use the following fonts, in this order: [Interstate](https://dafontfamily.com/interstate-font-free-download/), [Ubuntu](https://www.1001freefonts.com/ubuntu.font), and [Arial](https://www.cufonfonts.com/font/arial).

See below for information about customizing fonts and/or iconsets.

`weather_image.sh` can be started with the following command line 
options:

 * `-b` : add blur  
 * `-r` : occasionally mix in random image from pixabay (hardcoded to every third for now) 
 * `-help` or `-?` : show help text
 * `-n ###` : the number of output images to make (autonumbered). 
 * `-d [directory]` : image directory to choose from
 * `-i [file]` : specific image file to use
 * `-h ###` : height if sourced from pixabay
 * `-w ###` : height if sourced from pixabay 
 * `-o [full path]` : specify output file 
 * `-f [font family name]` : specify font family to use
 * `-c [full path to config file]` : specify config file (useful for crontab, etc)

### Customization

#### Icon Sets

You can substitute in any images in PNG format, they just need to be located 
and named the same as the ones in the `icons` subdirectory.  

#### Fonts

**IMPORTANT**  
If it cannot find the font you chose or any of the three default fonts, it will 
choose a RANDOM font using `fc-list`.  

**IMPORTANT**  
If you choose a font family with a space in the name, it will choose a random 
font *from that family*, along with the following warning:

```
There is a space in your font family. Because of the way imagemagick
handles fonts, please use the *filename* of the font, by typing 
fc-list | grep -i "Font Family" and choosing the filename as displayed. 
We are now going to try to choose a random font from that family.

```

This is probably a limitation based on my coding skill; pull requests welcomed.

You can see examples of these three default fonts at the bottom of the page.

Please note that while `weather_image.sh` will do its best to find an appropriate 
size and placement for the text and icon, some font families will work better than others. 
 
### Examples
 
`./weather_image.sh -f Abydos -n 3 -r -b -d /home/steven/my_images -o /home/steven/out.jpg`

Results in three images in my home directory, named `out_001.jpg`, `out_002.jpg`, 
and `out_003.jpg` using the Abydos font on my system, pulling images from 
`/home/steven/my_images`, and every third image being pulled from pixabay, and 
applying a blur effect to all background images.  

`./weather_image.sh -f /usr/share/fonts/truetype/noto/NotoSerif-Black.ttf -o /home/steven/out.jpg`

Results in one image in my home directory, named `out.jpg`, using the Noto Serif 
Black font, and pulling the source image from pixabay with no blur effect.

If your commandline gets a bit long, you may wish to use a wrapper script instead, 
particularly if you choose to use [systemd timers](https://fedoramagazine.org/systemd-timers-for-scheduling-tasks/)  instead of cron.

 
## 5. Todo

 * Options for how often images are sourced from the internet

## 6. Screenshots

![Interstate](https://github.com/uriel1998/weather.sh/raw/master/weather_image/interstate_font.jpg "Example Interstate font output")  

![Ubuntu](https://github.com/uriel1998/weather.sh/raw/master/weather_image/ubuntu_font.jpg "Example Ubuntu font output")  

![Arial](https://github.com/uriel1998/weather.sh/raw/master/weather_image/arial_font.jpg "Example Arial font output")  
