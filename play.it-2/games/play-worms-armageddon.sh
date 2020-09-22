#!/bin/sh -e
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
# Worms Armageddon
# build native Linux packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200929.2

# Set game-specific variables

GAME_ID='worms-armageddon'
GAME_NAME='Worms Armageddon'

ARCHIVES_LIST='
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0'

ARCHIVE_GOG_2='setup_worms_armageddon_gog-2_(40354).exe'
ARCHIVE_GOG_2_URL='https://www.gog.com/game/worms_armageddon'
ARCHIVE_GOG_2_MD5='db2087029ee8c069c9006ebeedc76bbf'
ARCHIVE_GOG_2_VERSION='3.8-gog40354'
ARCHIVE_GOG_2_SIZE='650000'

ARCHIVE_GOG_1='setup_worms_armageddon_gog-7_(40119).exe'
ARCHIVE_GOG_1_MD5='8e904d462327917452a47572a38b772a'
ARCHIVE_GOG_1_VERSION='3.8-gog40119'
ARCHIVE_GOG_1_SIZE='660000'

ARCHIVE_GOG_0='setup_worms_armageddon_2.0.0.2.exe'
ARCHIVE_GOG_0_MD5='7f0bb89729662ebe74b7c9c2cd97d1c8'
ARCHIVE_GOG_0_VERSION='3.7.2.1-gog2.0.0.2'
ARCHIVE_GOG_0_SIZE='570000'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='./wa_manual.pdf ./worms?armageddon?update?documentation.rtf'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='./lfbmp10n.dll ./lfcmp10n.dll ./lflmb10n.dll ./lftga10n.dll ./ltfil10n.dll ./ltkrn10n.dll ./wa.exe user/bankeditor.exe ./steam_api.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='./data ./fesfx ./graphics ./tweaks user/fanfare user/flags user/graves user/import user/names.wdb user/savedlevels user/schemes user/speech user/teams ./steam.dat'

ARCHIVE_GAME_DATA_SAVE_PATH='./__support'
ARCHIVE_GAME_DATA_SAVE_FILES='./save'

# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_0='app'
ARCHIVE_GAME_BIN_PATH_GOG_0='app'
ARCHIVE_GAME_DATA_PATH_GOG_0='app'
ARCHIVE_GAME_DATA_SAVE_PATH_GOG_0='app/__support'

DATA_DIRS='./save ./user'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='wa.exe'
APP_MAIN_ICON='wa.exe'
APP_MAIN_ICON_RES='16 32 48'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Load common functions

target_version='2.3'

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

for PKG in $PACKAGES_LIST; do
	organize_data "DOC_${PKG#PKG_}"  "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

PKG='PKG_DATA'
organize_data "GAME_DATA_SAVE"  "$PATH_GAME"

PKG='PKG_BIN'
extract_and_sort_icons_from 'APP_MAIN'
move_icons_to 'PKG_DATA'

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
