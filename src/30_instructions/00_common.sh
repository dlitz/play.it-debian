# print installation instructions
# USAGE: print_instructions $pkg[…]
print_instructions() {
	# If no explicit list of packages has been passed, fall back on handling all packages
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		print_instructions $(packages_get_list)
		return 0
	fi

	# Print the list of library dependencies that have been skipped
	if [ -n "$(dependencies_unknown_libraries_list)" ]; then
		warning_dependencies_unknown_libraries
	fi

	# Sort packages by architecture
	local package package_architecture packages_list_32 packages_list_64 packages_list_all
	for package in "$@"; do
		package_architecture=$(package_get_architecture "$package")
		case "$package_architecture" in
			('32')
				packages_list_32="$packages_list_32 $package"
			;;
			('64')
				packages_list_64="$packages_list_64 $package"
			;;
			(*)
				packages_list_all="$packages_list_all $package"
			;;
		esac
	done

	if [ "$OPTION_PACKAGE" = 'gentoo' ] && [ -n "$GENTOO_OVERLAYS" ]; then
		information_required_gentoo_overlays "$GENTOO_OVERLAYS"
	fi
	if [ "$OPTION_PACKAGE" = 'egentoo' ]; then
		info_local_overlay_gentoo
	fi

	local game_name
	game_name=$(game_name)
	information_installation_instructions_common "$game_name"

	# If both 32-bit and 64-bit binaries packages are available,
	# display instructions on how to install one build or the other.
	# If only a single architecture is available, display standard instructions.
	if [ -n "$packages_list_32" ] && [ -n "$packages_list_64" ]; then
		print_instructions_architecture_specific '32' $packages_list_all $packages_list_32
		print_instructions_architecture_specific '64' $packages_list_all $packages_list_64
	else
		case $OPTION_PACKAGE in
			('arch')
				print_instructions_arch "$@"
			;;
			('deb')
				print_instructions_deb "$@"
			;;
			('gentoo')
				print_instructions_gentoo "$@"
			;;
			('egentoo')
				print_instructions_egentoo "$@"
			;;
			(*)
				error_option_invalid 'package' "$OPTION_PACKAGE"
				return 1
			;;
		esac
	fi
	printf '\n'
}

# print installation instructions, for a given architecture
# USAGE: print_instructions_architecture_specific $pkg[…]
# CALLS: print_instructions_arch print_instructions_deb print_instructions_gentoo
print_instructions_architecture_specific() {
	local architecture_variant
	architecture_variant="${1}-bit"
	information_installation_instructions_variant "$architecture_variant"
	shift 1
	case $OPTION_PACKAGE in
		('arch')
			print_instructions_arch "$@"
		;;
		('deb')
			print_instructions_deb "$@"
		;;
		('gentoo')
			print_instructions_gentoo "$@"
		;;
		('egentoo')
			print_instructions_egentoo "$@"
		;;
		(*)
			error_invalid_argument 'OPTION_PACKAGE' 'print_instructions'
			return 1
		;;
	esac
}

