# Debian - Print the package names providing the given native libraries
# USAGE: debian_dependencies_providing_native_libraries $library[…]
# RETURN: a list of Debian package names,
#         one per line
debian_dependencies_providing_native_libraries() {
	local library packages_list package
	packages_list=''
	for library in "$@"; do
		package=$(dependency_package_providing_library_deb "$library")
		packages_list="$packages_list
		$package"
	done

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Debian - Print the package name providing the given native library
# USAGE: dependency_package_providing_library_deb $library
dependency_package_providing_library_deb() {
	local library package_name
	library="$1"
	case "$library" in
		('ld-linux.so.2')
			package_name='libc6'
		;;
		('ld-linux-x86-64.so.2')
			package_name='libc6'
		;;
		('liballeg.so.4.4')
			package_name='liballegro4.4'
		;;
		('libasound.so.2')
			package_name='libasound2'
		;;
		('libasound_module_'*'.so')
			package_name='libasound2-plugins'
		;;
		('libatk-1.0.so.0')
			package_name='libatk1.0-0'
		;;
		('libaudio.so.2')
			package_name='libaudio2'
		;;
		('libavcodec.so.58')
			package_name='libavcodec58 | libavcodec-extra58'
		;;
		('libavformat.so.58')
			package_name='libavformat58 | libavformat-extra58'
		;;
		('libavutil.so.56')
			package_name='libavutil56'
		;;
		('libbz2.so.1.0'|'libbz2.so.1')
			package_name='libbz2-1.0'
		;;
		('libc.so.6')
			package_name='libc6'
		;;
		('libc++.so.1')
			package_name='libc++1'
		;;
		('libc++abi.so.1')
			package_name='libc++abi1'
		;;
		('libcairo.so.2')
			package_name='libcairo2'
		;;
		('liblcms2.so.2')
			package_name='liblcms2-2'
		;;
		('libcom_err.so.2')
			package_name='libcom-err2'
		;;
		('libcrypt.so.1')
			package_name='libcrypt1'
		;;
		('libcrypto.so.1.1')
			package_name='libssl1.1'
		;;
		('libcups.so.2')
			package_name='libcups2'
		;;
		('libcurl.so.4')
			package_name='libcurl4'
		;;
		('libcurl-gnutls.so.4')
			package_name='libcurl3-gnutls'
		;;
		('libdbus-1.so.3')
			package_name='libdbus-1-3'
		;;
		('libdl.so.2')
			package_name='libc6'
		;;
		('libexpat.so.1')
			package_name='libexpat1'
		;;
		('libFAudio.so.0')
			package_name='libfaudio0'
		;;
		('libfontconfig.so.1')
			package_name='libfontconfig1'
		;;
		('libfreeimage.so.3')
			package_name='libfreeimage3'
		;;
		('libfreetype.so.6')
			package_name='libfreetype6'
		;;
		('libgcc_s.so.1')
			package_name='libgcc-s1'
		;;
		('libgconf-2.so.4')
			package_name='libgconf-2-4'
		;;
		('libgcrypt.so.11')
			# This old library is no longer available from Debian.
			unset package_name
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='libgdk-pixbuf-2.0-0 | libgdk-pixbuf2.0-0'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='libgtk2.0-0'
		;;
		('libgio-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libGL.so.1')
			package_name='
			libgl1 | libgl1-mesa-glx
			libglx-mesa0 | libglx-vendor | libgl1-mesa-glx'
		;;
		('libGLEW.so.2.2')
			package_name='libglew2.2'
		;;
		('libglfw.so.3')
			package_name='libglfw3 | libglfw3-wayland'
		;;
		('libglib-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libGLU.so.1')
			package_name='libglu1-mesa | libglu1'
		;;
		('libGLX.so.0')
			package_name='libglx0'
		;;
		('libgmodule-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libgobject-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libgomp.so.1')
			package_name='libgomp1'
		;;
		('libgpg-error.so.0')
			package_name='libgpg-error0'
		;;
		('libgssapi_krb5.so.2')
			package_name='libgssapi-krb5-2'
		;;
		('libgthread-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='libgtk2.0-0'
		;;
		('libgtk-3.so.0')
			package_name='libgtk-3-0'
		;;
		('libICE.so.6')
			package_name='libice6'
		;;
		('libidn2.so.0')
			package_name='libidn2-0'
		;;
		('libIL.so.1')
			package_name='libdevil1c2'
		;;
		('libjpeg.so.62')
			package_name='libjpeg62-turbo | libjpeg62'
		;;
		('libk5crypto.so.3')
			package_name='libk5crypto3'
		;;
		('libkrb5.so.3')
			package_name='libkrb5-3'
		;;
		('libluajit-5.1.so.2')
			package_name='libluajit-5.1-2'
		;;
		('libm.so.6')
			package_name='libc6'
		;;
		('libmbedtls.so.12')
			package_name='libmbedtls12'
		;;
		('libminiupnpc.so.17')
			package_name='libminiupnpc17'
		;;
		('libmodplug.so.1')
			package_name='libmodplug1'
		;;
		('libmpg123.so.0')
			package_name='libmpg123-0'
		;;
		('libnghttp2.so.14')
			package_name='libnghttp2-14'
		;;
		('libnspr4.so')
			package_name='libnspr4'
		;;
		('libnss3.so')
			package_name='libnss3'
		;;
		('libnssutil3.so')
			package_name='libnss3'
		;;
		('libogg.so.0')
			package_name='libogg0'
		;;
		('libopenal.so.1')
			package_name='libopenal1'
		;;
		('libOpenGL.so.0')
			package_name='libopengl0'
		;;
		('libopenmpt.so.0')
			package_name='libopenmpt0'
		;;
		('libpango-1.0.so.0')
			package_name='libpango-1.0-0'
		;;
		('libpangocairo-1.0.so.0')
			package_name='libpangocairo-1.0-0'
		;;
		('libpangoft2-1.0.so.0')
			package_name='libpangoft2-1.0-0'
		;;
		('libpcre.so.3')
			package_name='libpcre3'
		;;
		('libphysfs.so.1')
			package_name='libphysfs1'
		;;
		('libpixman-1.so.0')
			package_name='libpixman-1-0'
		;;
		('libplc4.so')
			package_name='libnspr4'
		;;
		('libplds4.so')
			package_name='libnspr4'
		;;
		('libpng16.so.16')
			package_name='libpng16-16'
		;;
		('libpsl.so.5')
			package_name='libpsl5'
		;;
		('libpthread.so.0')
			package_name='libc6'
		;;
		('libpulse.so.0')
			package_name='libpulse0'
		;;
		('libpulse-simple.so.0')
			package_name='libpulse0'
		;;
		('libresolv.so.2')
			package_name='libc6'
		;;
		('librt.so.1')
			package_name='libc6'
		;;
		('librtmp.so.1')
			package_name='librtmp1'
		;;
		('libSDL-1.2.so.0')
			package_name='libsdl1.2debian'
		;;
		('libSDL_kitchensink.so.1')
			package_name='libsdl-kitchensink1'
		;;
		('libSDL_mixer-1.2.so.0')
			package_name='libsdl-mixer1.2'
		;;
		('libSDL_sound-1.0.so.1')
			package_name='libsdl-sound1.2'
		;;
		('libSDL_ttf-2.0.so.0')
			package_name='libsdl-ttf2.0-0'
		;;
		('libSDL2-2.0.so.0')
			package_name='libsdl2-2.0-0'
		;;
		('libSDL2_image-2.0.so.0')
			package_name='libsdl2-image-2.0-0'
		;;
		('libSDL2_mixer-2.0.so.0')
			package_name='libsdl2-mixer-2.0-0'
		;;
		('libSDL2_ttf-2.0.so.0')
			package_name='libsdl2-ttf-2.0-0'
		;;
		('libsecret-1.so.0')
			package_name='libsecret-1-0'
		;;
		('libsigc-2.0.so.0')
			package_name='libsigc++-2.0-0v5'
		;;
		('libSM.so.6')
			package_name='libsm6'
		;;
		('libsmime3.so')
			package_name='libnss3'
		;;
		('libsmpeg-0.4.so.0')
			package_name='libsmpeg0'
		;;
		('libsodium.so.23')
			package_name='libsodium23'
		;;
		('libssh2.so.1')
			package_name='libssh2-1'
		;;
		('libssl.so.1.1')
			package_name='libssl1.1'
		;;
		('libssl3.so')
			package_name='libnss3'
		;;
		('libstdc++.so.5')
			package_name='libstdc++5'
		;;
		('libstdc++.so.6')
			package_name='libstdc++6'
		;;
		('libtheora.so.0')
			package_name='libtheora0'
		;;
		('libtheoradec.so.1')
			package_name='libtheora0'
		;;
		('libthread_db.so.1')
			package_name='libc6'
		;;
		('libturbojpeg.so.0')
			package_name='libturbojpeg0'
		;;
		('libudev.so.1')
			package_name='libudev1'
		;;
		('libutil.so.1')
			package_name='libc6'
		;;
		('libuuid.so.1')
			package_name='libuuid1'
		;;
		('libuv.so.1')
			package_name='libuv1'
		;;
		('libvorbis.so.0')
			package_name='libvorbis0a'
		;;
		('libvorbisenc.so.2')
			package_name='libvorbisenc2'
		;;
		('libvorbisfile.so.3')
			package_name='libvorbisfile3'
		;;
		('libvulkan.so.1')
			package_name='
			libvulkan1
			mesa-vulkan-drivers | vulkan-icd'
		;;
		('libX11.so.6')
			package_name='libx11-6'
		;;
		('libX11-xcb.so.1')
			package_name='libx11-xcb1'
		;;
		('libxcb.so.1')
			package_name='libxcb1'
		;;
		('libxcb-randr.so.0')
			package_name='libxcb-randr0'
		;;
		('libXcomposite.so.1')
			package_name='libxcomposite1'
		;;
		('libXcursor.so.1')
			package_name='libxcursor1'
		;;
		('libXdamage.so.1')
			package_name='libxdamage1'
		;;
		('libXext.so.6')
			package_name='libxext6'
		;;
		('libXfixes.so.3')
			package_name='libxfixes3'
		;;
		('libXft.so.2')
			package_name='libxft2'
		;;
		('libXi.so.6')
			package_name='libxi6'
		;;
		('libXinerama.so.1')
			package_name='libxinerama1'
		;;
		('libxml2.so.2')
			package_name='libxml2'
		;;
		('libxmp.so.4')
			package_name='libxmp4'
		;;
		('libXmu.so.6')
			package_name='libxmu6'
		;;
		('libXrandr.so.2')
			package_name='libxrandr2'
		;;
		('libXrender.so.1')
			package_name='libxrender1'
		;;
		('libxslt.so.1')
			package_name='libxslt1.1'
		;;
		('libXss.so.1')
			package_name='libxss1'
		;;
		('libXt.so.6')
			package_name='libxt6'
		;;
		('libXtst.so.6')
			package_name='libxtst6'
		;;
		('libXxf86vm.so.1')
			package_name='libxxf86vm1'
		;;
		('libz.so.1')
			package_name='zlib1g'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	dependencies_unknown_libraries_add "$library"
}
