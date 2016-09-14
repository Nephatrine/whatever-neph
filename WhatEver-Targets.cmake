include(GNUInstallDirs)

# ------------------------------
# we_target_add_paths
# add inclusion paths to search for headers
#

set(CPACK_COMPONENT_HEADERS_DEPENDS lic)
set(CPACK_COMPONENT_HEADERS_DISPLAY_NAME "Header Files")
set(CPACK_COMPONENT_HEADERS_GROUP dev)
set(CPACK_COMPONENT_HEADERS_INSTALL_TYPES Full)

function(we_target_add_paths)
	set(FUNC_MODE TARGET)
	set(FUNC_PLUS _INTERNAL)
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
			set(FUNC_PLUS _INTERNAL)
		elseif("${arg}" STREQUAL "EXTERNAL")
			set(FUNC_PLUS _EXTERNAL)
		elseif("${arg}" STREQUAL "INSTALL_TAG")
			set(FUNC_MODE TAG)

		# make install directory unique
		elseif("${FUNC_MODE}" STREQUAL "TAG")
			set(INSTALL_DIR "${INSTALL_DIR}${arg}")

		# target list
		elseif("${FUNC_MODE}" STREQUAL "TARGET")
			list(APPEND SELECTED_TARGETS ${arg})

		else()

			# strip cmake paths so we don't double up
			if("${FUNC_PLUS}" STREQUAL "_INTERNAL")
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
				list(APPEND "PUBLIC_PATHS${FUNC_PLUS}" ${arg})
			elseif("${FUNC_MODE}" STREQUAL "PRIVATE")
				list(APPEND "PRIVATE_PATHS${FUNC_PLUS}" ${arg})
			elseif("${FUNC_MODE}" STREQUAL "INTERFACE")
				list(APPEND "INTERFACE_PATHS${FUNC_PLUS}" ${arg})
			endif()
		endif()
	endforeach()

	# add paths to each target
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
endfunction()

