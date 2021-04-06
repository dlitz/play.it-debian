#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Evoland
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201219.12

# Set game-specific variables

GAME_ID='evoland-1'
GAME_NAME='Evoland'

ARCHIVES_LIST='
ARCHIVE_GOG_0
ARCHIVE_HUMBLE_0'

ARCHIVE_GOG_0='setup_evoland_1.1.2490_(20677).exe'
ARCHIVE_GOG_0_MD5='97978ef959d097876142ae2c6ce765c2'
ARCHIVE_GOG_0_SIZE='120000'
ARCHIVE_GOG_0_VERSION='1.1.2490-gog20677'
ARCHIVE_GOG_0_TYPE='innosetup'
ARCHIVE_GOG_0_URL='https://www.gog.com/game/evoland'

ARCHIVE_HUMBLE_0='Evoland.exe'
ARCHIVE_HUMBLE_0_MD5='9585142f38d769d4ac9125f587d0c891'
ARCHIVE_HUMBLE_0_SIZE='110000'
ARCHIVE_HUMBLE_0_VERSION='1.1.2490-humble1'
ARCHIVE_HUMBLE_0_TYPE='nullsoft-installer'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='adobe?air dinput8.dll evoland.exe pad.exe'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='game.dat icons meta-inf mimetype'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='evoland.exe'
for res in 16 32 48 128; do
	export "APP_MAIN_ICON_${res}=icons/evoicon${res}.png"
	APP_MAIN_ICONS_LIST="$APP_MAIN_ICONS_LIST APP_MAIN_ICON_${res}"
done

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Ensure easy upgrades from packages generated by pre-20201219.1 script
PKG_BIN_PROVIDE='evoland'

# Store saved games in persistent paths

DATA_DIRS="$DATA_DIRS ./saves"
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
# Store saved games in persistent paths
saves_path_prefix="$WINEPREFIX/drive_c/users/$USER/Application Data/com.shirogames.evoland/Local Store/#SharedObjects/game.dat"
saves_path_persistent="$PATH_PREFIX/saves"
if [ ! -h "$saves_path_prefix" ]; then
	if [ -d "$saves_path_prefix" ]; then
		# Migrate existing saves to the persistent path
		mv "$saves_path_prefix"/* "$saves_path_persistent"
		rmdir "$saves_path_prefix"
	fi
	# Create link from prefix to persistent path
	mkdir --parents "$(dirname "$saves_path_prefix")"
	ln --symbolic "$saves_path_persistent" "$saves_path_prefix"
fi'

# Load common functions

target_version='2.12'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
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
case "$ARCHIVE" in
	('ARCHIVE_HUMBLE'*)
		tolower "${PLAYIT_WORKDIR}/gamedata"
	;;
esac
prepare_package_layout

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0