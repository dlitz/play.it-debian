# set distribution-specific supported architectures for Gentoo Linux target
# Usage set_supported_architectures_gentoo $architecture
# CALLED BY: set_supported_architectures
set_supported_architectures_gentoo() {
	case "$1" in
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
}
