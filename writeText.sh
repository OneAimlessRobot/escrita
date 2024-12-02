#!/bin/bash

maxCols=50

if [  $# -ne 1  ]
then
		echo "Mete mais cenas!!!"
		exit
	
fi

nano -l -r $maxCols -J $maxCols "$1"
