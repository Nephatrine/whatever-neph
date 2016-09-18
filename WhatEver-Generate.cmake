set(WHATEVER_HAVE_GENERATE ON)

if(NOT DEFINED WHATEVER_CMAKE_DIR)
	set(WHATEVER_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR}
		CACHE STRING "WhatEver Directory")
endif()

if(NOT DEFINED WHATEVER_CACHE_DIR)
	set(WHATEVER_CACHE_DIR "${CMAKE_CURRENT_BINARY_DIR}/downloads"
		CACHE STRING "downloaded file location")
endif()

# ------------------------------
# we_download_unicode
# download unicode files
#

function(we_download_unicode VAR version)
	if(NOT DEFINED PYTHON_EXECUTABLE)
		message(FATAL_ERROR "No Python Executable Found")
	endif()

	file(MAKE_DIRECTORY ${WHATEVER_CACHE_DIR})
	foreach(arg ${ARGN})

		# get output filename
		get_filename_component(FILE_SLUG ${arg} NAME_WE)
		get_filename_component(FILE_TYPE ${arg} EXT)
		if("${FILE_SLUG}" MATCHES "%s")
			string(REPLACE "%s" "-${version}"
				FILE_OUT "${WHATEVER_CACHE_DIR}/${FILE_SLUG}${FILE_TYPE}")
		else()
			set(FILE_OUT "${WHATEVER_CACHE_DIR}/${FILE_SLUG}-${version}${FILE_TYPE}")
		endif()
		list(APPEND FUNC_OUTS ${FILE_OUT})

		# download targets
		add_custom_command(OUTPUT ${FILE_OUT}
			COMMAND ${PYTHON_EXECUTABLE}
			ARGS "${WHATEVER_CMAKE_DIR}/Tools/we_download_unicode.py"
			     "${FILE_SLUG}${FILE_TYPE}" ${version}
			DEPENDS "${WHATEVER_CMAKE_DIR}/Tools/we_download_unicode.py"
			COMMENT "[PYTHON] Downloading ${FILE_OUT}"
			WORKING_DIRECTORY ${WHATEVER_CACHE_DIR})
	endforeach()

	set(${VAR} ${${VAR}} ${FUNC_OUTS}
		PARENT_SCOPE)
endfunction()

# ------------------------------
# we_generate_from_script
# use script to create generated files
#

function(we_generate_from_script VAR script)
	# strip paths so we don't double up on them
	string(REGEX REPLACE "^${CMAKE_CURRENT_BINARY_DIR}" "" script ${script})
	string(REGEX REPLACE "^${CMAKE_CURRENT_SOURCE_DIR}" "" script ${script})

	# determine where script resides
	if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/config/scripts/${script}")
		set(script "${CMAKE_CURRENT_SOURCE_DIR}/config/scripts/${script}")
	elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${script}")
		set(script "${CMAKE_CURRENT_SOURCE_DIR}/${script}")
	else()
		set(script "${CMAKE_CURRENT_BINARY_DIR}/${script}")
	endif()

	list(APPEND FUNC_ARGS ${script})
	list(APPEND FUNC_DEPS ${script})
	set(FUNC_MODE ARGOUT)
	foreach(arg ${ARGN})

		# control words
		if("${arg}" STREQUAL "ARGS")
			set(FUNC_MODE ARGS)
		elseif("${arg}" STREQUAL "DEPENDS")
			set(FUNC_MODE DEPS)
		elseif("${arg}" STREQUAL "OUTPUT")
			set(FUNC_MODE OUTS)

		else()
			# output and input files
			if("${FUNC_MODE}" STREQUAL "ARGOUT" OR "${FUNC_MODE}" STREQUAL "OUTS")
				string(REGEX REPLACE "^${CMAKE_CURRENT_BINARY_DIR}" "" arg ${arg})
				set(arg "${CMAKE_CURRENT_BINARY_DIR}/${arg}")
				list(APPEND FUNC_OUTS ${arg})
				
				get_filename_component(FUNC_DIR ${arg} DIRECTORY)
				list(APPEND FUNC_DIRS ${FUNC_DIR})
			elseif("${FUNC_MODE}" STREQUAL "DEPS")
				string(REGEX REPLACE "^${CMAKE_CURRENT_BINARY_DIR}" "" arg ${arg})
				string(REGEX REPLACE "^${CMAKE_CURRENT_SOURCE_DIR}" "" arg ${arg})

				if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${arg}")
					list(APPEND FUNC_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/${arg}")
				else()
					list(APPEND FUNC_DEPS "${CMAKE_CURRENT_BINARY_DIR}/${arg}")
				endif()
			endif()

			# script arguments
			if("${FUNC_MODE}" STREQUAL "ARGOUT" OR "${FUNC_MODE}" STREQUAL "ARGS")
				list(APPEND FUNC_ARGS ${arg})
			endif()

			# only one argument is inherently the output name
			if("${FUNC_MODE}" STREQUAL "ARGOUT")
				set(FUNC_MODE ARGS)
			endif()
		endif()
	endforeach()

	# ensure output locations exist
	if(DEFINED FUNC_DIRS)
		list(REMOVE_DUPLICATES FUNC_DIRS)
		foreach(directory ${FUNC_DIRS})
			file(MAKE_DIRECTORY ${directory})
		endforeach()
	endif()

	# determine script type
	get_filename_component(SCRIPT_TYPE ${script} EXT)
	if("${SCRIPT_TYPE}" STREQUAL ".py")
		if(NOT DEFINED PYTHON_EXECUTABLE)
			message(FATAL_ERROR "No Python Executable Found")
		endif()
		set(FUNC_EXEC ${PYTHON_EXECUTABLE})
		set(FUNC_DESC "PYTHON")
	endif()

	# unsupported script
	if(NOT DEFINED FUNC_EXEC)
		message(FATAL_ERROR "Unknown Script Type: ${SCRIPT_TYPE}")
	endif()

	message(STATUS "args: ${FUNC_ARGS}")
	message(STATUS "deps: ${FUNC_DEPS}")
	message(STATUS "outs: ${FUNC_OUTS}")

	# add custom command
	add_custom_command(OUTPUT ${FUNC_OUTS}
		COMMAND ${FUNC_EXEC}
		ARGS ${FUNC_ARGS}
		DEPENDS ${FUNC_DEPS}
		COMMENT "[${FUNC_DESC}] Running ${script}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

	set(${VAR} ${${VAR}} ${FUNC_OUTS}
		PARENT_SCOPE)
endfunction()

