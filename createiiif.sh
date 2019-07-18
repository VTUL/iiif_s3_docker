#!/bin/bash
# Generate the tiles
ruby create_iiif_s3.rb ${CSV_NAME} ${ACCESS_DIR} ${DEST_URL} ${DEST_FOLDER} --upload_to_s3=${UPLOAD_BOOL}

