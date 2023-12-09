#!/bin/bash
set -ex
svg=karkarkar.svg

size="16 32 24 48 72 96 144 152 192 196"
out="pngs"
mkdir -p $out

echo Making bitmaps from your svg...
for i in $size; do
    outdir="$out/${i}x${i}"
    mkdir -p $outdir
    inkscape $svg --export-type=png --export-filename "$outdir/karkarkar.png" -w $i -h $i
done

echo Generating to icon.ico...

convert $out/*/karkarkar.png icon.ico

echo Done
