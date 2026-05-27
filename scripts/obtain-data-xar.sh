#!/usr/bin/env bash

# URL of the WeGA data at Zenodo
DATA_LOCATION=https://zenodo.org/records/13759841/files/WeGA-data-4.11.0.zip

# filename including file suffix
FILENAME=$(basename $DATA_LOCATION)

# location of the current script
# all relative paths to other files are based on this location
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

CUR_DIR=$(pwd)

# download zip archive from Zenodo to current directory
curl -LO $DATA_LOCATION

# delete unnecessary content
zip --delete $FILENAME \
  "addenda/*" \
  "biblio/*" \
  "diaries/*" \
  "documents/*" \
  "news/*" \
  "thematicCommentaries/*" \
  "var/*" \
  "writings/*"

# add files to the root directory of the zip archive
zip -uj $FILENAME \
  $SCRIPT_DIR/../expath-package-files/expath-pkg.xml \
  $SCRIPT_DIR/../expath-package-files/repo.xml \
  $SCRIPT_DIR/../expath-package-files/WeGA-data-pre-install.xql

# (recursively) add indices directory to the zip archive
(cd $SCRIPT_DIR/../expath-package-files && zip -ru $CUR_DIR/$FILENAME indices)

# change file suffix to ".xar"
mv $FILENAME $(basename $DATA_LOCATION .zip).xar
