# check the presence of required tools to handle a LHA archive (.lzh)
# USAGE: archive_dependencies_check_type_lha
archive_dependencies_check_type_lha() {
	local required_command
	for required_command in 'lha' 'bsdtar'; do
		if command -v "$required_command" >/dev/null 2>&1; then
			return 0
		fi
	done
	error_dependency_not_found 'lha'
	return 1
}

# extract the content of a LHA archive (.lzh)
# USAGE: archive_extraction_lha $archive $destination_directory
archive_extraction_lha() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'lha' >/dev/null 2>&1; then
		debug_external_command "lha -ew=\"$destination_directory\" \"$archive_path\" >/dev/null"
		lha -ew="$destination_directory" "$archive_path" >/dev/null
		set_standard_permissions "$destination_directory"
	elif command -v 'bsdtar' >/dev/null 2>&1; then
		debug_external_command "bsdtar --directory \"$destination_directory\" --extract --file \"$archive_path\""
		bsdtar --directory "$destination_directory" --extract --file "$archive_path"
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'lha'
		return 1
	fi
}

