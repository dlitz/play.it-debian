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
# Stellaris - Synthetic Dawn Story Pack
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20210529.1

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris'

EXPANSION_ID='synthetic-dawn'
EXPANSION_NAME='Synthetic Dawn Story Pack'

ARCHIVE_BASE_15='stellaris_synthetic_dawn_story_pack_2_8_1_2_42827.sh'
ARCHIVE_BASE_15_URL='https://www.gog.com/game/stellaris_synthetic_dawn_story_pack'
ARCHIVE_BASE_15_MD5='2bcad8721700e5a8203fd7fe90c6f03c'
ARCHIVE_BASE_15_SIZE='49000'
ARCHIVE_BASE_15_VERSION='2.8.1.2-gog42827'
ARCHIVE_BASE_15_TYPE='mojosetup_unzip'

ARCHIVE_BASE_14='stellaris_synthetic_dawn_story_pack_2_8_0_5_42441.sh'
ARCHIVE_BASE_14_MD5='df7e6af404d8eb979a314a232430fbb3'
ARCHIVE_BASE_14_SIZE='49000'
ARCHIVE_BASE_14_VERSION='2.8.0.5-gog42441'
ARCHIVE_BASE_14_TYPE='mojosetup_unzip'

ARCHIVE_BASE_13='stellaris_synthetic_dawn_story_pack_2_8_0_3_42321.sh'
ARCHIVE_BASE_13_MD5='f199f4751b106516822e19249ab13014'
ARCHIVE_BASE_13_SIZE='49000'
ARCHIVE_BASE_13_VERSION='2.8.0.3-gog42321'
ARCHIVE_BASE_13_TYPE='mojosetup_unzip'

ARCHIVE_BASE_12='stellaris_synthetic_dawn_story_pack_2_7_2_38578.sh'
ARCHIVE_BASE_12_MD5='a58f3ab05f5b7b7c69e3b4d6c55dd2d7'
ARCHIVE_BASE_12_SIZE='49000'
ARCHIVE_BASE_12_VERSION='2.7.2-gog38578'
ARCHIVE_BASE_12_TYPE='mojosetup_unzip'

ARCHIVE_BASE_11='stellaris_synthetic_dawn_story_pack_2_7_1_38218.sh'
ARCHIVE_BASE_11_MD5='8a7261157927d868c0a9f807ac5310ae'
ARCHIVE_BASE_11_SIZE='49000'
ARCHIVE_BASE_11_VERSION='2.7.1-gog38218'
ARCHIVE_BASE_11_TYPE='mojosetup_unzip'

ARCHIVE_BASE_10='stellaris_synthetic_dawn_story_pack_2_6_3_2_37617.sh'
ARCHIVE_BASE_10_MD5='348d3e5a1a106fb2fbcd9c533dd413dc'
ARCHIVE_BASE_10_SIZE='49000'
ARCHIVE_BASE_10_VERSION='2.6.3.2-gog37617'
ARCHIVE_BASE_10_TYPE='mojosetup_unzip'

ARCHIVE_BASE_9='stellaris_synthetic_dawn_story_pack_2_6_2_37285.sh'
ARCHIVE_BASE_9_MD5='6663a393984f3c2ce4197a9b4e947d4e'
ARCHIVE_BASE_9_SIZE='49000'
ARCHIVE_BASE_9_VERSION='2.6.2-gog37285'
ARCHIVE_BASE_9_TYPE='mojosetup_unzip'

ARCHIVE_BASE_8='stellaris_synthetic_dawn_story_pack_2_6_1_1_36932.sh'
ARCHIVE_BASE_8_MD5='ac0fdc68b651da04b26c69072e931217'
ARCHIVE_BASE_8_SIZE='49000'
ARCHIVE_BASE_8_VERSION='2.6.1.1-gog36932'
ARCHIVE_BASE_8_TYPE='mojosetup_unzip'

ARCHIVE_BASE_7='stellaris_synthetic_dawn_story_pack_2_6_0_4_36778.sh'
ARCHIVE_BASE_7_MD5='d3520644ec752147a4d9eb9b8c6b7595'
ARCHIVE_BASE_7_SIZE='49000'
ARCHIVE_BASE_7_VERSION='2.6.0.4-gog36778'
ARCHIVE_BASE_7_TYPE='mojosetup_unzip'

ARCHIVE_BASE_6='stellaris_synthetic_dawn_story_pack_2_5_1_33517.sh'
ARCHIVE_BASE_6_MD5='651b7fdba97f8b12a57118bd5af75315'
ARCHIVE_BASE_6_SIZE='49000'
ARCHIVE_BASE_6_VERSION='2.5.1-gog33517'
ARCHIVE_BASE_6_TYPE='mojosetup_unzip'

ARCHIVE_BASE_5='stellaris_synthetic_dawn_story_pack_2_5_0_5_33395.sh'
ARCHIVE_BASE_5_MD5='bef6e627ff8e4e1d0890bfacff979261'
ARCHIVE_BASE_5_SIZE='49000'
ARCHIVE_BASE_5_VERSION='2.5.0.5-gog33395'
ARCHIVE_BASE_5_TYPE='mojosetup_unzip'

ARCHIVE_BASE_4='stellaris_synthetic_dawn_story_pack_2_4_1_1_33112.sh'
ARCHIVE_BASE_4_MD5='39b5ff1e84024fa579054a4b69043f8f'
ARCHIVE_BASE_4_SIZE='49000'
ARCHIVE_BASE_4_VERSION='2.4.4.1-gog33112'
ARCHIVE_BASE_4_TYPE='mojosetup_unzip'

ARCHIVE_BASE_3='stellaris_synthetic_dawn_story_pack_2_4_1_33088.sh'
ARCHIVE_BASE_3_MD5='85bdd887883651fbf43d5526d23d2231'
ARCHIVE_BASE_3_SIZE='49000'
ARCHIVE_BASE_3_VERSION='2.4.1-gog33088'
ARCHIVE_BASE_3_TYPE='mojosetup_unzip'

ARCHIVE_BASE_2='stellaris_synthetic_dawn_story_pack_2_4_0_7_33057.sh'
ARCHIVE_BASE_2_MD5='917989c55c41acecfa6ecb4d0f1f607b'
ARCHIVE_BASE_2_SIZE='49000'
ARCHIVE_BASE_2_VERSION='2.4.0.7-gog33057'
ARCHIVE_BASE_2_TYPE='mojosetup_unzip'

ARCHIVE_BASE_1='stellaris_synthetic_dawn_story_pack_2_3_3_1_30901.sh'
ARCHIVE_BASE_1_MD5='0bd54303550244ca68695f80d515d73c'
ARCHIVE_BASE_1_SIZE='49000'
ARCHIVE_BASE_1_VERSION='2.3.3.1-gog30901'
ARCHIVE_BASE_1_TYPE='mojosetup_unzip'

ARCHIVE_BASE_0='stellaris_synthetic_dawn_story_pack_2_3_3_30733.sh'
ARCHIVE_BASE_0_MD5='9f591acef78c04290fab2ec11cb92189'
ARCHIVE_BASE_0_SIZE='49000'
ARCHIVE_BASE_0_VERSION='2.3.3-gog30733'
ARCHIVE_BASE_0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc016_synthetic_dawn'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-${EXPANSION_ID}"
PKG_MAIN_DESCRIPTION="$EXPANSION_NAME"
PKG_MAIN_DEPS="$GAME_ID"

# Ensure smooth upgrade from pre-20201031.1 packages
PKG_MAIN_PROVIDE='stellaris-synthetic-dawn-story-pack'

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
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

GAME_NAME="$GAME_NAME - $EXPANSION_NAME"
print_instructions

exit 0
