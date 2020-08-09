#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
# Copyright (c) 2020, Hoël Bézier
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
# Oxenfree
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200608.1

# Set game-specific variables

GAME_ID='oxenfree'
GAME_NAME='Oxenfree'

ARCHIVE_GOG='oxenfree_2_7_1_27542.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/oxenfree'
ARCHIVE_GOG_MD5='d1571d0af998fafcf26d628b3be13537'
ARCHIVE_GOG_VERSION='2.7.1f8-gog27542'
ARCHIVE_GOG_SIZE='3000000'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD='oxenfree_en_2_6_0_15278.sh'
ARCHIVE_GOG_OLD_MD5='9f9e9c4a3f4b73fa85a8d29714f5959e'
ARCHIVE_GOG_OLD_VERSION='2.6.0f30-gog15278'
ARCHIVE_GOG_OLD_SIZE='3000000'
ARCHIVE_GOG_OLD_TYPE='mojosetup'

ARCHIVE_ITCH='oxenfree-release-linux.zip'
ARCHIVE_ITCH_URL='https://night-school-studio.itch.io/oxenfree'
ARCHIVE_ITCH_MD5='54469a9bf98bc08125e69fc4612f390b'
ARCHIVE_ITCH_VERSION='2.7.1f8-20190208'
ARCHIVE_ITCH_SIZE='3000000'
ARCHIVE_ITCH_TYPE='zip'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='./*.txt'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_ITCH='Oxenfree_2.7.1_Linux-Uni-NoSteam_20190208_008'
ARCHIVE_GAME_BIN32_FILES='./*.x86 ./*_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_ITCH='Oxenfree_2.7.1_Linux-Uni-NoSteam_20190208_008'
ARCHIVE_GAME_BIN64_FILES='./*.x86_64 ./*_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_ITCH='Oxenfree_2.7.1_Linux-Uni-NoSteam_20190208_008'
ARCHIVE_GAME_DATA_FILES='./*_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Oxenfree.x86'
APP_MAIN_EXE_BIN64='Oxenfree.x86_64'
APP_MAIN_ICON='Oxenfree_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glx xcursor glibc libstdc++ libxrandr"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.11'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

prepare_package_layout

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launcher_write 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
