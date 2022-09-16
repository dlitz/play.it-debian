# check script dependencies
# USAGE: check_deps
# NEEDED VARS: (ARCHIVE) (OPTION_CHECKSUM) (OPTION_PACKAGE) (SCRIPT_DEPS)
# CALLS: check_deps_7z error_dependency_not_found icons_list_dependencies
check_deps() {
	local archive_type

	if [ "$ARCHIVE" ]; then
		archive_type=$(archive_get_type "$ARCHIVE")
		case "$archive_type" in
			('cabinet')
				SCRIPT_DEPS="$SCRIPT_DEPS cabextract"
			;;
			('debian')
				SCRIPT_DEPS="$SCRIPT_DEPS debian"
			;;
			('innosetup1.7'*)
				SCRIPT_DEPS="$SCRIPT_DEPS innoextract1.7"
			;;
			('innosetup'*)
				SCRIPT_DEPS="$SCRIPT_DEPS innoextract"
			;;
			('installshield')
				SCRIPT_DEPS="$SCRIPT_DEPS unshield"
			;;
			('lha')
				SCRIPT_DEPS="$SCRIPT_DEPS lha"
			;;
			('nixstaller')
				SCRIPT_DEPS="$SCRIPT_DEPS gzip tar unxz"
			;;
			('msi')
				SCRIPT_DEPS="$SCRIPT_DEPS msiextract"
			;;
			('mojosetup'|'iso')
				SCRIPT_DEPS="$SCRIPT_DEPS bsdtar"
			;;
			('rar'|'nullsoft-installer')
				SCRIPT_DEPS="$SCRIPT_DEPS unar"
			;;
			('tar')
				SCRIPT_DEPS="$SCRIPT_DEPS tar"
			;;
			('tar.gz')
				SCRIPT_DEPS="$SCRIPT_DEPS gzip tar"
			;;
			('tar.xz')
				SCRIPT_DEPS="$SCRIPT_DEPS xz tar"
			;;
			('zip'|'zip_unclean'|'mojosetup_unzip')
				SCRIPT_DEPS="$SCRIPT_DEPS unzip"
			;;
		esac
	fi
	case "$OPTION_COMPRESSION" in
		('gzip')
			SCRIPT_DEPS="$SCRIPT_DEPS gzip"
		;;
		('xz')
			SCRIPT_DEPS="$SCRIPT_DEPS xz"
		;;
		('bzip2')
			SCRIPT_DEPS="$SCRIPT_DEPS bzip2"
		;;
		('zstd')
			SCRIPT_DEPS="$SCRIPT_DEPS zstd"
		;;
		('lz4')
			SCRIPT_DEPS="$SCRIPT_DEPS lz4"
		;;
		('lzip')
			SCRIPT_DEPS="$SCRIPT_DEPS lzip"
		;;
		('lzop')
			SCRIPT_DEPS="$SCRIPT_DEPS lzop"
		;;
	esac
	if [ "$OPTION_CHECKSUM" = 'md5sum' ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS md5sum"
	fi
	if [ "$OPTION_PACKAGE" = 'deb' ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS fakeroot dpkg"
	fi
	if [ "$OPTION_PACKAGE" = 'gentoo' ]; then
		# fakeroot-ng doesn't work anymore, fakeroot >=1.25.1 does
		SCRIPT_DEPS="$SCRIPT_DEPS fakeroot:>=1.25.1 ebuild"
	fi
	for dep in $SCRIPT_DEPS; do
		case $dep in
			('7z')
				check_deps_7z
			;;
			('innoextract'*)
				check_deps_innoextract "$dep"
			;;
			('lha')
				check_deps_lha
			;;
			('debian')
				check_deps_debian
			;;
			('fakeroot'*)
				check_deps_fakeroot "$dep"
			;;
			('lzip')
				get_lzip_implementation >/dev/null
			;;
			(*)
				if ! command -v "$dep" >/dev/null 2>&1; then
					error_dependency_not_found "$dep"
					return 1
				fi
			;;
		esac
	done

	# Check for the dependencies required to extract the icons
	unset ICONS_DEPS
	icons_list_dependencies
	for dep in $ICONS_DEPS; do
		if ! command -v "$dep" >/dev/null 2>&1; then
			case "$OPTION_ICONS" in
				('yes')
					error_icon_dependency_not_found "$dep"
					return 1
				;;
				('auto')
					warning_icon_dependency_not_found "$dep"
					export SKIP_ICONS=1
					break
				;;
			esac
		fi
	done
}

# check presence of a software to handle .7z archives
# USAGE: check_deps_7z
# CALLS: error_dependency_not_found
# CALLED BY: check_deps
check_deps_7z() {
	for command in '7zr' '7za' 'unar'; do
		if command -v "$command" >/dev/null 2>&1; then
			return 0
		fi
	done
	error_dependency_not_found '7zr'
	return 1
}

# check presence of a software to handle LHA (.lzh) archives
# USAGE: check_deps_lha
# CALLS: error_dependency_not_found
# CALLED BY: check_deps
check_deps_lha() {
	for command in 'lha' 'bsdtar'; do
		if command -v "$command" >/dev/null 2>&1; then
			return 0
		fi
	done
	error_dependency_not_found 'lha'
	return 1
}

# check presence of a software to handle .deb packages
# USAGE: check_deps_debian
# CALLS: error_dependency_not_found
# CALLED BY: check_deps
check_deps_debian() {
	for command in 'dpkg-deb' 'bsdtar' 'unar'; do
		if command -v "$command" >/dev/null 2>&1; then
			return 0
		fi
	done
	if command -v 'tar' >/dev/null 2>&1; then
		for command in '7z' '7zr' 'ar'; do
			if command -v "$command" >/dev/null 2>&1; then
				return 0
			fi
		done
	fi
	error_dependency_not_found 'dpkg-deb'
	return 1
}

# check innoextract presence, optionally in a given minimum version
# USAGE: check_deps_innoextract $keyword
# CALLS: error_dependency_not_found
# CALLED BYD: check_deps
check_deps_innoextract() {
	local keyword
	local name
	keyword="$1"
	case "$keyword" in
		('innoextract1.7')
			name='innoextract (>= 1.7)'
		;;
		(*)
			name='innoextract'
		;;
	esac
	if ! command -v 'innoextract' >/dev/null 2>&1; then
		error_dependency_not_found "$name"
		return 1
	fi

	# Check innoextract version
	local innoextract_version
	innoextract_version=$(LANG=C innoextract --version | head --lines=1 | cut --delimiter=' ' --fields=2)
	case "$keyword" in
		('innoextract1.7')
			if ! version_is_at_least '1.7' "$innoextract_version"; then
				error_dependency_not_found "$name"
				return 1
			fi
		;;
	esac

	return 0
}

check_deps_fakeroot() {
	local keyword
	local name
	keyword="$1"
	case "$keyword" in
		('fakeroot:>=1.25.1')
			name='fakeroot (>=1.25.1)'
		;;
		(*)
			name='fakeroot'
		;;
	esac
	if ! command -v 'fakeroot' >/dev/null 2>&1; then
		error_dependency_not_found "$name"
		return 1
	fi

	# Check fakeroot version
	local fakeroot_version
	fakeroot_version="$(LANG=C fakeroot --version | cut --delimiter=' ' --fields=3)"
	case "$keyword" in
		('fakeroot:>=1.25.1')
			if ! version_is_at_least '1.25.1' "$fakeroot_version"; then
				error_dependency_not_found "$name"
				return 1
			fi
		;;
	esac

	return 0
}

# output what a command is provided by
# USAGE: dependency_provided_by $command
# CALLED BY: error_dependency_not_found
dependency_provided_by() {
	local command provider
	command="$1"
	case "$command" in
		('7zr')
			provider='p7zip'
		;;
		('bsdtar')
			provider='libarchive'
		;;
		('convert'|'identify')
			provider='imagemagick'
		;;
		('lha')
			provider='lhasa'
		;;
		('icotool'|'wrestool')
			provider='icoutils'
		;;
		('dpkg-deb')
			provider='dpkg'
		;;
		(*)
			provider="$command"
		;;
	esac
	printf '%s' "$provider"
	return 0
}

