# DOSBox - Print application-specific variables
# USAGE: dosbox_launcher_application_variables $application
dosbox_launcher_application_variables() {
	local application
	application="$1"

	local application_exe application_options
	application_exe=$(application_exe_escaped "$application")
	application_options=$(application_options "$application")

	cat <<- EOF
	# Set application-specific values
	APP_EXE='$application_exe'
	APP_OPTIONS="$application_options"
	EOF
}

# DOSBox - Print the actual call to dosbox
# USAGE: dosbox_launcher_run $application
dosbox_launcher_run() {
	local application
	application="$1"

	cat <<- EOF
	# Run the game
	cd "\$PATH_PREFIX"
	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit
	"\${PLAYIT_DOSBOX_BINARY:-dosbox}" -c "$(dosbox_launcher_instructions "$application")"
	game_exit_status=\$?
	set -o errexit
	EOF
}

# DOSBox - Print the list of commands executed by dosbox
# USAGE: dosbox_launcher_instructions $application
dosbox_launcher_instructions() {
	local application
	application="$1"

	cat <<- EOF
	mount c .
	c:
	$(dosbox_mount_disk_image)
	$(application_prerun "$application")
	\$APP_EXE \$APP_OPTIONS \$@
	$(application_postrun "$application")
	exit
	EOF
}

# DOSBox - Print the command mounting the disk image, if one is provided
# USAGE: dosbox_mount_disk_image
dosbox_mount_disk_image() {
	# Return early if no disk image is set
	if [ -z "$GAME_IMAGE" ]; then
		return 0
	fi

	local disk_image
	disk_image=$(dosbox_disk_image_path)
	case "$GAME_IMAGE_TYPE" in
		('cdrom')
			if [ -d "$disk_image" ]; then
				cat <<- EOF
				mount d $GAME_IMAGE -t cdrom
				EOF
			else
				cat <<- EOF
				imgmount d $GAME_IMAGE -t cdrom
				EOF
			fi
		;;
		('iso'|*)
			cat <<- EOF
			imgmount d $GAME_IMAGE -t iso -fs iso
			EOF
		;;
	esac
}

# DOSBox - Print the full path to the disk image
# USAGE: dosbox_disk_image_path
dosbox_disk_image_path() {
	local packages_list path_game_data
	packages_list=$(packages_get_list)
	path_game_data=$(path_game_data)

	# Loop over the list of packages, one should include the disk image.
	local package package_path image_path
	for package in $packages_list; do
		package_path=$(package_get_path "$package")
		image_path="${package_path}${path_game_data}/${GAME_IMAGE}"
		if [ -e "$image_path" ]; then
			printf '%s' "$image_path"
			return 0
		fi
	done

	# Exit with a failure state if the disk image has not been found.
	return 1
}
