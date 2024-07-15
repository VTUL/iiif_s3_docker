#!/bin/bash
# Error out if any command fails
# set -e

# somehow grants access to the ruby script???
aws sts get-caller-identity
ROOT=`pwd`
# Generate random directory and enter it
mkdir -p ./tmp
echo "Creating tmpdir:"
TMPDIR=$(mktemp -d --tmpdir=$(pwd)/tmp)
echo ${TMPDIR}
# cd ${TMPDIR}
# cp -r ../../**.* .
# Create directory structure (IIIF script requires it)
echo "Creating directory structure for IIIF script: ${ACCESS_DIR}"
mkdir -p ${ACCESS_DIR}/${TMPDIR}

echo "access_dir"
cd ${ACCESS_DIR}/${TMPDIR}
pwd
ls
echo "-------------"
echo "root"
cd ${ROOT}
pwd
ls
echo "-------------"
echo "tmp_dir"
cd ${TMPDIR}
pwd
ls
echo "-------------"

cd ${ROOT}
# Generate the tiles
echo "Calling ruby script to generate tiles with the following arguments:"
echo "IIIF_TEMP: -t ${TMPDIR}"
echo "SRC_BUCKET: -s ${AWS_SRC_BUCKET}"
echo "DEST_BUCKET: -d ${AWS_DEST_BUCKET}"
echo "COLLECTION_IDENTIFIER: -c ${COLLECTION_IDENTIFIER}"
echo "CSV_PATH: -m ${CSV_PATH}"
echo "CSV_NAME: -m ${CSV_NAME}"
echo "ACCESS_DIR: -i ${ACCESS_DIR}"
echo "DEST_URL: -b ${DEST_URL}"
echo "DEST_PREFIX: -r: ${DEST_PREFIX}"
echo "========================================"

AWS_BUCKET_NAME=${AWS_DEST_BUCKET} \
ruby create_iiif_s3.rb \
    -t ${TMPDIR} \
    -s ${AWS_SRC_BUCKET} \
    -d ${AWS_DEST_BUCKET} \
    -c ${COLLECTION_IDENTIFIER} \
    -p ${CSV_PATH} \
    -m ${CSV_NAME} \
    -i ${ACCESS_DIR} \
    -b ${DEST_URL} \
    -r ${DEST_PREFIX}

# Delete tmpdir
# echo "Cleaning up: Deleting tmpdir ${TMPDIR}"
# rm -rf ${TMPDIR}
