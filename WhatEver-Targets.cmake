include(GenerateExportHeader)
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

# ------------------------------
# we_target_build_library
# builds a library target
#

function(we_target_build_library VAR library soversion)
	set(FUNC_MODE SOURCE)
	foreach(arg ${ARGN})

		# control words
		if("${arg}" STREQUAL "SOURCE")
			set(FUNC_MODE SOURCE)
		elseif("${arg}" STREQUAL "EXPORT")
			set(FUNC_MODE EXPORT)
		elseif("${arg}" STREQUAL "TAG")
			set(FUNC_MODE TAG)

		# get lists
		elseif("${FUNC_MODE}" STREQUAL "SOURCE")
			list(APPEND TARG_SOURCE ${arg})
		elseif("${FUNC_MODE}" STREQUAL "EXPORT")
			list(APPEND TARG_INCLUDE ${arg})
			if(NOT TARG_EXPORT)
				set(TARG_EXPORT ${arg})
			endif()
		elseif("${FUNC_MODE}" STREQUAL "TAG")
			set(TARG_TAG ${arg})
		endif()
	endforeach()

	# what library types to build
	string(TOUPPER "BUILD_${library}_SHARED" HAS_SHARED)
	string(TOUPPER "BUILD_${library}_STATIC" HAS_STATIC)
	if(BUILD_SHARED_LIBS AND NOT DEFINED ${HAS_SHARED})
		set(${HAS_SHARED} ON)
	endif()
	if(NOT ${HAS_SHARED} AND NOT DEFINED ${HAS_STATIC})
		set( ${HAS_STATIC} ON)
	endif()

	# target names
	if(${HAS_SHARED})
		set(TARG_SHARED "${library}")
		set(TARG_STATIC "${library}_static")
	else()
		set(TARG_STATIC "${library}")
	endif()

	# configure static library
	if(${HAS_STATIC})
		add_library(${TARG_STATIC} STATIC ${TARG_SOURCE})

		# avoid conflicts between static lib and shared import lib names
		if(MSVC)
			set_target_properties(${TARG_STATIC} PROPERTIES
				OUTPUT_NAME "${library}-${soversion}${TARG_TAG}-static"
				INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
		else()
			set_target_properties(${TARG_STATIC} PROPERTIES
				OUTPUT_NAME "${library}-${soversion}${TARG_TAG}"
				INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
		endif()

		# don't export symbols
		string(TOUPPER "${library}_STATIC_DEFINE" TARG_DEF_STATIC)
		target_compile_definitions(${TARG_STATIC} PUBLIC ${TARG_DEF_STATIC})

		# install files
		install(TARGETS ${TARG_STATIC}
			EXPORT ${PROJECT_NAME}
			COMPONENT static
			LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
			ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

		list(APPEND TARG_ALL ${TARG_STATIC})
		set("${VAR}_STATIC" ${${VAR}_STATIC} ${TARG_STATIC}
			PARENT_SCOPE)
	endif()

	# confgure shared library
	if(${HAS_SHARED})
		add_library(${TARG_SHARED} SHARED ${TARG_SOURCE})

		# some platforms don't do soversions
		if(WIN32)
			set_target_properties(${TARG_SHARED} PROPERTIES
				OUTPUT_NAME "${library}-${soversion}${TARG_TAG}"
				VERSION ${PROJECT_VERSION}
				INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
		else()
			set_target_properties(${TARG_SHARED} PROPERTIES
				OUTPUT_NAME "${library}${TARG_TAG}"
				SOVERSION ${soversion}
				VERSION ${PROJECT_VERSION}
				INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
		endif()

		# export symbols
		target_compile_definitions(${TARG_SHARED} PRIVATE "${library}_EXPORTS")

		# install files
		install(TARGETS ${TARG_SHARED}
			EXPORT ${PROJECT_NAME}
			COMPONENT shared
			RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
			LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
			ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

		list(APPEND TARG_ALL ${TARG_SHARED})
		set("${VAR}_SHARED" ${${VAR}_SHARED} ${TARG_SHARED}
			PARENT_SCOPE)
	endif()

	# generate export header
	if(TARG_EXPORT)
		string(REGEX REPLACE "^${CMAKE_CURRENT_BINARY_DIR}" "" TARG_EXPORT ${TARG_EXPORT})
		set(TARG_EXPORT "${CMAKE_CURRENT_BINARY_DIR}/${TARG_EXPORT}")
		generate_export_header(${library} BASE_NAME ${library}
			EXPORT_FILE_NAME "${TARG_EXPORT}/${library}_api.h")
		we_target_add_paths(${TARG_ALL} PUBLIC ${TARG_INCLUDE} INSTALL_TAG ${TARG_TAG})
	endif()

	set(${VAR} ${${VAR}} ${TARG_ALL}
		PARENT_SCOPE)
endfunction()

