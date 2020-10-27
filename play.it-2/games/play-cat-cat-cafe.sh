#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Cat Cat Café
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20201017.1

# Set game-specific variables

GAME_ID='cat-cat-cafe'
GAME_NAME='Cat Cat Café'

ARCHIVES_LIST='
ARCHIVE_ITCH_0'

ARCHIVE_ITCH_0='CatCatCafe-Linux.zip'
ARCHIVE_ITCH_0_URL='https://pouleyketchoupp.itch.io/cat-cat-cafe'
ARCHIVE_ITCH_0_MD5='6a1e227a6d19d461e45c0f9e05b2af9f'
ARCHIVE_ITCH_0_SIZE='130000'
ARCHIVE_ITCH_0_VERSION='1.0-itch'
ARCHIVE_ITCH_0_TYPE='zip'

ARCHIVE_GAME_BIN32_PATH='CatCatCafe'
ARCHIVE_GAME_BIN32_FILES='CatCatCafe.x86 CatCatCafe_Data/Mono*/x86 CatCatCafe_Data/Plugins/x86 libsteam_api.so'

ARCHIVE_GAME_BIN64_PATH='CatCatCafe'
ARCHIVE_GAME_BIN64_FILES='CatCatCafe.x86_64 CatCatCafe_Data/Mono*/x86_64 CatCatCafe_Data/Plugins/x86_64 libsteam_api64.so'

ARCHIVE_GAME_DATA_PATH='CatCatCafe'
ARCHIVE_GAME_DATA_FILES='CatCatCafe_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='# Work around Unity3D poor support for non-US locales
export LANG=C'
APP_MAIN_EXE_BIN32='CatCatCafe.x86'
APP_MAIN_EXE_BIN64='CatCatCafe.x86_64'
APP_MAIN_ICON='CatCatCafe_Data/Resources/UnityPlayer.png'
# Use a per-session dedicated file for logs
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
