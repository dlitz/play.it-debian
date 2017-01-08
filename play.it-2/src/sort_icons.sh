# create icons tree
# USAGE: sort_icons $app
# NEEDED VARS: $app_ID, $app_ICON_RES, PKG, $PKG_PATH, PACKAGE_TYPE
# CALLS: sort_icons_arch, sort_icons_deb, sort_icons_tar
sort_icons() {
for app in $@; do
	testvar "$app" 'APP' || liberror 'app' 'sort_icons'
	local app_id="$(eval echo \$${app}_ID)"
	if [ -z "$app_id" ]; then
		app_id="$GAME_ID"
	fi
	local icon_res="$(eval echo \$${app}_ICON_RES)"
	local pkg_path="$(eval echo \$${PKG}_PATH)"
	case $PACKAGE_TYPE in
		('arch')
			sort_icons_arch
		;;
		('deb')
			sort_icons_deb
		;;
		(*)
			liberror 'PACKAGE_TYPE' 'sort_icons'
		;;
	esac
done
}

# create icons tree for .pkg.tar.xz package
# USAGE: sort_icons_arch
# NEEDED VARS: PATH_ICON_BASE, PLAYIT_WORKDIR
# CALLED BY: sort_icons
sort_icons_arch() {
	for res in $icon_res; do
		path_icon="${PATH_ICON_BASE}/${res}/apps"
		mkdir -p "${pkg_path}${path_icon}"
		for file in "${PLAYIT_WORKDIR}"/icons/*${res}x*.png; do
			mv "${file}" "${pkg_path}${path_icon}/${app_id}.png"
		done
	done
}

# create icons tree for .deb package
# USAGE: sort_icons_deb
# NEEDED VARS: PATH_ICON_BASE, PLAYIT_WORKDIR
# CALLED BY: sort_icons
sort_icons_deb() {
	for res in $icon_res; do
		path_icon="${PATH_ICON_BASE}/${res}/apps"
		mkdir -p "${pkg_path}${path_icon}"
		for file in "${PLAYIT_WORKDIR}"/icons/*${res}x*.png; do
			mv "${file}" "${pkg_path}${path_icon}/${app_id}.png"
		done
	done
}

