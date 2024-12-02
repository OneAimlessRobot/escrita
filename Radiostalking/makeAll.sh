#!/bin/bash
#cd SDL*
#sudo bash makeSoundLib.sh
#cd ..
make clean
make -C resources
make -j 2
