#!/bin/bash

/mnt/CAMARON/jvm/java-8-openjdk-amd64/bin/java -jar forge-1.12.2-14.23.5.2864.jar -Xmx2G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M
