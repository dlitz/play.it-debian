#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2020, ahub
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
# TEMPLATE_GAME_NAME
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###


script_version='20200925.0' # yyyymmdd.numberOfTries

# Set game-specific variables

GAME_ID='devil-daggers' # used for package name
GAME_NAME='Devil Daggers' # used for menu display


ARCHIVE_GOG='devil_daggers_en_update_1_20080.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/devil_daggers'
ARCHIVE_GOG_MD5='cf92f20e5a1662e9585fa500608ebdd1'
ARCHIVE_GOG_SIZE='420000' # rounded up 
ARCHIVE_GOG_TYPE='mojosetup_unzip'
ARCHIVE_GOG_VERSION='1.0-gog20080' # get that from the filename gameVersion-providerVersion

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

# dd/  default-44100.mhr  default-48000.mhr  devildaggers  lib64/  res/
ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='devildaggers lib64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='default-44100.mhr  default-48000.mhr res core dd'

DATA_FILES='error_log.txt'

APP_MAIN_TYPE='native'
APP_MAIN_ICON='data/noarch/support/icon.png'
# APP_MAIN_ICON='../support/icon.png'
APP_MAIN_EXE='devildaggers' 

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID"

# TODO: A voir
# PKG_BIN_DEPS_DEB="$PKG_BIN_DEPS_DEB"
# PKG_BIN_DEPS_ARCH='faudio'
# PKG_BIN_DEPS_GENTOO='app-emulation/faudio'

# Load common functions

target_version='2.12'

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

# Ensure availability of libcurl.so.4 providing CURL_OPENSSL_3 symbol

ARCHIVE_OPTIONAL_LIBCURL3='libcurl3_7.52.1_64-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBCURL3_URL='https://downloads.dotslashplay.it/resources/libcurl/'
ARCHIVE_OPTIONAL_LIBCURL3_MD5='e276dd3620c31617baace84dfa3dca21'
ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_LIBCURL3' 'ARCHIVE_OPTIONAL_LIBCURL3'
if [ "$ARCHIVE_LIBCURL3" ]; then
	extract_data_from "$ARCHIVE_LIBCURL3"
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/${APP_MAIN_LIBS:=libs}"
	mv "$PLAYIT_WORKDIR"/gamedata/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
else
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchive suivante nʼayant pas été fournie, libcurl.so.4.5.0 ne sera pas inclus dans les paquets : %s\n'
			message="$message"'Cette archive peut être téléchargée depuis %s\n'
		;;
		('en'|*)
			message='Due to the following archive missing, the packages will not include libcurl.so.4.5.0: %s\n'
			message="$message"'This archive can be downloaded from %s\n'
		;;
	esac
	print_warning
	printf "$message" "$ARCHIVE_OPTIONAL_LIBCURL3" "$ARCHIVE_OPTIONAL_LIBCURL3_URL"
	printf '\n'
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

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