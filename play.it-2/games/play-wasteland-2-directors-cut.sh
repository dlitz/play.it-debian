#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec <vv221@dotslashplay.it>
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
# Wasteland 2 - Directorʼs Cut
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20210628.2

# Set game-specific variables

GAME_ID='wasteland-2-directors-cut'
GAME_NAME='Wasteland 2 - Directorʼs Cut'

ARCHIVE_BASE_0='gog_wasteland_2_director_s_cut_2.3.0.5.sh'
ARCHIVE_BASE_0_MD5='dc697b13e1f08de606add7684b5b3f78'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'
ARCHIVE_BASE_0_VERSION='1.1.92788-gog2.3.0.5'
ARCHIVE_BASE_0_SIZE='16000000'
ARCHIVE_BASE_0_URL='https://www.gog.com/game/wasteland_2_directors_cut_digital_classic_edition'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='WL2 WL2_Data/Mono WL2_Data/Plugins'

ARCHIVE_GAME_RESOURCES_PATH='data/noarch/game'
ARCHIVE_GAME_RESOURCES_FILES='WL2_Data/*.resource'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='WL2_Data'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='WL2'
APP_MAIN_ICON='WL2_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_RESOURCES PKG_DATA'

PKG_RESOURCES_ID="${GAME_ID}-resources"
PKG_RESOURCES_DESCRIPTION='resources'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="${PKG_DATA_ID} glu xcursor libxrandr alsa"

# Use a per-session dedicated file for logs

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Use a per-session dedicated file for logs
mkdir --parents logs
APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"'

# Work around Unity3D poor support for non-PulseAudio audio systems

# shellcheck disable=SC1004
APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Start pulseaudio if it is available
if command -v pulseaudio >/dev/null 2>&1; then
	PULSEAUDIO_IS_AVAILABLE=1
	if pulseaudio --check; then
		KEEP_PULSEAUDIO_RUNNING=1
	else
		KEEP_PULSEAUDIO_RUNNING=0
	fi
	pulseaudio --start
else
	PULSEAUDIO_IS_AVAILABLE=0
fi

# Work around crash on launch related to libpulse
# Some Unity3D games crash on launch if libpulse-simple.so.0 is available but pulseaudio is not running
if [ $PULSEAUDIO_IS_AVAILABLE -eq 0 ]; then
	mkdir --parents "${APP_LIBS:=libs}"
	ln --force --symbolic /dev/null "$APP_LIBS/libpulse-simple.so.0"
else
	if \
		[ -h "${APP_LIBS:=libs}/libpulse-simple.so.0" ] && \
		[ "$(realpath "$APP_LIBS/libpulse-simple.so.0")" = "/dev/null" ]
	then
		rm "$APP_LIBS/libpulse-simple.so.0"
		rmdir --ignore-fail-on-non-empty --parents "$APP_LIBS"
	fi
fi'
# shellcheck disable=SC1004
APP_MAIN_POSTRUN="$APP_MAIN_POSTRUN"'
# Stop pulseaudio if it has specifically been started for the game
if \
	[ $PULSEAUDIO_IS_AVAILABLE -eq 1 ] && \
	[ $KEEP_PULSEAUDIO_RUNNING -eq 0 ]
then
	pulseaudio --kill
fi'

# Work around engine overuse of file descriptors

APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'

# Work around engine overuse of file descriptors
ulimit -n $(($(ulimit -Hn)/2))'

# Ensure easy upgrade from packages generated with pre-20210620.1 game script

PKG_BIN_PROVIDE='wasteland-2'
PKG_DATA_PROVIDE='wasteland-2-data'
PKG_RESOURCES_PROVIDE='wasteland-2-resources'

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

# Delete temporary files

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