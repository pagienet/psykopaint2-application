#  -n <start>,<end>  MIMAP LEVELS
# -q <0-180> = QUALITY , 0 = lossless
# -f <0-15> Selects how many flex bits are trimmed during JPEG XR compression. 
# -c store an uncompressed texture
# -e disable mipmaps

#DXT for Windows and Mac OS => d
#ETC1 or DXT for Android => e
#PVRTC for iOS => p

#!/bin/bash
for i in {1..49}
do
#	./png2atf -c p —q 0 -f 0 -i png/$i.png -o atf/ios/$i-ios.atf
#	./png2atf -c d —q 0 -f 0 -i png/$i.png -o atf/desktop/$i-desktop.atf
#
	./png2atf —q 0 -i png/$i.png -o atf/$i.atf
done



#create thumbnails using image Magick: http://www.imagemagick.org/
#for i in {1..49}
#do
#	convert -thumbnail 200 png/$i.png thumbs/$i.png
#done



