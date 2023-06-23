# List the requirements to extract the contents of a MojoSetup installer
# USAGE: archive_requirements_mojosetup_list
archive_requirements_mojosetup_list() {
	# ShellCheck false-positive
	# Quote this to prevent word splitting.
	# shellcheck disable=SC2046
	printf '%s\n' \
		$(archive_requirements_makeself_list) \
		'unar'
}

# Check the presence of required tools to handle a MojoSetup installer
# USAGE: archive_requirements_mojosetup_check
archive_requirements_mojosetup_check() {
	local commands_list required_command
	commands_list=$(archive_requirements_mojosetup_list)
	for required_command in $commands_list; do
		if ! command -v "$required_command" >/dev/null 2>&1; then
			error_dependency_not_found "$required_command"
			return 1
		fi
	done
}

# Extract the content of a MojoSetup installer
# USAGE: archive_extraction_mojosetup $archive $destination_directory
archive_extraction_mojosetup() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	# Fetch the archive properties
	local archive_makeself_offset archive_mojosetup_filesize archive_offset
	archive_makeself_offset=$(makeself_offset "$archive_path")
	archive_mojosetup_filesize=$(makeself_filesize "$archive_path")
	archive_offset=$((archive_makeself_offset + archive_mojosetup_filesize))

	# Extract the .zip archive containing the game data
	local archive_game_data
	archive_game_data="${destination_directory}/mojosetup-game-data.zip"
	dd if="$archive_path" ibs="$archive_offset" skip=1 obs=1024 conv=sync 2>/dev/null > "$archive_game_data"

	# Extract the game data

	## For some reason the extraction with unzip fails with:
	##
	## End-of-central-directory signature not found.  Either this file is not
    ## a zipfile, or it constitutes one disk of a multi-part archive.  In the
    ## latter case the central directory and zipfile comment will be found on
    ## the last disk(s) of this archive.
	##
	## Despite this error, listing the archive contents with zipinfo does not fail.
	## Using unar instead, the extraction works with no error.

	unar -force-overwrite -no-directory -output-directory "$destination_directory" "$archive_game_data" 1>/dev/null
	rm "$archive_game_data"

	# Apply minimal permissions on extracted files
	set_standard_permissions "$destination_directory"
}