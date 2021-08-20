#!/bin/bash

set -e

DIRNAME=$(dirname $0)

if [ "$#" -ne 1 ]; then
  echo 2>&1 "Usage: ./$(basename $0) <filename>"
  exit 1
fi

if [ ! -e "$1" ]; then
	echo 2>&1 "$1: file does not exist!"
	exit 2
fi

temp=$(mktemp)
"$DIRNAME/unfold-eyaml-values.rb" $1 > $temp
"$DIRNAME/sort-hiera-data.rb" $temp > $1
\rm $temp
