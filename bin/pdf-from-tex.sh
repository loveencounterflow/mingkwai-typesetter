#!/usr/bin/env bash
set -euo pipefail


# set default value of $TEXINPUTS so we don't get an `unbound variable` error:
TEXINPUTS=${TEXINPUTS:-}

# append first argument to $TEXINPUTS:
export TEXINPUTS=$TEXINPUTS:$1
echo '$TEXINPUTS set to' "$TEXINPUTS"

# Observe that in case $TEXINPUTS was unset when this script started, then it will be
# set to whatever the first script argument was, with a `:` (colon) prepended. Turns
# out this is the correct way to do it; without the initial colon, TeX will not be able
# to find files from its standard library.

xelatex -8bit -output-directory="$2" -jobname="$3" -halt-on-error --enable-write18 --recorder "$4"

echo "-----------------------------------------------------------------------------"
echo "you can re-run the last TeX command with:"
echo ""
echo "export TEXINPUTS=$TEXINPUTS:$1"
echo "xelatex -8bit -output-directory=$2 -jobname=$3 -halt-on-error --enable-write18 --recorder $4"
echo ""
echo "-----------------------------------------------------------------------------"



