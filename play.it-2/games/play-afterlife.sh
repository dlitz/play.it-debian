#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2019, Solène "Mopi" Huault
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
# Afterlife
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190310.2

# Set game-specific variables

GAME_ID='afterlife'
GAME_NAME='Afterlife'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='gog_afterlife_2.2.0.8.sh'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/afterlife'
ARCHIVE_GOG_EN_MD5='3aca0fac1b93adec5aff39d395d995ab'
ARCHIVE_GOG_EN_VERSION='1.0-gog2.2.0.8'
ARCHIVE_GOG_EN_SIZE='250000'

ARCHIVE_GOG_FR='gog_afterlife_french_2.2.0.8.sh'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/afterlife'
ARCHIVE_GOG_FR_MD5='56b3efee60bc490c68f8040587fc1878'
ARCHIVE_GOG_FR_VERSION='1.1-gog2.2.0.8'
ARCHIVE_GOG_FR_SIZE='250000'

ARCHIVE_DOC0_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC0_MAIN_FILES='*'

ARCHIVE_DOC1_MAIN_PATH='data/noarch/data'
ARCHIVE_DOC1_DATA_FILES='*.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*.asc *.exe *.ini alife.* alife'

CONFIG_FILES='./*.ini */*.ini'
DATA_DIRS='./save'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='alife/afterdos.bat'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="$GAME_ID"
PKG_MAIN_ID_GOG_EN="${PKG_MAIN_ID}-en"
PKG_MAIN_ID_GOG_FR="${PKG_MAIN_ID}-fr"
PKG_MAIN_PROVIDE="$PKG_MAIN_ID"
PKG_MAIN_DEPS='dosbox'

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
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN'

# Set working directory to the directory containing the game binary before running it

# shellcheck disable=SC2016
pattern='s|$APP_EXE $APP_OPTIONS $@|'
# shellcheck disable=SC2016
pattern="$pattern"'cd ${APP_EXE%/*}\n'
# shellcheck disable=SC2016
pattern="$pattern"'${APP_EXE##*/} $APP_OPTIONS $@|'
file="${PKG_MAIN_PATH}${PATH_BIN}/${GAME_ID}"
sed --in-place "$pattern" "$file"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
