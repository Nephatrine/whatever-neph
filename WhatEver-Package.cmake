include(CMakeDependentOption)
include(CMakeDetermineSystem)

find_package(DPKG)
find_package(NSIS)
find_package(RPM)

if(NOT DEFINED WHATEVER_CMAKE_DIR)
	set(WHATEVER_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR} CACHE STRING "WhatEver Directory")
endif()

cmake_dependent_option(BUILD_PACKAGE_7Z "Create 7-ZIP Archives" ON WIN32 OFF)
cmake_dependent_option(BUILD_PACKAGE_ZIP "Create ZIP Archives" ON WIN32 OFF)
cmake_dependent_option(BUILD_PACKAGE_TGZ "Create GZip-Compressed TAR Archives" ON UNIX OFF)
cmake_dependent_option(BUILD_PACKAGE_TXZ "Create LZMA-Compressed TAR Archives" ON UNIX OFF)

cmake_dependent_option(BUILD_INSTALLER_NSIS "Create NSIS EXE Installer" ${NSIS_FOUND} WIN32 OFF)
cmake_dependent_option(BUILD_INSTALLER_DEB "Create Debian DEB Installer" ${DPKG_FOUND} "UNIX;NOT APPLE" OFF)
cmake_dependent_option(BUILD_INSTALLER_RPM "Create Red Hat RPM Installer" ${RPM_FOUND} "UNIX;NOT APPLE" OFF)

set(WHATEVER_HAVE_PACKAGE ON)

# ------------------------------
# we_config_detect_arch
# detect target architecture
#

function(we_package_detect_arch VAR)
	try_run(run_result_unused compile_result_unused
		${CMAKE_CURRENT_BINARY_DIR}
		"${WHATEVER_CMAKE_DIR}/Tools/detect-arch.c"
		COMPILE_OUTPUT_VARIABLE ARCH)
	string(REGEX MATCH "CMAKE_ARCH ([a-zA-Z0-9_]+)" ARCH "${ARCH}")
	string(REPLACE "CMAKE_ARCH " "" ARCH "${ARCH}")

	if (NOT ARCH)
		set(ARCH unknown)
	endif()

	set(${VAR} ${ARCH}
		PARENT_SCOPE)
endfunction()

# ------------------------------
# we_package
# Build CPack Package
#

function(we_package)
	set(FUNC_MODE TAG)
	foreach(arg ${ARGN})

		# control words
		if("${arg}" STREQUAL "TAG")
			set(FUNC_MODE TAG)
		elseif("${arg}" STREQUAL "CATEGORY")
			set(FUNC_MODE CATEGORY)
		elseif("${arg}" STREQUAL "CONTACT")
			set(FUNC_MODE CONTACT)
		elseif("${arg}" STREQUAL "DESC")
			set(FUNC_MODE DESC)
		elseif("${arg}" STREQUAL "HOME")
			set(FUNC_MODE HOME)
		elseif("${arg}" STREQUAL "VENDOR")
			set(FUNC_MODE VENDOR)

		# get values
		elseif("${FUNC_MODE}" STREQUAL "TAG")
			set(FUNC_TAG ${arg})
		elseif("${FUNC_MODE}" STREQUAL "CATEGORY")
			set(CPACK_DEBIAN_PACKAGE_SECTION ${arg})
		elseif("${FUNC_MODE}" STREQUAL "CONTACT")
			set(CPACK_PACKAGE_CONTACT ${arg})
		elseif("${FUNC_MODE}" STREQUAL "DESC")
			if(DEFINED CPACK_PACKAGE_DESCRIPTION_SUMMARY)
				set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CPACK_PACKAGE_DESCRIPTION_SUMMARY} ${arg}")
			else()
				set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${arg})
			endif()
		elseif("${FUNC_MODE}" STREQUAL "HOME")
			set(CPACK_DEBIAN_PACKAGE_HOMEPAGE ${arg})
			set(CPACK_NSIS_URL_INFO_ABOUT ${arg})
			set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT ${arg})
		elseif("${FUNC_MODE}" STREQUAL "VENDOR")
			set(CPACK_PACKAGE_VENDOR ${arg})
			set(CPACK_PACKAGE_INSTALL_DIRECTORY ${arg})
			set(CPACK_WIX_PROGRAM_MENU_FOLDER ${arg})
		endif()
	endforeach()

	# Default README
	foreach(readme README.1ST README README.TXT README.txt README.md)
		if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${readme}")
			set(PACKAGE_README ${readme})
		endif()
	endforeach()
	if(DEFINED PACKAGE_README)
		if(WHATEVER_HAVE_TARGETS)
			we_target_list_docs(${PACKAGE_README})
		endif()
		if(NOT DEFINED CPACK_PACKAGE_DESCRIPTION_FILE)
			set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_README}")
		endif()
		if(NOT DEFINED CPACK_RESOURCE_FILE_README)
			set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_README}")
		endif()
	endif()

	# Default License
	foreach(readme COPYING COPYING.TXT COPYING.txt COPYING.md LICENSE LICENSE.TXT LICENSE.txt LICENSE.md)
		if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${readme}")
			set(PACKAGE_LICENSE ${readme})
		endif()
	endforeach()
	if(DEFINED PACKAGE_LICENSE)
		if(WHATEVER_HAVE_TARGETS)
			we_target_list_license(${PACKAGE_LICENSE})
		endif()
		if(NOT DEFINED CPACK_RESOURCE_FILE_LICENSE)
			set(CPACK_RESOURCE_FILE_LICENSE ""${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_LICENSE}")
		endif()
	endif()

	# Default Package Types
	foreach(generate 7Z TGZ TXZ ZIP)
		if(BUILD_PACKAGE_${generate})
			list(APPEND WHATEVER_GENERATOR ${generate})
			list(APPEND WHATEVER_SOURCE_GENERATOR ${generate})
		endif()
	endforeach()
	foreach(generate DEB NSIS RPM)
		if(BUILD_INSTALLER_${generate})
			list(APPEND WHATEVER_GENERATOR ${generate})
		endif()
	endforeach()

	set(CPACK_GENERATOR ${WHATEVER_GENERATOR})
	set(CPACK_SOURCE_GENERATOR ${WHATEVER_SOURCE_GENERATOR})

	# Binary Package
	we_package_detect_arch(WHATEVER_SYSTEM_ARCH)
	set(CPACK_PACKAGE_NAME "${PROJECT_NAME}${FUNC_TAG}")
	set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
	set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
	set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
	set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
	set(CPACK_STRIP_FILES ON)
	set(CPACK_PACKAGE_RELOCATABLE ON)
	string(TOLOWER "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CMAKE_SYSTEM_NAME}.${WHATEVER_SYSTEM_ARCH}" CPACK_PACKAGE_FILE_NAME)

	# Installer Settings
	set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
	set(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS ON)
	set(CPACK_DEBIAN_ARCHIVE_TYPE gnutar)
	set(CPACK_RPM_PACKAGE_AUTOREQ ON)
	set(CPACK_RPM_PACKAGE_AUTOPROV ON)
	set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
	set(CPACK_NSIS_MODIFY_PATH ON)
	set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION}")
	set(CPACK_NSIS_PACKAGE_NAME "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION}")

	# Source Package
	set(CPACK_SOURCE_IGNORE_FILES "\\\\.#;/#;.*~"
		"/\\\\.git"
		"/\\\\.svn"
		"appveyor.yml"
		"travis.yml"
		"${CMAKE_CURRENT_SOURCE_DIR}/build"
		"${CMAKE_CURRENT_BINARY_DIR}")
	string(TOLOWER "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-src.noarch" CPACK_SOURCE_PACKAGE_FILE_NAME)

	include(CPack)
endfunction()

