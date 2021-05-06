#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Pharaoh
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210506.3

# Set game-specific variables

GAME_ID='pharaoh'
GAME_NAME='Pharaoh'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='setup_pharaoh_gold_2.1.0.15.exe'
ARCHIVE_BASE_0_MD5='62298f00f1f2268c8d5004f5b2e9fc93'
ARCHIVE_BASE_0_TYPE='innosetup'
ARCHIVE_BASE_0_SIZE='810000'
ARCHIVE_BASE_0_VERSION='2.1-gog2.1.0.15'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/pharaoh_cleopatra'

ARCHIVE_DOC0_DATA_PATH='tmp'
ARCHIVE_DOC0_DATA_FILES='*.txt'

ARCHIVE_DOC1_DATA_PATH='app'
ARCHIVE_DOC1_DATA_FILES='*.pdf mission?editor?guide.txt readme.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.asi *.exe *.ini *.m3d *.tsk binkw32.dll mss16.dll mss32.dll smackw32.dll cleoicon.ico'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='*.emp *.eng *.inf *.pak setup.ico auto?reason?phrases.txt campaign.txt eventmsg.txt figure_*.txt music.txt pharaoh_*.txt tax_*.txt trade_recommends.txt audio binks data maps'

CONFIG_FILES='./*.ini'
DATA_DIRS='./save'
DATA_FILES='./*.txt'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='pharaoh.exe'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON1 APP_MAIN_ICON2'
APP_MAIN_ICON1='pharaoh.exe'
APP_MAIN_ICON2='cleoicon.ico'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="${PKG_DATA_ID} wine glx"

# Explicitely set icons-related script dependencies
# cf. https://forge.dotslashplay.it/play.it/scripts/-/issues/110

SCRIPT_DEPS="${SCRIPT_DEPS} convert identify wrestool"

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
prepare_package_layout

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build packages

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
