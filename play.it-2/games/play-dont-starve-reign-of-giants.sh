#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2015-2020, mortalius
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
# Don’t Starve: Reign Of Giants
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190724.1

# Set game-specific variables

GAME_ID='dont-starve'
GAME_NAME='Donʼt Starve: Reign Of Giants'

ARCHIVE_GOG='don_t_starve_reign_of_giants_dlc_en_20171215_17628.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/dont_starve_reign_of_giants'
ARCHIVE_GOG_MD5='47084ab8d5b36437e1bcb899c35bfe00'
ARCHIVE_GOG_SIZE='400000'
ARCHIVE_GOG_TYPE='mojosetup'
ARCHIVE_GOG_VERSION='246924-gog17628'

ARCHIVE_GOG_OLD0='gog_don_t_starve_reign_of_giants_dlc_2.0.0.3.sh'
ARCHIVE_GOG_OLD0_MD5='bd505adc70ed478a92669bc8c1c3a127'
ARCHIVE_GOG_OLD0_SIZE='400000'
ARCHIVE_GOG_OLD0_VERSION='1.0-gog2.0.0.3'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game/dontstarve32'
ARCHIVE_GAME_MAIN_FILES='data manifest_dlc0001.json'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-reign-of-giants"
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
