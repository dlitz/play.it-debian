#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2021, Antoine Le Gonidec <vv221@dotslashplay.it>
# Copyright (c) 2018-2021, BetaRays
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
# TIS-100
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210507.9

# Set game-specific variables

GAME_ID='tis-100'
GAME_NAME='TIS-100'

ARCHIVE_BASE_0='tis_100_en_11_27_2017_16765.sh'
ARCHIVE_BASE_0_MD5='70518ec82ee8148697b704ed2c3c8953'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_VERSION='2017.11.27-gog16765'
ARCHIVE_BASE_0_SIZE='83000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/tis100'

ARCHIVE_DOC_DATA_PATH='data/noarch/game'
ARCHIVE_DOC_DATA_FILES='TIS-100?Reference?Manual.pdf'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='tis100.x86 tis100_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='tis100.x86_64 tis100_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='tis100_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='tis100.x86'
APP_MAIN_EXE_BIN64='tis100.x86_64'
APP_MAIN_ICON='tis100_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ glx xcursor libxrandr gtk2 libX11.so.6 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

# Work around Unity3D poor support for non-US locales

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around Unity3D poor support for non-US locales
export LANG=C'

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

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Clean up temporary files

rm --recursive "${PLAYIT_WORKDIR}/gamedata"

# Copy the manual in the game directory

package_path=$(package_get_path 'PKG_DATA')
manual_source="${package_path}${PATH_DOC}/TIS-100 Reference Manual.pdf"
manual_destination="${package_path}${PATH_GAME}/TIS-100 Reference Manual.pdf"
mkdir --parents "$(dirname "$manual_destination")"
cp --link "$manual_source" "$manual_destination"

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
