include(GNUInstallDirs)

# ------------------------------
# we_target_add_cflags
# add compiler options
#

function(we_target_add_cflags)
	set(FUNC_MODE TARGET)
	foreach(arg ${ARGN})

		# control words
		if("${arg}" STREQUAL "TARGETS")
			set(FUNC_MODE TARGET)
		elseif("${arg}" STREQUAL "PUBLIC")
			set(FUNC_MODE PUBLIC)
		elseif("${arg}" STREQUAL "PRIVATE")
			set(FUNC_MODE PRIVATE)
		elseif("${arg}" STREQUAL "INTERFACE")
			set(FUNC_MODE INTERFACE)


		# target list
		elseif("${FUNC_MODE}" STREQUAL "TARGET")
			list(APPEND SELECTED_TARGETS ${arg})

		# cflag lists
		elseif("${FUNC_MODE}" STREQUAL "PUBLIC")
			list(APPEND PUBLIC_CLFAGS ${arg})
		elseif("${FUNC_MODE}" STREQUAL "PRIVATE")
			list(APPEND PRIVATE_CFLAGS ${arg})
		elseif("${FUNC_MODE}" STREQUAL "INTERFACE")
			list(APPEND INTERFACE_CFLAGS ${arg})
		endif()
	endforeach()

	# add flags to each target
	foreach(target ${SELECTED_TARGETS})
		target_compile_options(${target}
			PRIVATE ${PRIVATE_CFLAGS}
			PUBLIC ${PUBLIC_CFLAGS}
			INTERFACE ${INTERFACE_CFLAGS})
	endforeach()
endfunction()

# ------------------------------
# we_target_add_defines
# add preprocessor definitions
#

function(we_target_add_defines)
	set(FUNC_MODE TARGET)
	foreach(arg ${ARGN})

		# control words
		if("${arg}" STREQUAL "TARGETS")
			set(FUNC_MODE TARGET)
		elseif("${arg}" STREQUAL "PUBLIC")
			set(FUNC_MODE PUBLIC)
		elseif("${arg}" STREQUAL "PRIVATE")
			set(FUNC_MODE PRIVATE)
		elseif("${arg}" STREQUAL "INTERFACE")
			set(FUNC_MODE INTERFACE)

		# target list
		elseif("${FUNC_MODE}" STREQUAL "TARGET")
			list(APPEND SELECTED_TARGETS ${arg})

		# define lists
		elseif("${FUNC_MODE}" STREQUAL "PUBLIC")
			list(APPEND PUBLIC_CLFAGS ${arg})
		elseif("${FUNC_MODE}" STREQUAL "PRIVATE")
			list(APPEND PRIVATE_CFLAGS ${arg})
		elseif("${FUNC_MODE}" STREQUAL "INTERFACE")
			list(APPEND INTERFACE_CFLAGS ${arg})
		endif()
	endforeach()

	# add defines to each target
	foreach(target ${SELECTED_TARGETS})
		target_compile_definitions(${target}
			PRIVATE ${PRIVATE_CFLAGS}
			PUBLIC ${PUBLIC_CFLAGS}
			INTERFACE ${INTERFACE_CFLAGS})
	endforeach()
endfunction()

# ------------------------------
# we_target_add_ldflags
# add linker options
#

function(we_target_add_ldflags)
	set(FUNC_MODE TARGET)
	foreach(arg ${ARGN})

		# control words
		if("${arg}" STREQUAL "TARGETS")
			set(FUNC_MODE TARGET)
		elseif("${arg}" STREQUAL "PUBLIC")
			set(FUNC_MODE PRIVATE)
		elseif("${arg}" STREQUAL "PRIVATE")
			set(FUNC_MODE PRIVATE)
		elseif("${arg}" STREQUAL "INTERFACE")
			set(FUNC_MODE INTERFACE)

		# target list
		elseif("${FUNC_MODE}" STREQUAL "TARGET")
			list(APPEND SELECTED_TARGETS ${arg})

		# ldflag lists
		elseif(NOT "${FUNC_MODE}" STREQUAL "INTERFACE")
			set(PRIVATE_LDFLAGS "${PRIVATE_LDFLAGS} ${arg}")
		endif()
	endforeach()

	# add flags to each target
	foreach(target ${SELECTED_TARGETS})
		if(PRIVATE_LDFLAGS)
			set_target_properties(${target} PROPERTIES
				LINK_FLAGS ${PRIVATE_LDFLAGS})
		endif()
	endforeach()
endfunction()

# ------------------------------
# we_target_add_paths
# add inclusion paths to search for headers
#

set(CPACK_COMPONENT_HEADERS_DEPENDS lic)
set(CPACK_COMPONENT_HEADERS_DISPLAY_NAME "Header Files")
set(CPACK_COMPONENT_HEADERS_GROUP dev)

function(we_target_add_paths)
	set(FUNC_MODE TARGET)
	set(FUNC_PATH _INTERNAL)
	set(INSTALL_DIR "${PROJECT_NAME}-${PROJECT_VERSION}")
	foreach(arg ${ARGN})

		# control words
		if("${arg}" STREQUAL "TARGETS")
			set(FUNC_MODE TARGET)
		elseif("${arg}" STREQUAL "PUBLIC")
			set(FUNC_MODE PUBLIC)
		elseif("${arg}" STREQUAL "PRIVATE")
			set(FUNC_MODE PRIVATE)
		elseif("${arg}" STREQUAL "INTERFACE")
			set(FUNC_MODE INTERFACE)
		elseif("${arg}" STREQUAL "INTERNAL")
			set(FUNC_PATH _INTERNAL)
		elseif("${arg}" STREQUAL "EXTERNAL")
			set(FUNC_PATH _EXTERNAL)
		elseif("${arg}" STREQUAL "INSTALL_TAG")
			set(FUNC_MODE TAG)

		# make install directory unique
		elseif("${FUNC_MODE}" STREQUAL "TAG")
			set(INSTALL_DIR "${INSTALL_DIR}${arg}")

		# target list
		elseif("${FUNC_MODE}" STREQUAL "TARGET")
			list(APPEND SELECTED_TARGETS ${arg})

		# include paths
		else()

			# strip cmake paths so we don't double up
			if("${FUNC_PATH}" STREQUAL "_INTERNAL")
				string(REGEX REPLACE "^${CMAKE_CURRENT_SOURCE_DIR}" "" arg ${arg})
				string(REGEX REPLACE "^${CMAKE_CURRENT_BINARY_DIR}" "" arg ${arg})

				if("${FUNC_MODE}" STREQUAL "PRIVATE")
					set(arg "${CMAKE_CURRENT_SOURCE_DIR}/${arg}" "${CMAKE_CURRENT_BINARY_DIR}/${arg}")
				else()
					list(APPEND INSTALL_PATHS ${arg})
				endif()
			endif()

			# path lists
			if("${FUNC_MODE}" STREQUAL "PUBLIC")
				list(APPEND "PUBLIC_PATHS${FUNC_PATH}" ${arg})
			elseif("${FUNC_MODE}" STREQUAL "PRIVATE")
				list(APPEND "PRIVATE_PATHS${FUNC_PATH}" ${arg})
			elseif("${FUNC_MODE}" STREQUAL "INTERFACE")
				list(APPEND "INTERFACE_PATHS${FUNC_PATH}" ${arg})
			endif()
		endif()
	endforeach()

	# iterate over all targets
	foreach(target ${SELECTED_TARGETS})
		target_include_directories(${target}
			PRIVATE ${PRIVATE_PATHS_EXTERNAL} ${PRIVATE_PATHS_INTERNAL}
			PUBLIC ${PUBLIC_PATHS_EXTERNAL}
			INTERFACE ${INTERFACE_PATHS_EXTERNAL})

		# special handling for these since install paths will differ
		foreach(type PUBLIC INTERFACE)
			foreach(directory ${${type}_PATHS_INTERNAL})
				target_include_directories(${target} ${type}
					$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${directory}>
					$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/${directory}>
					$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${INSTALL_DIR}>)
			endforeach()
		endforeach()
	endforeach()

	# install files
	if(INSTALL_PATHS)
		list(REMOVE_DUPLICATES INSTALL_PATHS)
		foreach(directory ${INSTALL_PATHS})
			file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${directory}")
			install(DIRECTORY
				"${CMAKE_CURRENT_SOURCE_DIR}/${directory}/"
				"${CMAKE_CURRENT_BINARY_DIR}/${directory}/"
				DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${INSTALL_DIR}"
				COMPONENT headers
				PATTERN "internal" EXCLUDE)
		endforeach()
	endif()
endfunction()

