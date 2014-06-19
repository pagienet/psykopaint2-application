# mimap levels: -n 0,0 


#!/bin/bash
#for i in {1..49}
#do
#	./png2atf -c p —q 0 -f 0 -i png/$i.png -o atf/ios/$i-ios.atf
#	./png2atf -c d —q 0 -f 0 -i png/$i.png -o atf/desktop/$i-desktop.atf
#
#done



#create thumbnails using image Magick: http://www.imagemagick.org/
for i in {1..49}
do
	convert -thumbnail 200 png/$i.png thumbs/$i.png

done



