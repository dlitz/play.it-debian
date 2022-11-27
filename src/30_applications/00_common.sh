# list application identifiers for the current game
# USAGE: applications_list
# RETURN: a space-separated list of application identifiers
applications_list() {
	# Return APPLICATIONS_LIST value, if it is explicitly set.
	# Archive-specific values are supported.
	local applications_list
	applications_list=$(get_context_specific_value 'archive' 'APPLICATIONS_LIST')
	if [ -n "$applications_list" ]; then
		printf '%s' "$applications_list"
		return 0
	fi

	# If no value is set, try to guess one

	## Unity3D game
	if [ -n "$(unity3d_name)" ]; then
		# Unity3D games are expected to provide a single application
		printf '%s' 'APP_MAIN'
		return 0
	fi

	## Fallback, parse the game script
	local game_script
	game_script="$0"
	# Try to generate a list from the following variables:
	# - APP_xxx_EXE
	# - APP_xxx_SCUMMID
	# - APP_xxx_RESIDUALID
	local sed_expression application_id
	sed_expression='s/^\(APP_[0-9A-Z]\+\)_\(EXE\|SCUMMID\|RESIDUALID\)\(_[0-9A-Z]\+\)\?=.*/\1/p'
	while read -r application_id; do
		if [ -n "$application_id" ]; then
			applications_list="$applications_list $application_id"
		fi
	done <<- EOF
	$(sed --silent --expression="$sed_expression" "$game_script")
	EOF

	if [ -n "$applications_list" ]; then
		printf '%s\n' "$applications_list"
		return 0
	fi

	# This function does not error out if the list is empty,
	# callers should handle this case.
}

# Print the type of prefix to use for the given application.
# If no type is explicitely set from the game script, it defaults to "symlinks".
# USAGE: application_prefix_type $application
# RETURN: the prefix type keyword, from the supported values:
#         - symlinks
#         - none
application_prefix_type() {
	# Prefix types:
	# - "symlinks", the default, generate our usual symbolic links farm
	# - "none", no prefix is generated, the game is run from the read-only system directory

	local application
	application="$1"

	# The default for most application types is "symlinks".
	local prefix_type
	prefix_type='symlinks'

	# ScummVM and ResidualVM applications default to "none".
	local application_type
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
	case "$application_type" in
		('scummvm'|'residualvm')
			prefix_type='none'
		;;
	esac

	# Override default with explicitely set prefix type for the current game.
	if [ -n "$APPLICATIONS_PREFIX_TYPE" ]; then
		prefix_type="$APPLICATIONS_PREFIX_TYPE"
	fi

	# Override default with explicitely set prefix type for the given application.
	local prefix_type_override
	prefix_type_override=$(get_value "${application}_PREFIX_TYPE")
	if [ -n "$prefix_type_override" ]; then
		prefix_type="$prefix_type_override"
	fi

	# Check that a supported prefix type has been fetched
	case "$prefix_type" in
		('symlinks'|'none')
			## This is a supported type, no error to throw.
		;;
		(*)
			error_unknown_prefix_type "$prefix_type"
			return 1
		;;
	esac

	printf '%s' "$prefix_type"
}

# print the type of the given application
# USAGE: application_type $application
# RETURN: the application type keyword, from the supported values:
#         - dosbox
#         - java
#         - mono
#         - native
#         - native_no-prefix (deprecated)
#         - renpy
#         - residualvm
#         - scummvm
#         - wine
application_type() {
	# Get the application type from its identifier
	local application application_type
	application="$1"
	application_type=$(get_context_specific_value 'package' "${application}_TYPE")

	# If no type has been explicitely set, try to guess one
	if [ -z "$application_type" ]; then
		if [ -n "$(unity3d_name)" ]; then
			application_type='unity3d'
		else
			application_type=$(application_type_guess_from_file "$application")
		fi
	fi

	# Return early if no type has been found
	if [ -z "$application_type" ]; then
		return 0
	fi

	# Check that a supported type has been fetched
	case "$application_type" in
		( \
			'dosbox' | \
			'java' | \
			'mono' | \
			'native' | \
			'renpy' | \
			'residualvm' | \
			'scummvm' | \
			'unity3d' | \
			'wine' \
		)
			## This is a supported type, no error to throw.
		;;
		('native_no-prefix')
			## WARNING - This archive type is deprecated.
		;;
		(*)
			error_unknown_application_type "$application_type"
			return 1
		;;
	esac

	printf '%s' "$application_type"
}

# Try to find the application type from the MIME type of its binary file
# USAGE: application_type_guess_from_file $application
# RETURN: the guessed application type,
#         or an empty string if none could be guessed
application_type_guess_from_file() {
	# Compute path to application binary
	local application application_exe application_exe_path
	application="$1"
	## application_exe can not be used here, as it relies on application_type.
	## This could lead to a loop where application_type relies on itself.
	application_exe=$(get_context_specific_value 'package' "${application}_EXE")
	if [ -z "$application_exe" ]; then
		application_exe=$(get_context_specific_value 'archive' "${application}_EXE")
	fi
	application_exe_path=$(application_exe_path "$application_exe")

	# Return early if no binary file can be found for the given application.
	if [ -z "$application_exe_path" ]; then
		return 0
	fi

	local file_type application_type
	file_type=$(file_type "$application_exe_path")
	case "$file_type" in
		( \
			'application/x-executable' | \
			'application/x-pie-executable' \
		)
			application_type='native'
		;;
		('application/x-dosexec')
			local file_type_extended
			file_type_extended=$( \
				LANG=C file --brief --dereference "$application_exe_path" | \
				cut --delimiter=',' --fields=1 \
			)
			case "$file_type_extended" in
				('MS-DOS executable')
					application_type='dosbox'
				;;
				( \
					'PE32 executable (GUI) Intel 80386' | \
					'PE32+ executable (GUI) x86-64' \
				)
					application_type='wine'
				;;
				( \
					'PE32 executable (GUI) Intel 80386 Mono/.Net assembly' | \
					'PE32+ executable (GUI) x86-64 Mono/.Net assembly' \
				)
					application_type='mono'
				;;
			esac
		;;
	esac

	printf '%s' "$application_type"
}

# print the id of the given application
# USAGE: application_id $application
# RETURN: the application id, limited to the characters set [-_0-9a-z]
#         the id can not start nor end with a character from the set [-_]
application_id() {
	# Get the application type from its identifier
	local application_id
	application_id=$(get_value "${1}_ID")

	# If no id is explicitely set, fall back on the game id
	if [ -z "$application_id" ]; then
		application_id=$(game_id)
	fi

	# Check that the id fits the format restrictions
	if ! printf '%s' "$application_id" | \
		grep --quiet --regexp='^[0-9a-z][-_0-9a-z]\+[0-9a-z]$'
	then
		error_application_id_invalid "$application" "$application_id"
		return 1
	fi

	printf '%s' "$application_id"
}

# print the file name of the given application
# USAGE: application_exe $application
# RETURN: the application file name
application_exe() {
	# The following values a checked in order,
	# the first one found is used:
	# - package-specific value
	# - archive-specific value
	# - default value
	local application application_exe application_exe_default
	application="$1"
	application_exe_default=$(get_value "${application}_EXE")
	application_exe=$(get_context_specific_value 'package' "${application}_EXE")
	if \
		[ -z "$application_exe" ] || \
		[ "$application_exe" = "$application_exe_default" ]
	then
		application_exe=$(get_context_specific_value 'archive' "${application}_EXE")
	fi

	# If no value is set, try to find one based on the application type
	if [ -z "$application_exe" ]; then
		local application_type
		application_type=$(application_type "$application")
		if [ -z "$application_type" ]; then
			error_no_application_type "$application"
			return 1
		fi
		case "$application_type" in
			('unity3d')
				application_exe=$(application_unity3d_exe "$application")
			;;
		esac
	fi

	# Check that the file name is not empty
	if [ -z "$application_exe" ]; then
		error_application_exe_empty "$application" "$application_type"
		return 1
	fi

	printf '%s' "$application_exe"
}

# print the file name of the application, with single quotes escaped,
# for inclusion in a single quote delimited variable declaration.
# USAGE: application_exe_escaped $application
# RETURN: the application file name with single quotes escaped
application_exe_escaped() {
	local application
	application="$1"
	# If the file name includes single quotes, replace each one with: '\''
	application_exe "$application" | sed "s/'/'\\\''/g"
}

# Print the full path to the application binary.
# USAGE: application_exe_path $application_exe
# RETURN: the full path to the application binary,
#         or an empty string if it could not be found.
application_exe_path() {
	local application_exe
	application_exe="$1"

	# Look for the application binary in the temporary path for archive content.
	local content_path application_exe_path
	content_path=$(content_path_default)
	application_exe_path="${PLAYIT_WORKDIR}/gamedata/${content_path}/${application_exe}"
	if [ -f "$application_exe_path" ]; then
		printf '%s' "$application_exe_path"
		return 0
	fi

	# Look for the application binary in the current package.
	local package package_path path_game_data
	package=$(package_get_current)
	package_path=$(package_get_path "$package")
	path_game_data=$(path_game_data)
	application_exe_path="${package_path}${path_game_data}/${application_exe}"
	if [ -f "$application_exe_path" ]; then
		printf '%s' "$application_exe_path"
		return 0
	fi

	# Look for the application binary in all packages.
	local packages_list
	packages_list=$(packages_get_list)
	for package in $packages_list; do
		package_path=$(package_get_path "$package")
		application_exe_path="${package_path}${path_game_data}/${application_exe}"
		if [ -f "$application_exe_path" ]; then
			printf '%s' "$application_exe_path"
			return 0
		fi
	done
}

# print the name of the given application, for display in menus
# USAGE: application_name $application
# RETURN: the pretty version of the application name
application_name() {
	# Get the application name from its identifier
	local application_name
	application_name=$(get_value "${1}_NAME")

	# If no name is explicitely set, fall back on the game name
	if [ -z "$application_name" ]; then
		application_name=$(game_name)
	fi

	printf '%s' "$application_name"
}

# print the category of the given application, for sorting in menus with categories support
# USAGE: application_category $application
# RETURN: the application XDG menu category
application_category() {
	# Get the application category from its identifier
	local application_category
	application_category=$(get_value "${1}_CAT")

	# If no category is explicitely set, fall back on "Game"
	: "${application_category:=Game}"

	# TODO - We could check that the category is part of the 1.0 XDG spec:
	# https://specifications.freedesktop.org/menu-spec/menu-spec-1.0.html#category-registry

	printf '%s' "$application_category"
}

# print the pre-run actions for the given application
# USAGE: application_prerun $application
# RETURN: the pre-run actions, can span over multiple lines,
#         or an empty string if there are none
application_prerun() {
	get_value "${1}_PRERUN"
}

# print the post-run actions for the given application
# USAGE: application_postrun $application
# RETURN: the post-run actions, can span over multiple lines,
#         or an empty string if there are none
application_postrun() {
	get_value "${1}_POSTRUN"
}

# print the options string for the given application
# USAGE: application_options $application
# RETURN: the options string on a single line,
#         or an empty string if no options are set
application_options() {
	# Get the application options string from its identifier
	local application application_options
	application="$1"
	application_options=$(get_context_specific_value 'package' "${application}_OPTIONS")

	# Check that the options string does not span multiple lines
	if [ "$(printf '%s' "$application_options" | wc --lines)" -gt 1 ]; then
		error_variable_multiline "${application}_OPTIONS"
		return 1
	fi

	printf '%s' "$application_options"
}

# print the list of icon identifiers for the given application
# USAGE: application_icons_list $application
# RETURN: a space-separated list of icons identifiers,
#         or an empty string if no icon seems to be set
application_icons_list() {
	local application
	application="$1"

	# Use the value of APP_xxx_ICONS_LIST if it is set
	local icons_list
	icons_list=$(get_value "${application}_ICONS_LIST")
	if [ -n "$icons_list" ]; then
		printf '%s' "$icons_list"
		return 0
	fi

	# Fall back on the default value of a single APP_xxx_ICON icon
	local default_icon
	default_icon="${application}_ICON"
	## If a value is explicitly set for APP_xxx_ICON,
	## we assume this is the only icon for the current application.
	if [ -n "$(get_value "$default_icon")" ]; then
		printf '%s' "$default_icon"
		return 0
	fi
	## If no value is set for APP_xxx_ICON,
	## the behaviour depends on the application type.
	local application_type
	application_type=$(application_type "$application")
	case "$application_type" in
		('unity3d')
			# It is expected that Unity3D games always come with a single icon.
			printf '%s' "$default_icon"
			return 0
		;;
		('wine')
			# If no value is explicitly set for the icon of a WINE application,
			# we will fall back to extracting one from the binary.
			printf '%s' "$default_icon"
			return 0
		;;
	esac

	# If no icon has been found, there is nothing to print
	return 0
}

# Legacy - Print the application libraries path, relative to the game root.
# This function is deprecated, starting with ./play.it 2.19.
# New game scripts should no longer rely on the APP_xxx_LIBS variable.
# USAGE: application_libs $application
# RETURN: the application libraries path relative to the game root,
#         or an empty string if none is set
application_libs() {
	# Use the package-specific value if it is available,
	# falls back on the default value
	get_context_specific_value 'package' "${1}_LIBS"
}
