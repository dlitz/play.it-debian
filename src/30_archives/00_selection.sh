# set up a required archive
# USAGE: archive_initialize_required $archive_name $archive_candidate[…]
# RETURNS: nothing
archive_initialize_required() {
	local archive_name archive_candidate

	debug_entering_function 'archive_initialize_required'

	archive_name="$1"
	shift 1

	archive_candidate=$(archive_find_from_candidates "$archive_name" "$@")

	# Throw an error if no archive candidate has been found
	if [ -z "$archive_candidate" ]; then
		error_archive_not_found "$@"
		return 1
	fi

	# Call common part of archive initialization
	archive_initialize "$archive_name" "$archive_candidate"

	debug_leaving_function 'archive_initialize_required'

	return 0
}

# set up an optional archive
# USAGE: archive_initialize_optional $archive_name $archive_candidate[…]
# RETURNS: nothing
archive_initialize_optional() {
	local archive_name archive_candidate

	debug_entering_function 'archive_initialize_optional'

	archive_name="$1"
	shift 1

	archive_candidate=$(archive_find_from_candidates "$archive_name" "$@")

	# Return early if no archive candidate has been found
	if [ -z "$archive_candidate" ]; then
		return 0
	fi

	# Call common part of archive initialization
	archive_initialize "$archive_name" "$archive_candidate"

	debug_leaving_function 'archive_initialize_optional'

	return 0
}

# common part of an archive initialization
# USAGE: archive_initialize $archive_name $archive_candidate
# RETURNS: nothing
archive_initialize() {
	local archive_name archive_candidate archive_path archive_part_name archive_part_candidate
	archive_name="$1"
	archive_candidate="$2"

	archive_path=$(archive_find_path "$archive_candidate")

	assert_not_empty "$archive_path" '$archive_path' 'archive_initialize'

	# Set the current archive properties from the candidate one
	archive_set_properties_from_candidate "$archive_name" "$archive_candidate"

	# Check archive integrity if it comes with a MD5 hash
	if [ -n "$(get_value "${archive_name}_MD5")" ]; then
		archive_integrity_check "$archive_candidate" "$archive_path" "$archive_name"
	fi

	# Check dependencies
	check_deps

	# Update total size of all archives
	archive_add_size_to_total "$archive_name"

	# Check for archive extra parts
	for i in $(seq 1 9); do
		archive_part_name="${archive_name}_PART${i}"
		archive_part_candidate="${archive_candidate}_PART${i}"
		test -z "$(get_value "$archive_part_candidate")" && break
		archive_initialize_required "$archive_part_name" "$archive_part_candidate"
	done

	return 0
}

# find a single archive from a list of candidates
# USAGE: archive_find_from_candidates $archive_name $archive_candidate[…]
# RETURNS: an archive identifier, or nothing
archive_find_from_candidates() {
	local archive_name archive_candidate file_name file_path current_archive_path
	archive_name="$1"
	shift 1

	# An archive path might already be set, if it has been passed on the command line
	if [ -n "$(get_value $archive_name)" ]; then
		current_archive_path="$(get_value $archive_name)"
	fi

	# Loop around archive candidates, stopping on the first one found
	for archive_candidate in "$@"; do
		if [ -n "$current_archive_path" ]; then
			file_name=$(get_value "$archive_candidate")
			if [ "$(basename "$current_archive_path")" = "$file_name" ]; then
				file_path=$(realpath "$current_archive_path")
			fi

		else
			file_path=$(archive_find_path "$archive_candidate")
		fi
		test -n "$file_path" && break
	done

	# Return early if no archive candidate has been found
	if [ -z "$file_path" ]; then
		return 0
	fi

	# Return the identifier of the found archive candidate
	printf '%s' "$archive_candidate"
	return 0
}

# return the absolute path to a given archive
# USAGE: archive_find_path $archive
# RETURNS: an absolute file path, or nothing
archive_find_path() {
	local archive
	archive="$1"

	local archive_name
	archive_name=$(get_value "$archive")

	archive_find_path_from_name "$archive_name"
}

# find an archive from its file name
# USAGE: archive_find_path_from_name $archive_name
# RETURNS: an absolute file path, or nothing
archive_find_path_from_name() {
	local archive_name
	archive_name="$1"

	# If the passed name starts with "/",
	# assume it is an absolute path to the archive file.
	if printf '%s' "$archive_name" | grep --quiet '^/'; then
		if [ -f "$archive_name" ]; then
			printf '%s' "$archive_name"
		fi
		# No archive found at the given absolute path,
		# return nothing.
		return 0
	fi

	# Look for the archive in current directory
	local archive_path
	archive_path="${PWD}/${archive_name}"
	if [ -f "$archive_path" ]; then
		realpath "$archive_path"
		return 0
	fi

	# Look for the archive in the same directory than the main archive
	if [ -n "$SOURCE_ARCHIVE" ]; then
		local source_directory
		source_directory=$(dirname "$SOURCE_ARCHIVE")
		archive_path="${source_directory}/${archive_name}"
		if [ -f "$archive_path" ]; then
			realpath "$archive_path"
			return 0
		fi
	fi

	# No archive found, return nothing
	return 0
}

# set an archive properties from a candidate informations
# USAGE: archive_set_properties_from_candidate $archive_name $archive_candidate
# RETURNS: nothing
archive_set_properties_from_candidate() {
	local archive_name archive_candidate archive_path property
	archive_name="$1"
	archive_candidate="$2"

	assert_not_empty "$archive_name" '$archive_name' 'archive_set_properties_from_candidate'
	assert_not_empty "$archive_candidate" '$archive_candidate' 'archive_set_properties_from_candidate'

	# Set archive path
	archive_path=$(archive_find_path "$archive_candidate")

	assert_not_empty "$archive_path" '$archive_path' 'archive_set_properties_from_candidate'

	export "${archive_name}=$archive_path"

	# Print information message
	information_file_in_use "$archive_path"

	# Set list of extra archive parts
	for i in $(seq 1 9); do
		export "${archive_name}_PART${i}=$(get_value "${archive_candidate}_PART${i}")"
	done

	# Set other archive properties
	for property in \
		'MD5' \
		'TYPE' \
		'SIZE' \
		'VERSION'
	do
		export "${archive_name}_${property}=$(get_value "${archive_candidate}_${property}")"
	done

	return 0
}

# add the size of given archive to the total size of all archives in use
# USAGE: archive_add_size_to_total $archive
# RETURNS: nothing
archive_add_size_to_total() {
	local archive archive_size
	archive="$1"

	assert_not_empty "$archive" '$archive' 'archive_add_size_to_total'

	# Get the given archive size, defaults to a size of 0
	archive_size=$(get_value "${archive}_SIZE")
	: "${archive_size:=0}"

	# Update the total size of all archives in use
	: "${ARCHIVE_SIZE:=0}"
	ARCHIVE_SIZE=$((ARCHIVE_SIZE + archive_size))
	export ARCHIVE_SIZE

	return 0
}

# get the type of a given archive
# USAGE: archive_get_type $archive_identifier
# RETURNS: an archive type
archive_get_type() {
	# Get the archive identifier, check that it is not empty
	local archive_identifier
	archive_identifier="$1"
	if [ -z "$archive_identifier" ]; then
		error_empty_string 'archive_get_type' 'archive_identifier'
		return 1
	fi

	# Return archive type early if it is already set
	local archive_type
	archive_type=$(get_value "${archive_identifier}_TYPE")
	if [ -n "$archive_type" ]; then
		printf '%s' "$archive_type"
		return 0
	fi

	# Guess archive type from its file name
	local archive_file
	archive_file=$(get_value "$archive_identifier")
	case "$archive_file" in
		(*'.cab')
			archive_type='cabinet'
		;;
		(*'.deb')
			archive_type='debian'
		;;
		('setup_'*'.exe'|'patch_'*'.exe')
			archive_type='innosetup'
		;;
		('gog_'*'.sh')
			archive_type='mojosetup'
		;;
		(*'.iso')
			archive_type='iso'
		;;
		(*'.msi')
			archive_type='msi'
		;;
		(*'.rar')
			archive_type='rar'
		;;
		(*'.tar')
			archive_type='tar'
		;;
		(*'.tar.gz'|*'.tgz')
			archive_type='tar.gz'
		;;
		(*'.zip')
			archive_type='zip'
		;;
		(*'.7z')
			archive_type='7z'
		;;
		(*'.tar.xz'|*'.txz')
			archive_type='tar.xz'
		;;
		(*)
			error_archive_type_not_set "$archive_identifier"
			return 1
		;;
	esac

	# Return guessed type
	printf '%s' "$archive_type"
	return 0
}

# check integrity of target file
# USAGE: archive_integrity_check $archive $file ($name)
# CALLS: archive_integrity_check_md5
archive_integrity_check() {
	local archive
	local file
	local name
	archive="$1"
	file="$2"
	name="$3"
	case "$OPTION_CHECKSUM" in
		('md5')
			archive_integrity_check_md5 "$archive" "$file" "$name"
		;;
		('none')
			return 0
		;;
		(*)
			error_invalid_argument 'OPTION_CHECKSUM' 'archive_integrity_check'
			return 1
		;;
	esac
}

# return the list of supported archives for the current script
# USAGE: archives_return_list
# RETURNS: the list of identifiers of the supported archives,
#          as a list of strings separated by spaces or line breaks
archives_return_list() {
	# If a list is already explicitely set, return early
	# shellcheck disable=SC2153
	if [ -n "$ARCHIVES_LIST" ]; then
		printf '%s' "$ARCHIVES_LIST"
		return 0
	fi

	# Parse the calling script to guess the identifiers of the archives it supports
	local script pattern
	script="$0"

	# Try to find archives using the ARCHIVE_BASE_xxx_[0-9]+ naming scheme
	# Fall back to the older naming scheme for scripts targeting a library older than 2.13
	local archives_list pattern
	# shellcheck disable=SC2154
	if version_is_at_least '2.13' "$target_version"; then
		pattern='^ARCHIVE_BASE\(_[0-9A-Z]\+\)*_[0-9]\+='
	else
		pattern='^ARCHIVE_[0-9A-Z]\+\(_OLD[0-9A-Z]*\)*='
	fi
	archives_list=$(grep \
		--regexp="$pattern" "$script" | \
		cut --delimiter='=' --fields=1)

	# Returns the list of found archives
	if [ -n "$archives_list" ]; then
		printf '%s' "$archives_list"
		return 0
	fi

	# Fall back on trying to find archives using the old naming scheme
	# This will be deprecated in some future release
	pattern='^ARCHIVE_[0-9A-Z]\+\(_OLD[0-9A-Z]*\)*='
	archives_list=$(grep \
		--regexp="$pattern" "$script" | \
		cut --delimiter='=' --fields=1)

	# Returns the list of found archives
	if [ -n "$archives_list" ]; then
		printf '%s' "$archives_list"
		return 0
	fi

	# The current script does not seem to support any archive
	# This should not happen
	return 1
}

