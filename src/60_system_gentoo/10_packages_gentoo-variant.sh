# Gentoo - Print path to ebuild file for the given package
# USAGE: gentoo_ebuild_path $package
# RETURN: the path to the .ebuild file
gentoo_ebuild_path() {
	local package
	package="$1"

	local package_id package_name
	package_id=$(package_id "$package")
	package_name=$(package_name "$package")

	printf '%s/%s/gentoo-overlay/games-playit/%s/%s.ebuild' "$PLAYIT_WORKDIR" "$package" "$package_id" "${package_name%.tbz2}"
}

# write .ebuild package meta-data
# USAGE: pkg_write_gentoo
pkg_write_gentoo() {
	###
	# TODO
	# $pkg should be passed as a function argument, not inherited from the calling function
	###

	local package_path package_id
	package_path=$(package_path "$pkg")
	package_id=$(package_id "$pkg")

	mkdir --parents \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/metadata" \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/profiles" \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/${package_id}/files"
	printf '%s\n' "masters = gentoo" > "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/metadata/layout.conf"
	printf '%s\n' 'games-playit' > "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/profiles/categories"
	ln --symbolic --force --no-target-directory "$package_path" "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/${package_id}/files/install"
	local package_version target
	package_version=$(package_version)
	target=$(gentoo_ebuild_path "$pkg")

	cat > "$target" <<- EOF
	EAPI=7
	RESTRICT="fetch strip binchecks"
	EOF
	local package_architecture pkg_architectures
	package_architecture=$(package_architecture "$pkg")
	case "$package_architecture" in
		('32')
			pkg_architectures='-* x86 amd64'
		;;
		('64')
			pkg_architectures='-* amd64'
		;;
		(*)
			pkg_architectures='x86 amd64' #data packages
		;;
	esac
	local package_description
	package_description=$(package_description "$pkg")
	cat >> "$target" <<- EOF
	KEYWORDS="$pkg_architectures"
	DESCRIPTION="${package_description}"
	SLOT="0"
	EOF

	# fakeroot >=1.25.1 considers all files belong to root by default
	local field_rdepend
	field_rdepend=$(package_gentoo_field_rdepend "$pkg")
	cat >> "$target" <<- EOF
	RDEPEND="$field_rdepend"

	src_unpack() {
		mkdir --parents "\$S"
	}
	src_install() {
		cp --recursive --link \$FILESDIR/install/* \$ED/
	}
	EOF

	if ! variable_is_empty "${pkg}_POSTINST_RUN"; then
		local postinst_command
		postinst_command=$(get_value "${pkg}_POSTINST_RUN")
		cat >> "$target" <<- EOF
		pkg_postinst() {
		$postinst_command
		}
		EOF
	fi

	if ! variable_is_empty "${pkg}_PRERM_RUN"; then
		local prerm_command
		prerm_command=$(get_value "${pkg}_PRERM_RUN")
		cat >> "$target" <<- EOF
		pkg_prerm() {
		$prerm_command
		}
		EOF
	fi
}

# Gentoo ("gentoo" variant) - Build a list of packages
# USAGE: gentoo_packages_build $package[…]
gentoo_packages_build() {
	local package
	for package in "$@"; do
		gentoo_package_build_single "$package"
	done
}

# Gentoo ("gentoo" variant) - Build a single package
# USAGE: gentoo_package_build_single $package
gentoo_package_build_single() {
	local package
	package="$1"

	local package_path package_name generated_package_path generated_package_directory
	package_path=$(package_path "$package")
	package_name=$(package_name "$package")
	generated_package_path="${package_path}.tbz2"
	generated_package_directory=$(dirname "$generated_package_path")

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

	# Set compression setting
	local option_compression binkpg_compress
	option_compression=$(option_value 'compression')
	case "$option_compression" in
		('none')
			binkpg_compress='cat'
		;;
		('speed')
			binkpg_compress='gzip'
		;;
		('size')
			binkpg_compress='bzip2'
		;;
		('auto')
			binkpg_compress=''
		;;
		('gzip'|'xz'|'bzip2'|'zstd'|'lzip')
			if ! version_is_at_least '2.23' "$target_version"; then
				binkpg_compress=$(gentoo_package_binkpg_compress_legacy "$option_compression")
			fi
		;;
	esac

	# Run the actual package generation, using ebuild
	local package_generation_return_code
	information_package_building "$package_name"
	mkdir --parents "${PLAYIT_WORKDIR}/portage-tmpdir"
	local ebuild_path
	ebuild_path=$(gentoo_ebuild_path "$package")
	ebuild "$ebuild_path" manifest 1>/dev/null
	if [ -n "$binkpg_compress" ]; then
		debug_external_command "PORTAGE_TMPDIR=\"${PLAYIT_WORKDIR}/portage-tmpdir\" PKGDIR=\"${PLAYIT_WORKDIR}/gentoo-pkgdir\" BINPKG_COMPRESS=\"$binkpg_compress\" fakeroot -- ebuild \"$ebuild_path\" package 1>/dev/null"
		set +o errexit
		PORTAGE_TMPDIR="${PLAYIT_WORKDIR}/portage-tmpdir" PKGDIR="${PLAYIT_WORKDIR}/gentoo-pkgdir" BINPKG_COMPRESS="$binkpg_compress" fakeroot -- ebuild "$ebuild_path" package 1>/dev/null
		package_generation_return_code=$?
		set -o errexit
	else
		debug_external_command "PORTAGE_TMPDIR=\"${PLAYIT_WORKDIR}/portage-tmpdir\" PKGDIR=\"${PLAYIT_WORKDIR}/gentoo-pkgdir\" fakeroot -- ebuild \"$ebuild_path\" package 1>/dev/null"
		set +o errexit
		PORTAGE_TMPDIR="${PLAYIT_WORKDIR}/portage-tmpdir" PKGDIR="${PLAYIT_WORKDIR}/gentoo-pkgdir" fakeroot -- ebuild "$ebuild_path" package 1>/dev/null
		package_generation_return_code=$?
		set -o errexit
	fi

	if [ $package_generation_return_code -ne 0 ]; then
		error_package_generation_failed "$package_name"
		return 1
	fi

	mkdir --parents "$generated_package_directory"
	mv "${PLAYIT_WORKDIR}/gentoo-pkgdir/games-playit/${package_name}" "$generated_package_path"
	rm --recursive "${PLAYIT_WORKDIR}/portage-tmpdir"
}

# Print the file name of the given package
# USAGE: package_name_gentoo $package
# RETURNS: the file name, as a string
package_name_gentoo() {
	local package
	package="$1"

	local package_id package_version package_name
	package_id=$(package_id "$package")
	package_version=$(package_version)
	package_name="${package_id}-${package_version}.tbz2"

	# Avoid paths collisions when building multiple architecture variants for a same package
	local packages_list current_package current_package_id
	packages_list=$(packages_get_list)
	for current_package in $packages_list; do
		current_package_id=$(package_id "$current_package")
		if \
			[ "$current_package" != "$package" ] \
			&& [ "$current_package_id" = "$package_id" ]
		then
			local package_architecture
			package_architecture=$(package_architecture_string "$package")
			package_name="${package_architecture}/${package_name}"
			break
		fi
	done

	printf '%s' "$package_name"
}

# Get the path to the directory where the given package is prepared,
# relative to the directory where all packages are stored
# USAGE: package_path_gentoo $package
# RETURNS: relative path to a directory, as a string
package_path_gentoo() {
	local package
	package="$1"

	local package_name package_path
	package_name=$(package_name "$package")
	package_path="${package_name%.tbz2}"

	printf '%s' "$package_path"
}

# Tweak the given package version string to ensure it is compatible with portage
# USAGE: gentoo_package_version $package_version
# RETURNS: the package version, as a non-empty string
gentoo_package_version() {
	assert_not_empty 'script_version' 'gentoo_package_version'

	local package_version
	package_version="$1"

	set +o errexit
	package_version=$(
		printf '%s' "$package_version" | \
			grep --extended-regexp --only-matching '^([0-9]{1,18})(\.[0-9]{1,18})*[a-z]?'
	)
	set -o errexit

	if [ -z "$package_version" ]; then
		package_version='1.0'
	fi

	printf '$%s_p%s' "$package_version" "$(printf '%s' "$script_version" | sed 's/\.//g')"
}

# Print the architecture string of the given package, in the format expected by portage
# USAGE: gentoo_package_architecture_string $package
# RETURNS: the package architecture, as one of the following values:
#          - x86
#          - amd64
#          - data (dummy value)
gentoo_package_architecture_string() {
	local package
	package="$1"

	local package_architecture package_architecture_string
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			package_architecture_string='x86'
		;;
		('64')
			package_architecture_string='amd64'
		;;
		('all')
			# We could put anything here, it should not be used for package metadata.
			package_architecture_string='data'
		;;
	esac

	printf '%s' "$package_architecture_string"
}

# Tweak the given package id to ensure compatibility with portage
# USAGE: gentoo_package_id $package_id
# RETURNS: the package id, as a non-empty string
gentoo_package_id() {
	local package_id
	package_id="$1"

	# Avoid mixups between numbers in package id and version number.
	printf '%s' "$package_id" | sed 's/-/_/g'
}