#!/bin/sh

FONT_FILE=/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf
RESOLUTION=2304x1536
LIGHTS_ON_THRESHOLD=10 # Percent

CWD=$(dirname $(realpath $0))
DATESTAMP=`date +%Y%m%d`
TIMESTAMP=`date +%H%M%S`
IMAGE_DIR="${CWD}/images/${DATESTAMP}"
FILENAME="${IMAGE_DIR}/image-${DATESTAMP}-${TIMESTAMP}.jpg"

mkdir -p $IMAGE_DIR

v4l2-ctl -c brightness=118,contrast=128,saturation=138,sharpness=205,white_balance_temperature_auto=1

# Get a few frames so the camera can auto adjust
ffmpeg -f v4l2 -i /dev/video0 -vframes 30 -f null -

ffmpeg \
  -f video4linux2 \
  -s $RESOLUTION \
  -i /dev/video0 \
  -vf drawtext="fontfile=${FONT_FILE}:text='%{localtime\:%Y-%m-%d %T}':x=w-tw-10:y=h-th-10:fontcolor=LightGreen:fontsize=30" \
  -vframes 1 \
  $FILENAME

IMAGE_BRIGHTNESS=`convert $FILENAME -colorspace gray -format "%[fx:100*mean]%%" info: | sed -e 's/\..*//g'`
if [ $IMAGE_BRIGHTNESS -lt $LIGHTS_ON_THRESHOLD ]; then
  rm -f $FILENAME
fi
