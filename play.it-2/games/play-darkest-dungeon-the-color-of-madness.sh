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
# Darkest Dungeon: The Color of Madness
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190504.2

# Set game-specific variables

# copy GAME_ID from play-darkest-dungeon.sh
GAME_ID='darkest-dungeon'
GAME_NAME='Darkest Dungeon: The Color of Madness'

ARCHIVE_GOG='darkest_dungeon_the_color_of_madness_24839_28859.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/darkest_dungeon_the_color_of_madness'
ARCHIVE_GOG_MD5='9830e2b3cefc653db593a022e1c87359'
ARCHIVE_GOG_SIZE='640000'
ARCHIVE_GOG_VERSION='24839-gog28859'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='darkest_dungeon_the_color_of_madness_24788_26004.sh'
ARCHIVE_GOG_OLD3_MD5='a92a69e13e7ddb5da63d283ea40d93f7'
ARCHIVE_GOG_OLD3_SIZE='640000'
ARCHIVE_GOG_OLD3_VERSION='24788-gog26004'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='darkest_dungeon_the_color_of_madness_dlc_en_24358_23005.sh'
ARCHIVE_GOG_OLD2_MD5='0447fad1313ab47f6521debc3e75d308'
ARCHIVE_GOG_OLD2_SIZE='640000'
ARCHIVE_GOG_OLD2_VERSION='24358-gog23005'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='darkest_dungeon_the_color_of_madness_dlc_en_24154_22522.sh'
ARCHIVE_GOG_OLD1_MD5='40088860d8e3e3a651074e84eb2746ac'
ARCHIVE_GOG_OLD1_SIZE='630000'
ARCHIVE_GOG_OLD1_VERSION='24154-gog22522'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='darkest_dungeon_the_color_of_madness_dlc_en_23885_21662.sh'
ARCHIVE_GOG_OLD0_MD5='fe07f35c57c3ddd421db5da33b42ee6e'
ARCHIVE_GOG_OLD0_SIZE='630000'
ARCHIVE_GOG_OLD0_VERSION='23885-gog21662'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-the-color-of-madness"
PKG_MAIN_DEPS="$GAME_ID"

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
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
