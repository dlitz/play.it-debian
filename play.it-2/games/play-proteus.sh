#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2019, BetaRays
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
# Proteus
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180825.1

# Set game-specific variables

GAME_ID='proteus'
GAME_NAME='Proteus'

ARCHIVE_HUMBLE='proteus-05162014-bin'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/proteus'
ARCHIVE_HUMBLE_MD5='8a5911751382bcfb91483f52f781e283'
ARCHIVE_HUMBLE_VERSION='1.0-humble140516'
ARCHIVE_HUMBLE_SIZE='130000'
ARCHIVE_HUMBLE_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data'
ARCHIVE_DOC_DATA_FILES='./Linux.README'

ARCHIVE_GAME_BIN32_PATH='data'
ARCHIVE_GAME_BIN32_FILES='./Proteus.bin.x86 ./lib/libmono-2.0.so.1 ./lib/libSDL2-2.0.so.0 ./lib/libSDL2_mixer-2.0.so.0'

ARCHIVE_GAME_BIN64_PATH='data'
ARCHIVE_GAME_BIN64_FILES='./Proteus.bin.x86_64 ./lib64/libmono-2.0.so.1 ./lib64/libSDL2-2.0.so.0 lib64/libSDL2_mixer-2.0.so.0'

ARCHIVE_GAME_DATA_PATH='data'
ARCHIVE_GAME_DATA_FILES='./resources ./Proteus.png ./Proteus.exe ./*.dll ./*.config ./mono'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Proteus.bin.x86'
APP_MAIN_EXE_BIN64='Proteus.bin.x86_64'
APP_MAIN_ICON='Proteus.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glx xcursor glibc libstdc++ libxrandr sdl2 sdl2_image sdl2_mixer"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.10'

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
	write_launcher 'APP_MAIN'
done

# Fix a crash when starting from some terminals

# shellcheck disable=SC2016
pattern='s#^"\./$APP_EXE" .*#& > ./logs/$(date +%F-%R).log#'
sed --in-place "$pattern" "${PKG_BIN32_PATH}${PATH_BIN}/$GAME_ID"
sed --in-place "$pattern" "${PKG_BIN64_PATH}${PATH_BIN}/$GAME_ID"

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
