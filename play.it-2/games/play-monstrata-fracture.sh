#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2020, Mopi
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
# Monstrata Fracture
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201019.1

# Set game-specific variables

GAME_ID='monstrata-fracture'
GAME_NAME='Monstrata Fracture'

ARCHIVES_LIST='
ARCHIVE_ITCH_1
ARCHIVE_ITCH_0'

ARCHIVE_ITCH_1='monstrata-fracture-win-linux.zip'
ARCHIVE_ITCH_1_URL='https://astralore.itch.io/monstrata-fracture'
ARCHIVE_ITCH_1_MD5='9839d978298251f296febd5bc9a9b550'
ARCHIVE_ITCH_1_SIZE='250000'
ARCHIVE_ITCH_1_VERSION='1.2.11-itch'
ARCHIVE_ITCH_1_TYPE='zip'

ARCHIVE_ITCH_0='monstrata-fracture-win-osx-linux.zip'
ARCHIVE_ITCH_0_URL='https://astralore.itch.io/monstrata-fracture'
ARCHIVE_ITCH_0_MD5='7fa34744e2ff3ad7b745909ebfea51fc'
ARCHIVE_ITCH_0_SIZE='270000'
ARCHIVE_ITCH_0_VERSION='1.2.11-itch'
ARCHIVE_ITCH_0_TYPE='zip'

ARCHIVE_DOC_DATA_PATH_ITCH_1='Monstrata-1.2.11-pc'
ARCHIVE_DOC_DATA_PATH_ITCH_0='Monstrata-1.2.11-market'
ARCHIVE_DOC_DATA_FILES='credits.txt'

ARCHIVE_GAME_BIN32_PATH_ITCH_1='Monstrata-1.2.11-pc'
ARCHIVE_GAME_BIN32_PATH_ITCH_0='Monstrata-1.2.11-market'
ARCHIVE_GAME_BIN32_FILES='lib/linux-i686 Monstrata.sh'

ARCHIVE_GAME_BIN64_PATH_ITCH_1='Monstrata-1.2.11-pc'
ARCHIVE_GAME_BIN64_PATH_ITCH_0='Monstrata-1.2.11-market'
ARCHIVE_GAME_BIN64_FILES='lib/linux-x86_64'

ARCHIVE_GAME_DATA_PATH_ITCH_1='Monstrata-1.2.11-pc'
ARCHIVE_GAME_DATA_PATH_ITCH_0='Monstrata-1.2.11-market'
ARCHIVE_GAME_DATA_FILES='lib/pythonlib2.7 game Monstrata.py renpy'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Monstrata.sh'
APP_MAIN_ICON_ITCH_1='Monstrata-1.2.11-pc/Monstrata.exe'
APP_MAIN_ICON_ITCH_0='Monstrata-1.2.11-market/Monstrata.exe'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.12'

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
prepare_package_layout

# Copy launching script between the binaries packages

LAUNCHER_SOURCE="${PKG_BIN32_PATH}${PATH_GAME}/$APP_MAIN_EXE"
LAUNCHER_DESTINATION="${PKG_BIN64_PATH}${PATH_GAME}/$APP_MAIN_EXE"
mkdir --parents "$(dirname "$LAUNCHER_DESTINATION")"
cp "$LAUNCHER_SOURCE" "$LAUNCHER_DESTINATION"

# Get icon

use_archive_specific_value 'APP_MAIN_ICON'

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'

# Clean up temporary directories

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
