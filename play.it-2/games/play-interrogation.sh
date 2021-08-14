#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2016-2021, Mopi
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
# Interrogation: You Will Be Deceived
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210710.2

# Set game-specific variables

GAME_ID='interrogation'
GAME_NAME='Interrogation: You Will Be Deceived'

ARCHIVE_BASE_0='interrogation_you_will_be_deceived_1_1_9_a1704342_39945.sh'
ARCHIVE_BASE_0_MD5='6e5c4d0ed24129d10a7781d034665b89'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='630000'
ARCHIVE_BASE_0_VERSION='1.1.9.a1704342-gog39954'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/interrogation_you_will_be_deceived'

ARCHIVE_DOC_PATH='data/noarch/game'
ARCHIVE_DOC_FILES='licenses.html'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Interrogation.x86_64 lib*'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='banks game.* '

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='.'
APP_MAIN_EXE='Interrogation.x86_64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} glibc libstdc++ glx libopenal.so.1 libX11.so.6 libGLU.so.1"
PKG_BIN_DEPS_ARCH='libxext libxi'
PKG_BIN_DEPS_DEB='libxext6, libxi6'
PKG_BIN_DEPS_GENTOO='x11-libs/libXext x11-libs/libXi'

# Load common functions

target_version='2.13'

if [ -z "$PLAYIT_LIB2" ]; then
	for path in \
		"$PWD" \
		"${XDG_DATA_HOME:="$HOME/.local/share"}/play.it" \
		'/usr/local/share/games/play.it' \
		'/usr/local/share/play.it' \
		'/usr/share/games/play.it' \
		'/usr/share/play.it'
	do
		if [ -e "${path}/libplayit2.sh" ]; then
			PLAYIT_LIB2="${path}/libplayit2.sh"
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

# Get icon

icons_get_from_workdir 'APP_MAIN'

# Clean up temporary directories

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

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
