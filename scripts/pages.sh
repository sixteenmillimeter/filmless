#!/bin/bash

# Script to properly scale generated page_#.tif files
# to your desired DPI.

#Requires ImageMagick

#Printer DPI, same as in filmless_processing.pde
DPI=1440
#Location of generated pages
PAGE_FILES="~/Desktop/page_*.tif"

echo "Changing calibration files to ${DPI}dpi..."

for f in $PAGE_FILES
do
	name=$(basename "$f" .tif)
	#echo $name
	echo "Converting $f..."
	mogrify $f -units PixelsPerInch -density $DPI
	rm $f
done