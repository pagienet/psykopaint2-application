#  -n <start>,<end>  MIMAP LEVELS
# -q <0-180> = QUALITY , 0 = lossless
# -f <0-15> Selects how many flex bits are trimmed during JPEG XR compression. 
# -c store an uncompressed texture
# -e disable mipmaps

#DXT for Windows and Mac OS => d
#ETC1 or DXT for Android => e
#PVRTC for iOS => p

#example:
#./png2atf -c p —q 10 -f 0  -i png/logo.png -o atf/ios/logo.atf
#./png2atf -c d —q 10 -f 0  -i png/logo.png -o atf/desktop/logo.atf

./png2atf —q 0 -i png/basic_circle2_hsp.png -o atf/basic_circle2_hsp.atf

: '#for entry in png
do
	echo "$entry"
	filename=$(basename "$entry")
	extension="${filename##*.}"
	filename="${filename%.*}"
	echo $extension
	if  [ "$extension" == "png" ]; then
		./png2atf —q 0 -i "png/$filename.png" -o "atf/$filename.atf"
	else
		echo "SKIPPING $entry"
	fi

done
'