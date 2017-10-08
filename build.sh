#!/bin/bash

# 

set -e -x

export NAME=Sjoerd
export EMAIL=sjoerd-2017@linuxonly.nl
export PATH=$PATH:/root/.cargo/bin

DEPTXT="dependencies.txt"

# Create a deb for each cargo package
cat "$DEPTXT" | while read dep ver
do
    cleanver=${ver/v/}
    cleandep=${dep/_/-}     # Cargo packages have underscores, debian packages have dashes.
    if [ ! -e librust-$cleandep-*$cleanver*.deb ]
    then
        debcargo package $dep $cleanver
        cd rust-$cleandep-*-$cleanver
        debuild -uc -us
        cd ..
    fi
done

# Install all created debian packages
dpkg -i *.deb

# Build ripgrep itself
debcargo package ripgrep 0.6
cd rust-ripgrep-0.6.0
debuild -uc -us
cd ..

dpkg -i ripgrep_0.6.0-1_amd64.deb

echo "Done"
