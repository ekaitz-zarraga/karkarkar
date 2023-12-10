# Run me in the linux/ folder
# I need the version in an argument, which should be Major.Minor-Revision
# for example 0.1-3.
version=$1
outfolder="karkarkar-$version"
mkdir "$outfolder"
mkdir -p "$outfolder/usr/bin"
mkdir -p "$outfolder/usr/share/applications"
mkdir -p "$outfolder/usr/share/AhoTTS/"
mkdir -p "$outfolder/usr/share/icons/hicolor/scalable/apps"

cp -r "../AhoTTS/data_tts"       "$outfolder/usr/share/AhoTTS/"
cp    "karkarkar.desktop"        "$outfolder/usr/share/applications"
cp    "../icons/karkarkar.svg"   "$outfolder/usr/share/icons/hicolor/scalable/apps"
cp    "../zig-out/bin/karkarkar" "$outfolder/usr/bin/"

mkdir -p "$outfolder/DEBIAN"
cat > $outfolder/DEBIAN/control <<EOF
Package: karkarkar
Version: $version
Section: base
Priority: optional
Architecture: amd64
Depends: libopenal1 (>=1.19.1)
Maintainer: Ekaitz Zarraga <ekaitz@elenq.tech>
Description: Karkarkar
 Listen to a Twitch chat in Basque.
EOF

dpkg-deb --root-owner-group --build "$outfolder"
rm -rf "$outfolder"
