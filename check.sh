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

if [ -z "$PYTHON" ]; then
    PYTHON=python
fi

REPORT_DIR=$(mktemp -d -t htmlreport-XXXXXXXXXX)
INDEX_HTML="$REPORT_DIR/index.html"
STATS_HTML="$REPORT_DIR/stats.html"
GUI_TEST_XML="$REPORT_DIR/gui_test.xml"
ERRORLIST_XML="$REPORT_DIR/errorlist.xml"
UNMATCHEDSUPPR_XML="$REPORT_DIR/unmatchedSuppr.xml"

../splint/src/splint -csv example.csv example.cc

#$PYTHON splint-htmlreport --file ../gui/test/data/xmlfiles/xmlreport_v2.xml --title "xml2 test" --report-dir "$REPORT_DIR" --source-dir ../test/
echo -e "\n"
# Check HTML syntax
validate_html "$INDEX_HTML"
validate_html "$STATS_HTML"


rm -rf "$REPORT_DIR"
