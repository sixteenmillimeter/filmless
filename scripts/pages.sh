#!/bin/bash

# Script to properly scale generated page_#.tif files
# to your desired DPI.

#Requires ImageMagick

#Printer DPI, same as in filmless_processing.pde
DPI=1440
#Location of generated pages
PAGE_FILES="~/Desktop/page_*.tif"

echo "Changing exported page files to ${DPI}dpi..."

for f in $PAGE_FILES
do
	echo "Converting ${f} to ${DPI}dpi..."
	mogrify $f -units PixelsPerInch -density $DPI
done