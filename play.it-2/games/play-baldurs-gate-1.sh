#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# This software is provided by the copyright holders and contributors "as is"
# and any express or implied warranties, including, but not limited to, the
# implied warranties of merchantability and fitness for a particular purpose
# are disclaimed. In no event shall the copyright holder or contributors be
# liable for any direct, indirect, incidental, special, exemplary, or
# consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business
# interruption) however caused and on any theory of liability, whether in
# contract, strict liability, or tort (including negligence or otherwise)
# arising in any way out of the use of this software, even if advised of the
# possibility of such damage.
###

###
# Baldur’s Gate
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200803.2

# Set game-specific variables

SCRIPT_DEPS='dos2unix'

GAME_ID='baldurs-gate-1'
GAME_NAME='Baldurʼs Gate'

ARCHIVES_LIST='
ARCHIVE_GOG_EN_1
ARCHIVE_GOG_FR_1
ARCHIVE_GOG_EN_0
ARCHIVE_GOG_FR_0'

ARCHIVE_GOG_EN_1='baldur_s_gate_the_original_saga_gog_3_23532.sh'
ARCHIVE_GOG_EN_1_URL='https://www.gog.com/game/baldurs_gate_enhanced_edition'
ARCHIVE_GOG_EN_1_MD5='f1750a05b52a5c8bb4810f0dbdb92091'
ARCHIVE_GOG_EN_1_VERSION='1.3.5521-gog23532'
ARCHIVE_GOG_EN_1_SIZE='3400000'
ARCHIVE_GOG_EN_1_TYPE='mojosetup'

ARCHIVE_GOG_FR_1='baldur_s_gate_the_original_saga_french_gog_3_23532.sh'
ARCHIVE_GOG_FR_1_URL='https://www.gog.com/game/baldurs_gate_enhanced_edition'
ARCHIVE_GOG_FR_1_MD5='09073e75602383c2c90d7c82436a8d91'
ARCHIVE_GOG_FR_1_VERSION='1.3.5521-gog23532'
ARCHIVE_GOG_FR_1_SIZE='3400000'
ARCHIVE_GOG_FR_1_TYPE='mojosetup'

ARCHIVE_GOG_EN_0='gog_baldur_s_gate_the_original_saga_2.1.0.10.sh'
ARCHIVE_GOG_EN_0_MD5='6810388ef67960dded254db5750f9aa5'
ARCHIVE_GOG_EN_0_VERSION='1.3.5521-gog2.1.0.10'
ARCHIVE_GOG_EN_0_SIZE='3100000'

ARCHIVE_GOG_FR_0='gog_baldur_s_gate_the_original_saga_french_2.1.0.10.sh'
ARCHIVE_GOG_FR_0_MD5='87ed67decb79e497b8c0ce9e0b16ac4c'
ARCHIVE_GOG_FR_0_VERSION='1.3.5521-gog2.1.0.10'
ARCHIVE_GOG_FR_0_SIZE='3100000'

ARCHIVE_DOC_L10N_PATH='data/noarch/docs'
ARCHIVE_DOC_L10N_FILES='*'

ARCHIVE_GAME_BIN_PATH_GOG_EN="data/noarch/prefix/drive_c/gog games/baldur's gate"
ARCHIVE_GAME_BIN_PATH_GOG_FR="data/noarch/prefix/drive_c/gog games/baldur's gate (french)"
ARCHIVE_GAME_BIN_FILES='*.cfg *.exe *.ini'

ARCHIVE_GAME_L10N_PATH_GOG_EN="data/noarch/prefix/drive_c/gog games/baldur's gate"
ARCHIVE_GAME_L10N_PATH_GOG_FR="data/noarch/prefix/drive_c/gog games/baldur's gate (french)"
ARCHIVE_GAME_L10N_FILES='*.tlk save mpsave override sounds data/chasound.bif data/cresound.bif data/mpsounds.bif data/npcsound.bif movies/moviecd1.bif movies/moviecd2.bif movies/moviecd3.bif movies/moviecd4.bif'

ARCHIVE_GAME_DATA_PATH_GOG_EN="data/noarch/prefix/drive_c/gog games/baldur's gate"
ARCHIVE_GAME_DATA_PATH_GOG_FR="data/noarch/prefix/drive_c/gog games/baldur's gate (french)"
ARCHIVE_GAME_DATA_FILES='*.key characters music scripts data movies'

CONFIG_FILES='*.ini'
DATA_DIRS='./characters ./mpsave ./save'

# Set a WINE virtual desktop on first launch, using the current desktop resolution
APP_WINETRICKS="vd=\$(xrandr|awk '/\\*/ {print \$1}')"
# Disable the multi-threaded command stream feature, as it has a very severe impact on performances
APP_WINETRICKS="$APP_WINETRICKS csmt=off"

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='bgmain2.exe'
APP_MAIN_ICON='baldur.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='config.exe'
APP_CONFIG_ICON='config.exe'
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

# Localization package — common properties
PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
# Localization package — English version
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
# Localization package — French version
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine winetricks glx libxrandr"

# Easier upgrade from packages generated with pre-20180930.2 scripts
PKG_BIN_PROVIDE='baldurs-gate'
PKG_DATA_PROVIDE='baldurs-gate-data'

# Load common functions

target_version='2.11'

if [ -z "$PLAYIT_LIB2" ]; then
	: "${XDG_DATA_HOME:="$HOME/.local/share"}"
	for path in\
		"$PWD"\
		"$XDG_DATA_HOME/play.it"\
		'/usr/local/share/games/play.it'\
		'/usr/local/share/play.it'\
		'/usr/share/games/play.it'\
		'/usr/share/play.it'
	do
		if [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
fi
if [ -z "$PLAYIT_LIB2" ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'libplayit2.sh not found.\n'
	exit 1
fi
# shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
tolower "$PLAYIT_WORKDIR/gamedata/data/noarch/docs"
tolower "$PLAYIT_WORKDIR/gamedata/data/noarch/prefix/drive_c"
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
move_icons_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Tweak paths in baldur.ini

###
# TODO
# A library-provided function for .ini files edition could be useful
###

ini_file="${PKG_BIN_PATH}${PATH_GAME}/baldur.ini"
path_game='C:\\'"$GAME_ID"'\\'
path_data='C:\\'"$GAME_ID"'\\data\\'
pattern="s/HD0:=.\\+/HD0:=$path_game/"
pattern="$pattern;s/CD1:=.*/CD1:=$path_data/"
pattern="$pattern;s/CD2:=.*/CD2:=$path_data/"
pattern="$pattern;s/CD3:=.*/CD3:=$path_data/"
pattern="$pattern;s/CD4:=.*/CD4:=$path_data/"
pattern="$pattern;s/CD5:=.*/CD5:=$path_data/"
pattern="$pattern;s/CD6:=.*/CD6:=$path_data/"
dos2unix "$ini_file" >/dev/null 2>&1
sed --in-place "$pattern" "$ini_file"
unix2dos "$ini_file" >/dev/null 2>&1

# Use more sensible default settings for modern hardware

ini_file="${PKG_BIN_PATH}${PATH_GAME}/baldur.ini"
ini_field='Path Search Nodes'
ini_value='400000'
pattern="s/^$ini_field=.*/$ini_field=$ini_value/"
ini_field='CacheSize'
ini_value='1024'
pattern="$pattern;s/^$ini_field=.*/$ini_field=$ini_value/"
dos2unix "$ini_file" >/dev/null 2>&1
sed --in-place "$pattern" "$ini_file"
unix2dos "$ini_file" >/dev/null 2>&1

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_CONFIG'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
