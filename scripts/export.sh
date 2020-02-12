#!/bin/bash

WITH_SOUND=true		#change to false for a silent film

#changes based on printer DPI, this is for 1440
#check the output of the calibration script
AUDIO_RATE=10296

#Either use the script by passing in a path, ie:
#sh export.sh /path/to/my/video.mov
#or hardcode it by changing VIDEO=${1} to VIDEO=/path/to/my/video.mov
VIDEO="${1}"

# change these to directory where you will store your frames and audio
FRAMES_DIR=~/Desktop/frames/
AUDIO_DIR=~/Desktop/audio/

mkdir -p "$FRAMES_DIR"
mkdir -p "$AUDIO_DIR"

echo "Exporting ${VIDEO}..."

rm "${FRAMES_DIR}*.png"
ffmpeg -y -i "${VIDEO}" -f image2 -r 24 "${FRAMES_DIR}image-%04d.png"

if [ "$WITH_SOUND" == "true" ]; then
  echo "Exporting audio from ${VIDEO}..."
  ffmpeg -y -i "${VIDEO}" -y -acodec pcm_s16le -ac 1 -ar $AUDIO_RATE -ss "$START" -t 15 "${AUDIO_DIR}audio.wav"
fi
