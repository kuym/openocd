#!/bin/sh

output="./openocd-0.9.0rc1"
configureOptions="--enable-ftdi --enable-stlink --enable-jlink"


git submodule init && git submodule update


cd tools/libtool-2.4.6/
./configure --prefix=`pwd` && make && make install
cd ../..

	
cd tools/autoconf-2.69/
./configure --prefix=`pwd` && make && make install
cd ../..


cd tools/automake-1.15
PATH="$PATH:`pwd`/../autoconf-2.69/bin" ./configure --prefix=`pwd` && make && make install
cd ../..


cd tools/libusb-1.0.19
./configure --prefix=`pwd` && make && make install
cd ../..


PATH="$PATH:tools/libtool-2.4.6:tools/autoconf-2.69/bin:tools/automake-1.15/bin" ./bootstrap

LIBUSB1_CFLAGS="-I`pwd`/tools/libusb-1.0.19/include/libusb-1.0" LIBUSB1_LIBS="-L`pwd`/tools/libusb-1.0.19/lib -lusb-1.0.19" PATH="$PATH:tools/libtool-2.4.6:tools/autoconf-2.69/bin:tools/automake-1.15/bin" ./configure $configureOptions

# at this point a defect in the openocd build system prevents the binary from linking correctly, so we will re-build:


cd src

files=$(nm .libs/libopenocd.a | grep : | sed -E "s/\.libs\/libopenocd\.a\(([a-zA-Z0-9_.-]+)\):/\1/g")

for f in $files; do
	if [ "$f" == "libhelper_la-replacements.o" ]; then
		echo "Skipping libhelper_la-replacements.o, it is incompatible."
		continue;
	fi
	p=$(find . -name $f)
	if [ -z "$p" ]; then
		echo "Warning: could not find $f, it may not be necessary"
	else
		paths="$paths $p"
	fi
done

gcc -g -O2 -Wall -Wstrict-prototypes -Wformat-security -Wshadow -Wextra -Wno-unused-parameter -Wbad-function-cast -Wcast-align -Wredundant-decls -Werror -o $output main.o $paths ../tools/libusb-1.0.19/lib/libusb-1.0.a ../jimtcl/libjim.a -lm -framework CoreFoundation -framework IOKit -lobjc

if [ $? -ne 0 ]; then
	echo "Could not build"
	exit -1
fi

echo Built $output

cd ..
