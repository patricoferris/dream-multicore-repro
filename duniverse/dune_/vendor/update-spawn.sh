#!/bin/bash

version=f7b883ebc9bfa5c142a2f10a62b415a51c83bd36

set -e -o pipefail

TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

rm -rf spawn
mkdir -p spawn/src

(
    cd $TMP
    git clone https://github.com/janestreet/spawn.git
    cd spawn
    git checkout $version
)

SRC=$TMP/spawn

cp -v $SRC/src/spawn{.ml,.mli,_stubs.c} spawn/src

git checkout spawn/src/dune
git add -A .
