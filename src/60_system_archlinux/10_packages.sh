# write .pkg.tar package meta-data
# USAGE: pkg_write_arch
pkg_write_arch() {
	###
	# TODO
	# $pkg should be passed as a function argument, not inherited from the calling function
	###

	local package_path
	package_path=$(package_path "$pkg")

	local pkg_size
	pkg_size=$(du --total --block-size=1 --summarize "$package_path" | tail --lines=1 | cut --fields=1)
	local target
	target="${package_path}/.PKGINFO"

	mkdir --parents "$(dirname "$target")"

	local package_id
	package_id=$(package_get_id "$pkg")
	cat > "$target" <<- EOF
	# Generated by ./play.it $LIBRARY_VERSION
	pkgname = $package_id
	pkgver = $(packages_get_version "$ARCHIVE")
	packager = $(packages_get_maintainer)
	builddate = $(date +%s)
	size = $pkg_size
	arch = $(package_get_architecture_string "$pkg")
	pkgdesc = $(package_get_description "$pkg")
	$(package_archlinux_fields_depend "$pkg")
	EOF

	if [ -n "$(package_get_provide "$pkg")" ]; then
		cat >> "$target" <<- EOF
		conflict = $(package_get_provide "$pkg")
		provides = $(package_get_provide "$pkg")
		EOF
	fi

	if [ "$(package_get_architecture "$pkg")" = '32' ]; then
		cat >> "$target" <<- EOF
		conflict = $(printf '%s' "$package_id" | sed 's/^lib32-//')
		provides = $(printf '%s' "$package_id" | sed 's/^lib32-//')
		EOF
	fi

	target="${package_path}/.INSTALL"

	if ! variable_is_empty "${pkg}_POSTINST_RUN"; then
		cat >> "$target" <<- EOF
		post_install() {
		$(get_value "${pkg}_POSTINST_RUN")
		}

		post_upgrade() {
		post_install
		}
		EOF
	fi

	if ! variable_is_empty "${pkg}_PRERM_RUN"; then
		cat >> "$target" <<- EOF
		pre_remove() {
		$(get_value "${pkg}_PRERM_RUN")
		}

		pre_upgrade() {
		pre_remove
		}
		EOF
	fi

	# Creates .MTREE
	if [ "$MTREE" -eq 1 ]; then
		package_archlinux_create_mtree "$pkg"
	fi
}

# build .pkg.tar package
# USAGE: pkg_build_arch $pkg_path
# NEEDED VARS: (OPTION_COMPRESSION) (LANG) PLAYIT_WORKDIR
# CALLED BY: build_pkg
pkg_build_arch() {
	local pkg_filename
	pkg_filename=$(realpath "$OPTION_OUTPUT_DIR/$(basename "$1").pkg.tar")

	if [ -e "$pkg_filename" ] && [ $OVERWRITE_PACKAGES -ne 1 ]; then
		information_package_already_exists "$(basename "$pkg_filename")"
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg?}_PKG
		return 0
	fi

	local tar_options
	tar_options='--create'
	if [ -z "$PLAYIT_TAR_IMPLEMENTATION" ]; then
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

	case $OPTION_COMPRESSION in
		('gzip')
			tar_options="$tar_options --gzip"
			pkg_filename="${pkg_filename}.gz"
		;;
		('xz')
			export XZ_DEFAULTS="${XZ_DEFAULTS:=--threads=0}"
			tar_options="$tar_options --xz"
			pkg_filename="${pkg_filename}.xz"
		;;
		('bzip2')
			tar_options="$tar_options --bzip2"
			pkg_filename="${pkg_filename}.bz2"
		;;
		('zstd')
			tar_options="$tar_options --zstd"
			pkg_filename="${pkg_filename}.zst"
		;;
		('none') ;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_build_arch'
			return 1
		;;
	esac

	information_package_building "$(basename "$pkg_filename")"

	(
		cd "$1"
		local files
		files='.PKGINFO *'
		if [ -e '.INSTALL' ]; then
			files=".INSTALL $files"
		fi
		if [ -e '.MTREE' ]; then
			files=".MTREE $files"
		fi
		debug_external_command "tar $tar_options --file \"$pkg_filename\" $files"
		tar $tar_options --file "$pkg_filename" $files
	)

	eval ${pkg}_PKG=\"$pkg_filename\"
	export ${pkg?}_PKG
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

# Arch Linux - Print list of "depend" fields
# USAGE: package_archlinux_fields_depend $package
package_archlinux_fields_depend() {
	local package
	package="$1"

	local dependency_string
	while read -r dependency_string; do
		if [ -z "$dependency_string" ]; then
			continue
		fi
		printf 'depend = %s\n' "$dependency_string"
	done <<- EOL
	$(dependencies_archlinux_full_list "$package")
	EOL
}

# Print the file name of the given package
# USAGE: package_name_archlinux $package
# RETURNS: the file name, as a string
package_name_archlinux() {
	local package
	package="$1"

	assert_not_empty 'ARCHIVE' 'package_name_archlinux'
	assert_not_empty 'OPTION_COMPRESSION' 'package_name_archlinux'

	local package_id package_version package_architecture package_name
	package_id=$(package_get_id "$package")
	package_version=$(packages_get_version "$ARCHIVE")
	package_architecture=$(package_get_architecture_string "$package")
	package_name="${package_id}_${package_version}_${package_architecture}.tar"
	case "$OPTION_COMPRESSION" in
		('gzip')
			package_name="${package_name}.gz"
		;;
		('xz')
			package_name="${package_name}.xz"
		;;
		('bzip2')
			package_name="${package_name}.bz2"
		;;
		('zstd')
			package_name="${package_name}.zst"
		;;
		('none')
			# No compression extension to append.
		;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'package_name_archlinux'
			return 1
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
	package_path="${package_name%.tar*}"

	printf '%s' "$package_path"
}
