#!/bin/sh

UPLOAD_DIR=alex@rosmarus.refsmmat.com:/home/alex/data-repository/

rsync -rvch --exclude '*.DS_Store' _site/ $UPLOAD_DIR
