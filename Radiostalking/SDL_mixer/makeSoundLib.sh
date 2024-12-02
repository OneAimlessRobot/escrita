#!/bin/bash
sudo echo ""
make clean
./configure
sudo make install -j 2
