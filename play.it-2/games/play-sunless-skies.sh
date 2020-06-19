#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Sunless Skies
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200619.1

# Set game-specific variables

GAME_ID='sunless-skies'
GAME_NAME='Sunless Skies'

ARCHIVES_LIST='
ARCHIVE_GOG_9
ARCHIVE_GOG_8
ARCHIVE_GOG_7
ARCHIVE_GOG_6
ARCHIVE_GOG_5
ARCHIVE_GOG_4
ARCHIVE_GOG_3
ARCHIVE_GOG_2
ARCHIVE_GOG_1
ARCHIVE_GOG_0
'

ARCHIVE_GOG_9='sunless_skies_1_3_2_06feaeba_33084.sh'
ARCHIVE_GOG_9_URL='https://www.gog.com/game/sunless_skies'
ARCHIVE_GOG_9_TYPE='mojosetup'
ARCHIVE_GOG_9_MD5='dd5e33674222031eb7f6f5c9f26d7ee2'
ARCHIVE_GOG_9_VERSION='1.3.2.0-gog33084'
ARCHIVE_GOG_9_SIZE='4000000'

ARCHIVE_GOG_8='sunless_skies_1_2_4_0_015d561cx_31380.sh'
ARCHIVE_GOG_8_TYPE='mojosetup'
ARCHIVE_GOG_8_MD5='26aff59406f1210330cfe143f6c10575'
ARCHIVE_GOG_8_VERSION='1.2.4.0-gog31380'
ARCHIVE_GOG_8_SIZE='3900000'

ARCHIVE_GOG_7='sunless_skies_1_2_3_0_f3b4e1db_x_30226.sh'
ARCHIVE_GOG_7_TYPE='mojosetup'
ARCHIVE_GOG_7_MD5='edc2efd209096787f831e304da46258a'
ARCHIVE_GOG_7_VERSION='1.2.3.0-gog30226'
ARCHIVE_GOG_7_SIZE='3900000'

ARCHIVE_GOG_6='sunless_skies_1_2_1_3_0224b0c8_28905.sh'
ARCHIVE_GOG_6_TYPE='mojosetup'
ARCHIVE_GOG_6_MD5='fbfe10c4211b7b31cd1392d26b817c20'
ARCHIVE_GOG_6_VERSION='1.2.1.3-gog28905'
ARCHIVE_GOG_6_SIZE='3900000'

ARCHIVE_GOG_5='sunless_skies_1_2_1_2_b0df8add_28695.sh'
ARCHIVE_GOG_5_TYPE='mojosetup'
ARCHIVE_GOG_5_MD5='12a0c255956e4c563a721da55d832f9b'
ARCHIVE_GOG_5_VERSION='1.2.1.2-gog28695'
ARCHIVE_GOG_5_SIZE='3900000'

ARCHIVE_GOG_4='sunless_skies_1_2_0_4_20d30549_27995.sh'
ARCHIVE_GOG_4_TYPE='mojosetup'
ARCHIVE_GOG_4_MD5='209c6e10543513120d4d7eb35c61e2f2'
ARCHIVE_GOG_4_VERSION='1.2.0.4-gog27995'
ARCHIVE_GOG_4_SIZE='3600000'

ARCHIVE_GOG_3='sunless_skies_1_2_0_2_4cf00080_27469.sh'
ARCHIVE_GOG_3_TYPE='mojosetup'
ARCHIVE_GOG_3_MD5='ad52093137da318f4d7ce2c0033cb9ce'
ARCHIVE_GOG_3_VERSION='1.2.0.2-gog27469'
ARCHIVE_GOG_3_SIZE='3600000'

ARCHIVE_GOG_2='sunless_skies_1_2_0_0_157b386b_27304.sh'
ARCHIVE_GOG_2_TYPE='mojosetup'
ARCHIVE_GOG_2_MD5='f2223d46fca0d17c35ec724277f752a0'
ARCHIVE_GOG_2_VERSION='1.2.0.0-gog27304'
ARCHIVE_GOG_2_SIZE='3600000'

ARCHIVE_GOG_1='sunless_skies_1_1_9_6_e24eac9e_27177.sh'
ARCHIVE_GOG_1_TYPE='mojosetup'
ARCHIVE_GOG_1_MD5='dae9c1fa16c971613086c143fa45a540'
ARCHIVE_GOG_1_VERSION='1.1.9.6-gog27177'
ARCHIVE_GOG_1_SIZE='3600000'

ARCHIVE_GOG_0='sunless_skies_1_1_9_5_08b4e1b8_27040.sh'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_MD5='0fc87cf745c2db5d36e412c9265d1d76'
ARCHIVE_GOG_0_VERSION='1.1.9.5-gog27040'
ARCHIVE_GOG_0_SIZE='3600000'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Sunless?Skies.x86 Sunless?Skies_Data/Mono/x86 Sunless?Skies_Data/Plugins/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Sunless?Skies.x86_64 Sunless?Skies_Data/Mono/x86_64 Sunless?Skies_Data/Plugins/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Sunless?Skies_Data'

DATA_DIRS='./dlc ./logs'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Work around screen resolution detection issues
config_file="$HOME/.config/unity3d/Failbetter Games/Sunless Skies/prefs"
if [ ! -e "$config_file" ]; then
	mkdir --parents "${config_file%/*}"
	resolution=$(xrandr | awk "/\*/ {print $1}")
	cat > "$config_file" <<- EOF
	<unity_prefs version_major="1" version_minor="1">
	        <pref name="Screenmanager Resolution Height" type="int">${resolution%x*}</pref>
	        <pref name="Screenmanager Resolution Width" type="int">${resolution#*x}</pref>
	</unity_prefs>
	EOF
fi'
APP_MAIN_EXE_BIN32='Sunless Skies.x86'
APP_MAIN_EXE_BIN64='Sunless Skies.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Sunless Skies_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr libudev1 xrandr"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
