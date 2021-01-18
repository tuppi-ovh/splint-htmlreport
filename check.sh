#!/bin/bash -ex

# Command for checking HTML syntax with HTML Tidy, see http://www.html-tidy.org/
# newer tidy (5.6.0) command, if using this it is not necessary to ignore warnings:
#tidy_cmd='tidy -o /dev/null -eq --drop-empty-elements no'
# older tidy from 2009 (Ubuntu 16.04 Xenial comes with this old version):
tidy_cmd='tidy -o /dev/null -eq'

function validate_html {
    if [ ! -f "$1" ]; then
        echo "File $1 does not exist!"
	exit 1
    fi
    set +e
    ${tidy_cmd} "$1"
    tidy_status=$?
    set -e
    if [ $tidy_status -eq 2 ]; then
        echo "HTML does not validate!"
        exit 1
    fi
}

REPORT_DIR=`pwd`/htmlreport
INDEX_HTML="$REPORT_DIR/index.html"
STATS_HTML="$REPORT_DIR/stats.html"

# execute splint 
set +e
../splint/src/splint -csv example.csv example.cc
set -e

python3 splint-htmlreport.py --file example.csv --title "csv test" --report-dir $REPORT_DIR --source-dir .
echo -e "\n"

# Check HTML syntax
validate_html "$INDEX_HTML"
validate_html "$STATS_HTML"

# clean up
rm -rf "$REPORT_DIR"
