#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2017, Antoine Le Gonidec
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
# Darkest Dungeon
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170930.1

# Set game-specific variables

GAME_ID='darkest-dungeon'
GAME_NAME='Darkest Dungeon'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_GOG_OLD ARCHIVE_GOG_OLDER ARCHIVE_GOG_OLDEST'

ARCHIVE_GOG='darkest_dungeon_en_20645_15279.sh'
ARCHIVE_GOG_MD5='78bfc79c2b0e7e8016d611746499fa22'
ARCHIVE_GOG_SIZE='2100000'
ARCHIVE_GOG_VERSION='20645-gog15279'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD='darkest_dungeon_en_20578_15132.sh'
ARCHIVE_GOG_OLD_MD5='12b51408bdedb012ee38e2321910cfca'
ARCHIVE_GOG_OLD_SIZE='2100000'
ARCHIVE_GOG_OLD_VERSION='20578-gog15132'
ARCHIVE_GOG_OLD_TYPE='mojosetup'

ARCHIVE_GOG_OLDER='gog_darkest_dungeon_2.15.0.15.sh'
ARCHIVE_GOG_OLDER_MD5='aa129363a693458d421df1b203960f8c'
ARCHIVE_GOG_OLDER_SIZE='2100000'
ARCHIVE_GOG_OLDER_VERSION='20326-gog2.15.0.15'

ARCHIVE_GOG_OLDEST='gog_darkest_dungeon_2.14.0.14.sh'
ARCHIVE_GOG_OLDEST_MD5='68c3728388a44a9f7f859351748d2463'
ARCHIVE_GOG_OLDEST_SIZE='2100000'
ARCHIVE_GOG_OLDEST_VERSION='20326-gog2.14.0.14'

DATA_DIRS='./logs'

ARCHIVE_DOC1_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC1_DATA_FILES='./*'

ARCHIVE_DOC2_DATA_PATH='data/noarch/game'
ARCHIVE_DOC2_DATA_FILES='./README.linux'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='./lib ./darkest.bin.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='./lib64 ./darkest.bin.x86_64'

ARCHIVE_GAME_AUDIO_PATH='data/noarch/game'
ARCHIVE_GAME_AUDIO_FILES='./audio'

ARCHIVE_GAME_VIDEO_PATH='data/noarch/game'
ARCHIVE_GAME_VIDEO_FILES='./video'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./Icon.bmp ./pin ./svn_revision.txt ./activity_log ./campaign ./colours ./curios ./cursors ./dungeons ./effects ./fe_flow ./fonts ./fx ./game_over ./heroes ./inventory ./loading_screen ./loot ./maps ./modes ./mods ./monsters ./overlays ./panels ./props ./raid ./raid_results ./scripts ./scrolls ./shaders ./shared ./trinkets ./upgrades ./user_information ./localization/*.bat ./localization/*.csv ./localization/*.loc ./localization/*.txt ./localization/*.xml ./localization/pc'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='darkest.bin.x86'
APP_MAIN_EXE_BIN64='darkest.bin.x86_64'
APP_MAIN_OPTIONS='1>./logs/$(date +%F-%R).log 2>&1'
APP_MAIN_ICON='Icon.bmp'
APP_MAIN_ICON_RES='128'

PACKAGES_LIST='PKG_AUDIO PKG_VIDEO PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_AUDIO_ID="${GAME_ID}-audio"
PKG_AUDIO_DESCRIPTION='audio'

PKG_VIDEO_ID="${GAME_ID}-video"
PKG_VIDEO_DESCRIPTION='video'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS_DEB="$PKG_AUDIO_ID, $PKG_VIDEO_ID, $PKG_DATA_ID, libc6, libstdc++6, libsdl2-2.0-0"
PKG_BIN32_DEPS_ARCH="$PKG_AUDIO_ID $PKG_VIDEO_ID $PKG_DATA_ID lib32-glibc lib32-gcc-libs lib32-sdl2"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_ARCH="$PKG_AUDIO_ID $PKG_VIDEO_ID $PKG_DATA_ID glibs gcc-libs sdl2"

# Load common functions

target_version='2.1'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	if [ -e "$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh" ]; then
		PLAYIT_LIB2="$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh"
	elif [ -e './libplayit2.sh' ]; then
		PLAYIT_LIB2='./libplayit2.sh'
	else
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		return 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

for PKG in $PACKAGES_LIST; do
	organize_data "DOC1_${PKG#PKG_}" "$PATH_DOC"
	organize_data "DOC2_${PKG#PKG_}" "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

res="$APP_MAIN_ICON_RES"
PATH_ICON="$PATH_ICON_BASE/${res}x${res}/apps"
extract_icon_from "${PKG_DATA_PATH}${PATH_GAME}/$APP_MAIN_ICON"
mkdir --parents "${PKG_DATA_PATH}${PATH_ICON}"
mv "$PLAYIT_WORKDIR/icons/${APP_MAIN_ICON%.bmp}.png" "${PKG_DATA_PATH}${PATH_ICON}/$GAME_ID.png"

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done


# Allow persistent logging via output redirection to work

sed --in-place 's|"\./$APP_EXE" $APP_OPTIONS $@|eval &|' "${PKG_BIN32_PATH}${PATH_BIN}/$GAME_ID"
sed --in-place 's|"\./$APP_EXE" $APP_OPTIONS $@|eval &|' "${PKG_BIN64_PATH}${PATH_BIN}/$GAME_ID"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
printf '32-bit:'
print_instructions 'PKG_AUDIO' 'PKG_VIDEO' 'PKG_DATA' 'PKG_BIN32'
printf '64-bit:'
print_instructions 'PKG_AUDIO' 'PKG_VIDEO' 'PKG_DATA' 'PKG_BIN64'

exit 0