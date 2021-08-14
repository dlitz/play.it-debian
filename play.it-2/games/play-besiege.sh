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
# Besiege
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210424.5

# Set game-specific variables

GAME_ID='besiege'
GAME_NAME='Besiege'

ARCHIVES_LIST='
ARCHIVE_BASE_0'

ARCHIVE_BASE_0='besiege_v1_05_12536_39273.sh'
ARCHIVE_BASE_0_MD5='96d7e8ac29aa1f0bab020610d1a83c90'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='2800000'
ARCHIVE_BASE_0_VERSION='1.05-gog39273'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/besiege'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Besiege.x86 Besiege_Data/Mono/x86 Besiege_Data/Plugins/x68'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Besiege.x86_64 Besiege_Data/Mono/x86_64 Besiege_Data/Plugins/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Besiege_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Besiege.x86'
APP_MAIN_EXE_BIN64='Besiege.x86_64'
APP_MAIN_ICON='Besiege_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ glx xcursor libxrandr gtk2 libgdk_pixbuf-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0"
PKG_BIN32_DEPS_ARCH='lib32-libx11'
PKG_BIN32_DEPS_DEB='libx11-6'
PKG_BIN32_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libX11'

# Work around Unity3D poor support for non-US locales

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around Unity3D poor support for non-US locales
export LANG=C'

# Use a dedicated per-session log file

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a dedicated per-session log file
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile logs/$(date +%F-%R).log"'

# Use persistent storage for user data and settings

CONFIG_FILES="${CONFIG_FILES} Besiege_Data/*.xml"
DATA_DIRS="${DATA_DIRS} Besiege_Data/Mods"
DATA_FILES="${DATA_FILES} Besiege_Data/CompletedLevels.txt"

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
