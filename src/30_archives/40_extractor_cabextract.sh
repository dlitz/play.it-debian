# extract the content of an archive using cabextract
# USAGE: archive_extraction_using_cabextract $archive $destination_directory $log_file
archive_extraction_using_cabextract() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"
	assert_not_empty 'archive' 'archive_extraction_using_cabextract'
	assert_not_empty 'destination_directory' 'archive_extraction_using_cabextract'
	assert_not_empty 'log_file' 'archive_extraction_using_cabextract'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	if [ -z "$extractor_options" ]; then
		extractor_options='-L'
	fi
	debug_external_command "cabextract $extractor_options -d \"$destination_directory\" \"$archive_path\" >> \"$log_file\" 2>&1"
	cabextract $extractor_options -d "$destination_directory" "$archive_path" >> "$log_file" 2>&1
}
