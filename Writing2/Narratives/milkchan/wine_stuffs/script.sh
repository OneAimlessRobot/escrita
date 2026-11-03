#!/bin/bash


RUNNER="$HOME/.local/share/lutris/runners/wine/wine-ge-8-26-x86_64"
PREFIX="/home/addysmagic/.local/share/wineprefixes/wineprefix32bit/"

unset WINE WINESERVER WINELOADER WINEARCH

export WINEPREFIX="$PREFIX"
export WINE="$RUNNER/bin/wine"
export WINESERVER="$RUNNER/bin/wineserver"
export PATH="$RUNNER/bin:$PATH"


"$RUNNER/bin/wine" "/mnt/SUPER_CAVALEIRO/Attic/ISOs/mga/Metal_Gear_Acid_USA_PSP-LIGHTFORCE/mga/psound/PSound.exe"
