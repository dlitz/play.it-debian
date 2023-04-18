# Arch Linux - Write metadata for the given package
# USAGE: pkg_write_arch $package
pkg_write_arch() {
	local package
	package="$1"

	local package_path target
	package_path=$(package_path "$package")
	target="${package_path}/.PKGINFO"

	mkdir --parents "$(dirname "$target")"

	local package_id package_version package_maintainer package_builddate package_size package_architecture package_description package_provides package_fields_depend
	package_id=$(package_id "$package")
	package_version=$(package_version)
	package_maintainer=$(package_maintainer)
	package_builddate=$(date +%s)
	package_size=$(du --total --block-size=1 --summarize "$package_path" | tail --lines=1 | cut --fields=1)
	package_architecture=$(package_architecture_string "$package")
	package_description=$(package_description "$package")
	package_provides=$(archlinux_field_provides "$package")
	package_fields_depend=$(package_archlinux_fields_depend "$package")
	cat > "$target" <<- EOF
	# Generated by ./play.it $LIBRARY_VERSION
	pkgname = $package_id
	pkgver = $package_version
	packager = $package_maintainer
	builddate = $package_builddate
	size = $package_size
	arch = $package_architecture
	pkgdesc = $package_description
	$package_fields_depend
	EOF
	if [ -n "$package_provides" ]; then
		cat >> "$target" <<- EOF
		$package_provides
		EOF
	fi

	target="${package_path}/.INSTALL"

	if ! variable_is_empty "${package}_POSTINST_RUN"; then
		local package_postinst
		package_postinst=$(get_value "${package}_POSTINST_RUN")
		cat >> "$target" <<- EOF
		post_install() {
		$package_postinst
		}

		post_upgrade() {
		post_install
		}
		EOF
	fi

	if ! variable_is_empty "${package}_PRERM_RUN"; then
		local package_prerm
		package_prerm=$(get_value "${package}_PRERM_RUN")
		cat >> "$target" <<- EOF
		pre_remove() {
		$package_prerm
		}

		pre_upgrade() {
		pre_remove
		}
		EOF
	fi

	# Creates .MTREE
	local option_mtree
	option_mtree=$(option_value 'mtree')
	if [ "$option_mtree" -eq 1 ]; then
		package_archlinux_create_mtree "$package"
	fi
}

# Arch Linux - Build a list of packages
# USAGE: archlinux_packages_build $package[…]
archlinux_packages_build() {
	local package
	for package in "$@"; do
		archlinux_package_build_single "$package"
	done
}

# Arch Linux - Build a single package
# USAGE: archlinux_package_build_single $package
archlinux_package_build_single() {
	local package
	package="$1"

	local package_path
	package_path=$(package_path "$package")

	local option_output_dir package_name generated_package_path
	option_output_dir=$(option_value 'output-dir')
	package_name=$(package_name "$package")
	## The path to the generated package must be an absolute path,
	## because we do not run the tar call from the current directory.
	generated_package_path=$(realpath "${option_output_dir}/${package_name}")

	# Skip packages already existing,
	# unless called with --overwrite.
	local option_overwrite
	option_overwrite=$(option_value 'overwrite')
	if \
		[ "$option_overwrite" -eq 0 ] \
		&& [ -e "$generated_package_path" ]
	then
		information_package_already_exists "$package_name"
		return 0
	fi

	# Set basic tar options
	local tar_options
	tar_options='--create'
	if variable_is_empty 'PLAYIT_TAR_IMPLEMENTATION'; then
		guess_tar_implementation
	fi
	case "$PLAYIT_TAR_IMPLEMENTATION" in
		('gnutar')
			tar_options="$tar_options --group=root --owner=root"
		;;
		('bsdtar')
			tar_options="$tar_options --gname=root --uname=root"
		;;
		(*)
			error_unknown_tar_implementation
			return 1
		;;
	esac

	# Set compression setting
	local option_compression tar_compress_program
	option_compression=$(option_value 'compression')
	case "$option_compression" in
		('none')
			tar_compress_program=''
		;;
		('speed')
			tar_compress_program='zstd --fast=1'
		;;
		('size')
			tar_compress_program='zstd -19'
		;;
		('gzip'|'xz'|'bzip2'|'zstd')
			if ! version_is_at_least '2.23' "$target_version"; then
				tar_compress_program=$(archlinux_tar_compress_program_legacy "$option_compression")
			fi
		;;
	esac

	# Run the actual package generation, using tar
	local package_generation_return_code
	information_package_building "$package_name"
	package_generation_return_code=$(
		cd "$package_path"
		local package_contents
		package_contents='.PKGINFO *'
		if [ -e '.INSTALL' ]; then
			package_contents=".INSTALL $package_contents"
		fi
		if [ -e '.MTREE' ]; then
			package_contents=".MTREE $package_contents"
		fi
		if [ -n "$tar_compress_program" ]; then
			debug_external_command "tar $tar_options --use-compress-program=\"$tar_compress_program\" --file \"$generated_package_path\" $package_contents"
			set +o errexit
			tar $tar_options --use-compress-program="$tar_compress_program" --file "$generated_package_path" $package_contents
			package_generation_return_code=$?
			set -o errexit
		else
			debug_external_command "tar $tar_options --file \"$generated_package_path\" $package_contents"
			set +o errexit
			tar $tar_options --file "$generated_package_path" $package_contents
			package_generation_return_code=$?
			set -o errexit
		fi
		printf '%s' "$package_generation_return_code"
	)

	if [ $package_generation_return_code -ne 0 ]; then
		error_package_generation_failed "$package_name"
		return 1
	fi
}

# creates .MTREE in package
# USAGE: package_archlinux_create_mtree $pkg_path
# RETURNS: nothing
package_archlinux_create_mtree() {
	local package
	package="$1"

	local package_path
	package_path=$(package_path "$package")

	info_package_mtree_computation "$package"
	(
		cd "$package_path"
		# shellcheck disable=SC2030
		export LANG=C
		# shellcheck disable=SC2094
		find . -print0 | bsdtar \
			--create \
			--file - \
			--files-from - \
			--format=mtree \
			--no-recursion \
			--null \
			--options='!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link' \
			--exclude .MTREE \
			| gzip \
			--force \
			--no-name \
			--to-stdout \
			> .MTREE
	)
}

# Arch Linux - Print the contents of the "conflict" and "provides" fields
# USAGE: archlinux_field_provides $package
archlinux_field_provides() {
	local package
	package="$1"

	local package_provides
	package_provides=$(package_provides "$package")

	local package_architecture
	package_architecture=$(package_architecture "$package")
	if [ "$package_architecture" = '32' ]; then
		local package_id package_name_32
		package_id=$(package_id "$package")
		package_name_32=$(printf '%s' "$package_id" | sed 's/^lib32-//')
		package_provides="$package_provides
		$package_name_32"
	fi

	# Return early if there is no package name provided
	if [ -z "$package_provides" ]; then
		return 0
	fi

	printf 'conflict: %s\n' $package_provides
	printf 'provides: %s\n' $package_provides
}

# Arch Linux - Print list of "depend" fields
# USAGE: package_archlinux_fields_depend $package
package_archlinux_fields_depend() {
	local package
	package="$1"

	local dependencies_list dependency_string
	dependencies_list=$(dependencies_archlinux_full_list "$package")
	while read -r dependency_string; do
		if [ -z "$dependency_string" ]; then
			continue
		fi
		printf 'depend = %s\n' "$dependency_string"
	done <<- EOL
	$(printf '%s' "$dependencies_list")
	EOL
}

# Print the file name of the given package
# USAGE: package_name_archlinux $package
# RETURNS: the file name, as a string
package_name_archlinux() {
	local package
	package="$1"

	local package_id package_version package_architecture package_name
	package_id=$(package_id "$package")
	package_version=$(package_version)
	package_architecture=$(package_architecture_string "$package")
	package_name="${package_id}_${package_version}_${package_architecture}.pkg.tar"

	local option_compression
	option_compression=$(option_value 'compression')
	case $option_compression in
		('speed')
			package_name="${package_name}.zst"
		;;
		('size')
			package_name="${package_name}.zst"
		;;
		('gzip'|'xz'|'bzip2'|'zstd')
			if ! version_is_at_least '2.23' "$target_version"; then
				package_name=$(archlinux_package_name_legacy "$package_name" "$option_compression")
			fi
		;;
	esac

	printf '%s' "$package_name"
}

# Get the path to the directory where the given package is prepared,
# relative to the directory where all packages are stored
# USAGE: package_path_archlinux $package
# RETURNS: relative path to a directory, as a string
package_path_archlinux() {
	local package
	package="$1"

	local package_name package_path
	package_name=$(package_name "$package")
	package_path="${package_name%.pkg.tar*}"

	printf '%s' "$package_path"
}

# Print the architecture string of the given package, in the format expected by pacman
# USAGE: archlinux_package_architecture_string $package
# RETURNS: the package architecture, as one of the following values:
#          - x86_64
#          - any
archlinux_package_architecture_string() {
	local package
	package="$1"

	local package_architecture package_architecture_string
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32'|'64')
			package_architecture_string='x86_64'
		;;
		('all')
			package_architecture_string='any'
		;;
	esac

	printf '%s' "$package_architecture_string"
}

# Tweak the given package id to follow Arch Linux standards
# USAGE: archlinux_package_id $package_id
# RETURNS: the package id, as a non-empty string
archlinux_package_id() {
	local package_id
	package_id="$1"

	# Prepend "lib32-" to the ID of 32-bit packages.
	local package_architecture
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			package_id="lib32-${package_id}"
		;;
	esac

	printf '%s' "$package_id"
}
