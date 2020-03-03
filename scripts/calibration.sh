#!/bin/bash

# Script to change the generated calibration tif files to 
# properly scaled files that is a lossless png. The resulting
# file should be massively smaller--100's of MBs to KBs.

#Requires ImageMagick

#Printer DPI
DPI=1440
#Location of calibration files
CALIBRATION_FILES="../filmless_calibration/*.tif"

echo "Changing calibration files to ${DPI}dpi and converting to .png..."

for f in $CALIBRATION_FILES
do
	name=$(basename "$f" .tif)
	#echo $name
	echo "Converting $f -> ../filmless_calibration/${name}.png @ ${DPI}dpi..."
	convert $f -units PixelsPerInch -density $DPI "../filmless_calibration/${name}.png"
	rm $f
done
