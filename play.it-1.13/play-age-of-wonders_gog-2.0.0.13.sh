#!/bin/sh -e

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
# conversion script for the Age of Wonders installer sold on GOG.com
# build a .deb package from the Windows installer
# tested on Debian, should work on any .deb-based distribution
#
# send your bug reports to vv221@dotslashplay.it
# start the e-mail subject by "./play.it" to avoid it being flagged as spam
###

script_version=20160209.1

# Set game-specific variables

SCRIPT_DEPS_HARD='fakeroot innoextract realpath'
SCRIPT_DEPS_SOFT='icotool wrestool'

GAME_ID='age-of-wonders'
GAME_ID_SHORT='aow'
GAME_NAME='Age of Wonders'
GAME_NAME_SHORT='AoW'

GAME_ARCHIVE1='setup_age_of_wonders_2.0.0.13.exe'
GAME_ARCHIVE1_MD5='9ee2ccc5223c41306cf6695fc09a5634'
GAME_ARCHIVE_FULLSIZE='330000'
PKG_REVISION='gog2.0.0.13'

INSTALLER_JUNK='app/gameuxinstallhelper.dll app/gfw_high.ico app/goggame.dll app/gog.ico app/support.ico'
INSTALLER_DOC='app/quickstart.pdf app/readme.txt tmp/*eula.txt'
INSTALLER_GAME='app/*'

GAME_CACHE_DIRS=''
GAME_CACHE_FILES=''
GAME_CACHE_FILES_POST=''
GAME_CONFIG_DIRS=''
GAME_CONFIG_FILES=''
GAME_CONFIG_FILES_POST=''
GAME_DATA_DIRS='./emailin ./emailout ./save ./user'
GAME_DATA_FILES=''
GAME_DATA_FILES_POST=''

APP_COMMON_ID="${GAME_ID_SHORT}-common.sh"

MENU_NAME="${GAME_NAME}"
MENU_NAME_FR="${GAME_NAME}"
MENU_CAT='Games'

APP1_ID="${GAME_ID}"
APP1_EXE='./aow.exe'
APP1_ICON='./age of wonders.ico'
APP1_ICON_RES='32x32'
APP1_NAME="${GAME_NAME_SHORT}: ${GAME_NAME}"
APP1_NAME_FR="${GAME_NAME_SHORT}: ${GAME_NAME}"

APP2_ID="${GAME_ID}_editor"
APP2_EXE='./aowed.exe'
APP2_ICON='./aowed.exe'
APP2_ICON_RES='32x32'
APP2_NAME="${GAME_NAME_SHORT}: editor"
APP2_NAME_FR="${GAME_NAME_SHORT}: éditeur"

PKG1_ID="${GAME_ID}"
PKG1_ARCH='i386'
PKG1_VERSION='1.36.0053'
PKG1_CONFLICTS=''
PKG1_DEPS='wine:amd64 | wine, wine32 | wine-bin | wine1.6-i386 | wine1.4-i386 | wine-staging-i386'
PKG1_RECS=''
PKG1_DESC="${GAME_NAME}
 package built from GOG.com installer
 ./play.it script version ${script_version}"

# Load common functions

TARGET_LIB_VERSION='1.13'

if [ -z "${PLAYIT_LIB}" ]; then
	PLAYIT_LIB='./play-anything.sh'
fi

if ! [ -e "${PLAYIT_LIB}" ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'play-anything.sh not found.\n'
	printf 'It must be placed in the same directory than this script.\n\n'
	exit 1
fi

LIB_VERSION="$(grep '^# library version' "${PLAYIT_LIB}" | cut -d' ' -f4 | cut -d'.' -f1,2)"

if [ ${LIB_VERSION%.*} -ne ${TARGET_LIB_VERSION%.*} ] || [ ${LIB_VERSION#*.} -lt ${TARGET_LIB_VERSION#*.} ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'Wrong version of play-anything.\n'
	printf 'It must be at least %s ' "${TARGET_LIB_VERSION}"
	printf 'but lower than %s.\n\n' "$((${TARGET_LIB_VERSION%.*}+1)).0"
	exit 1
fi

. "${PLAYIT_LIB}"

# Set extra variables

NO_ICON=0

GAME_ARCHIVE_CHECKSUM_DEFAULT='md5sum'
PKG_COMPRESSION_DEFAULT='none'
PKG_PREFIX_DEFAULT='/usr/local'

fetch_args "$@"

set_checksum
set_compression
set_prefix

check_deps_hard ${SCRIPT_DEPS_HARD}
check_deps_soft ${SCRIPT_DEPS_SOFT}

game_mkdir 'PKG_TMPDIR' "$(mktemp -u ${GAME_ID_SHORT}.XXXXX)" "$((${GAME_ARCHIVE_FULLSIZE}*2))"
game_mkdir 'PKG1_DIR' "${PKG1_ID}_${PKG1_VERSION}-${PKG_REVISION}_${PKG1_ARCH}" "$((${GAME_ARCHIVE_FULLSIZE}*2))"

PATH_BIN="${PKG_PREFIX}/games"
PATH_DESK='/usr/local/share/applications'
PATH_DESK_DIR='/usr/local/share/desktop-directories'
PATH_DESK_MERGED='/etc/xdg/menus/applications-merged'
PATH_DOC="${PKG_PREFIX}/share/doc/${GAME_ID}"
PATH_GAME="${PKG_PREFIX}/share/games/${GAME_ID}"
PATH_ICON_BASE='/usr/local/share/icons/hicolor'

printf '\n'

set_target '1' 'gog.com'

printf '\n'

# Check target file integrity

if [ "${GAME_ARCHIVE_CHECKSUM}" = 'md5sum' ]; then
	checksum "${GAME_ARCHIVE}" 'defaults' "${GAME_ARCHIVE1_MD5}"
fi

# Extract game data

build_pkg_dirs '1' "${PATH_BIN}" "${PATH_DOC}" "${PATH_DESK}" "${PATH_DESK_DIR}" "${PATH_DESK_MERGED}" "${PATH_GAME}"

print wait

extract_data 'inno' "${GAME_ARCHIVE}" "${PKG_TMPDIR}" 'quiet'

for file in ${INSTALLER_JUNK}; do
	rm -rf "${PKG_TMPDIR}"/${file}
done

for file in ${INSTALLER_DOC}; do
	mv "${PKG_TMPDIR}"/${file} "${PKG1_DIR}${PATH_DOC}"
done

for file in ${INSTALLER_GAME}; do
	mv "${PKG_TMPDIR}"/${file} "${PKG1_DIR}${PATH_GAME}"
done

if [ "${NO_ICON}" = '0' ]; then
	extract_icons "${APP1_ID}" "${APP1_ICON}" "${APP1_ICON_RES}" "${PKG_TMPDIR}"
	extract_icons "${APP2_ID}" "${APP2_ICON}" "${APP2_ICON_RES}" "${PKG_TMPDIR}"
fi

rm -rf "${PKG_TMPDIR}"

print done

# Write launchers

write_bin_wine_common "${PKG1_DIR}${PATH_BIN}/${APP_COMMON_ID}"
write_bin_wine_cfg "${PKG1_DIR}${PATH_BIN}/${GAME_ID_SHORT}-winecfg"
write_bin_wine "${PKG1_DIR}${PATH_BIN}/${APP1_ID}" "${APP1_EXE}" '' '' "${APP1_NAME}"
write_bin_wine "${PKG1_DIR}${PATH_BIN}/${APP2_ID}" "${APP2_EXE}" '' '' "${APP2_NAME}"

write_menu "${GAME_ID}" "${MENU_NAME}" "${MENU_NAME_FR}" "${MENU_CAT}" "${PKG1_DIR}${PATH_DESK_DIR}/${GAME_ID}.directory" "${PKG1_DIR}${PATH_DESK_MERGED}/${GAME_ID}.menu" 'wine' "${APP1_ID}" "${APP2_ID}"
write_desktop "${APP1_ID}" "${APP1_NAME}" "${APP1_NAME_FR}" "${PKG1_DIR}${PATH_DESK}/${APP1_ID}.desktop" '' 'wine'
write_desktop "${APP2_ID}" "${APP2_NAME}" "${APP2_NAME_FR}" "${PKG1_DIR}${PATH_DESK}/${APP2_ID}.desktop" '' 'wine'

printf '\n'

# Build package

write_pkg_debian "${PKG1_DIR}" "${PKG1_ID}" "${PKG1_VERSION}-${PKG_REVISION}" "${PKG1_ARCH}" "${PKG1_CONFLICTS}" "${PKG1_DEPS}" "${PKG1_RECS}" "${PKG1_DESC}"

build_pkg "${PKG1_DIR}" "${PKG1_DESC}" "${PKG_COMPRESSION}"

print_instructions "${PKG1_DESC}" "${PKG1_DIR}"

printf '\n%s ;)\n\n' "$(l10n 'have_fun')"

exit 0
