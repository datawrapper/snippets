# Website Colors

Take a screenshot of a website and print statistics about its colors.

https://blog.datawrapper.de/weekly-chart-website-colors/

## Prerequisites

### Mac

``` shell
$ brew install python geckodriver
```

### Arch Linux

``` shell
# pacman -S pipenv geckodriver
```

### Other systems

Install these dependencies manually:

- Python >= 3.6
- geckodriver

## Setup

Create Python virtual environment and install the requirements:

``` shell
$ python -m virtualenv .venv
$ source .venv/bin/activate
$ pip install -r requirements.txt
```

## Usage

Activate the virtual environment:

``` shell
$ source .venv/bin/activate
```

Run `website_colors.py` with the two required arguments:

- `--url` or `-u`: the website to take the screenshot of
- `--screenshot-path` or `-s`: the path to store the screenshot PNG

Example:

``` shell
$ ./website_colors.py -u https://www.datawrapper.de/ -s datawrapper.png
```

The script will then output the color statistics in CSV format to the standard
output.

Example:

``` csv
color,frequency
#a0a0a0,0.0009525772977887732
#d0d0d0,0.0003235168181169418
#707070,0.0005064201172484155
#606060,0.0005888851885331261
#505050,0.0006132018121170793
#808080,0.0013596164316940758
#c0c0c0,0.0010117829899931807
#e0e0e0,0.0005053628727447652
#000000,0.004619101236447447
#b0b0b0,0.0011809421105772025
#404040,0.09185763145513846
#f0f0f0,0.1691200025373868
```

Note that if the screenshot PNG already exists, it will be used to calculate the
statistics and no new screenshot will be made.
