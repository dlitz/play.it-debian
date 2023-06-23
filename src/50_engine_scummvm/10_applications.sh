# print the ScummVM id for the given application
# USAGE: application_scummvm_scummid $application
# RETURN: the ScummVM id
application_scummvm_scummid() {
	# Check that the application uses the scummvm type
	local application application_type
	application="$1"
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
	if [ "$application_type" != 'scummvm' ]; then
		error_application_wrong_type 'application_scummvm_scummid' "$application_type"
		return 1
	fi

	# Get the application ScummVM id from its identifier
	local application_scummid
	application_scummid=$(context_value "${application}_SCUMMID")

	# Check that the id fits the ScummVM id format
	# Allowed formats are:
	# - "engine:game"
	# - "game"
	if ! printf '%s' "$application_scummid" | \
		grep --quiet --regexp='^\([0-9a-z]\+:\)\?[0-9a-z]\+$'
	then
		error_application_scummid_invalid "$application" "$application_scummid"
		return 1
	fi

	printf '%s' "$application_scummid"
}
