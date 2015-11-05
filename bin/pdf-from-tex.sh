#!/usr/bin/env bash
# echo $TEXINPUTS
export TEXINPUTS=$TEXINPUTS:$1
xelatex -8bit -output-directory=$2 -jobname=$3 -halt-on-error --enable-write18 --recorder $4
# lualatex -8bit -output-directory=$2 -jobname=$3 -halt-on-error --enable-write18 --recorder $4
