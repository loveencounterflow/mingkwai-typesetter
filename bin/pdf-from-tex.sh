#!/usr/bin/env bash
set -euo pipefail

# ### TAINT in case TEXINPUTS is already set, the next line would make it longer
# with each run: ###
export TEXINPUTS=$TEXINPUTS:$1
# export TEXINPUTS=$1
xelatex -8bit -output-directory=$2 -jobname=$3 -halt-on-error --enable-write18 --recorder $4

echo "-----------------------------------------------------------------------------"
echo "you can re-run the last TeX command with:"
echo ""
echo "export TEXINPUTS=$TEXINPUTS:$1"
echo "xelatex -8bit -output-directory=$2 -jobname=$3 -halt-on-error --enable-write18 --recorder $4"
echo ""
echo "-----------------------------------------------------------------------------"



