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
# Blackwell 2: Blackwell Unbound
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210522.2

# Set game-specific variables

GAME_ID='blackwell-2'
GAME_NAME='Blackwell 2: Blackwell Unbound'

ARCHIVE_BASE_0='gog_blackwell_unbound_2.0.0.2.sh'
ARCHIVE_BASE_0_MD5='e694b6638f49535224ed474d3c8ce128'
ARCHIVE_BASE_0_TYPE='mojosetup'
ARCHIVE_BASE_0_SIZE='220000'
ARCHIVE_BASE_0_VERSION='1.0-gog2.0.0.2'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/blackwell_bundle'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Unbound.bin.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Unbound.bin.x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Unbound.png *.cfg *.dat *.vox'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Unbound.bin.x86'
APP_MAIN_EXE_BIN64='Unbound.bin.x86_64'
APP_MAIN_ICON='Unbound.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="${PKG_DATA_ID} glibc libstdc++ theora glx freetype libSDL2-2.0.so.0 libvorbisfile.so.3"
PKG_BIN32_DEPS_DEB='libogg0, libvorbis0a'
PKG_BIN32_DEPS_ARCH='lib32-libogg lib32-libvorbis'
PKG_BIN32_DEPS_GENTOO='media-libs/libogg[abi_x86_32] media-libs/libvorbis[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_ARCH='libogg libvorbis'
PKG_BIN64_DEPS_GENTOO='media-libs/libogg media-libs/libvorbis'

# Ensure easy upgrade from packages generated with pre-20210317.1 game script
PKG_BIN32_PROVIDE='blackwell-2-blackwell-unbound'
PKG_BIN64_PROVIDE='blackwell-2-blackwell-unbound'
PKG_DATA_PROVIDE='blackwell-2-blackwell-unbound-data'

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

# Switch French keyboard layout to us-azerty to provide direct access to digits

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Switch French keyboard layout to us-azerty to provide direct access to digits
KEYBOARD_LAYOUT=$(LANG=C setxkbmap -query | awk "/layout:/ {print \$2}")
RESTORE_VARIANT=0
if [ $KEYBOARD_LAYOUT = "fr" ]; then
	KEYBOARD_VARIANT=$(LANG=C setxkbmap -query | awk "/variant:/ {print \$2}")
	if [ $KEYBOARD_VARIANT != "us-azerty" ]; then
		setxkbmap -variant us-azerty
		RESTORE_VARIANT=1
	fi
fi'
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'

# Restore the keyboard variant
if [ $RESTORE_VARIANT -eq 1 ]; then
	setxkbmap -variant "$KEYBOARD_VARIANT"
fi'

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
