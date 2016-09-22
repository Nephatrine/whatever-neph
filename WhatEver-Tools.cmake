find_package(ClangExtras)

set(WHATEVER_HAVE_TOOLS ON)

# ------------------------------
# we_tool_get_libraries
# helper function
#

function(we_tool_get_libraries VAR target)
	get_property(TIDY_TARGET_LIBS TARGET ${target} PROPERTY LINK_LIBRARIES)
	foreach(linklib ${TIDY_TARGET_LIBS})
		if(TARGET ${linklib})
			we_tool_get_libraries(THESE_LIBS ${linklib})
			list(APPEND LINKED_LIBS ${linklib} ${THESE_LIBS})
		endif()
	endforeach()
	set(${VAR} ${${VAR}} LINKED_LIBS
		PARENT_SCOPE)
endfunction()

# ------------------------------
# we_tool_clang_format
# run clang-format
#

function(we_tool_clang_format custom)
	foreach(arg ${ARGN})
		get_property(TIDY_TARGET_SOURCES TARGET ${arg} PROPERTY SOURCES)
		list(APPEND TIDY_SOURCES ${TIDY_TARGET_SOURCES})
	endforeach()
	list(REMOVE_DUPLICATES TIDY_SOURCES)

	if(DEFINED CLANG_FORMAT_EXECUTABLE)
		add_custom_target(${custom}
			COMMAND ${CLANG_FORMAT_EXECUTABLE} -i ${TIDY_SOURCES}
			DEPENDS ${TIDY_SOURCES}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BIN_DIR}
			COMMENT "[CLANG] Formatting Code")
	endif()
endfunction()

# ------------------------------
# we_tool_clang_tidy
# run clang-tidy analysis
#

function(we_tool_clang_tidy custom target)
	# remove any checks defined
	foreach(arg ${ARGN})
		set(TIDY_FLAGS "${TIDY_FLAGS},${arg}")
	endforeach()

	# get all include directories and definitions needed
	get_property(TIDY_TARGET_INCLUDES TARGET ${target} PROPERTY INCLUDE_DIRECTORIES)
	get_property(TIDY_TARGET_DEFINES TARGET ${target} PROPERTY COMPILE_DEFINITIONS)
	we_tool_get_libraries(TIDY_TARGET_LIBS ${target})
	foreach(linklib ${TIDY_TARGET_LIBS})
		if(TARGET ${linklib})
			get_property(TIDY_LIBRARY_INCLUDES TARGET ${linklib} PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
			get_property(TIDY_LIBRARY_DEFINES TARGET ${linklib} PROPERTY INTERFACE_COMPILE_DEFINITIONS)
			list(APPEND TIDY_TARGET_INCLUDES ${TIDY_LIBRARY_INCLUDES})
			list(APPEND TIDY_TARGET_DEFINES ${TIDY_LIBRARY_DEFINES})
		endif()
	endforeach()

	# filter out generator statements
	foreach(incdir ${TIDY_TARGET_INCLUDES})
		if(NOT "${incdir}" MATCHES "INSTALL_INTERFACE")
			string(REPLACE "$<BUILD_INTERFACE:" "" INCDIR ${incdir})
			string(REPLACE ">" "" INCDIR ${incdir})
			list(APPEND TIDY_INCLUDES "-I${incdir}")
		endif()
	endforeach()

	# get definitions in proper format
	foreach(define ${TIDY_TARGET_DEFINES})
		list(APPEND TIDY_DEFINES "-D${define}")
	endforeach()

	# add custom target
	get_property(TIDY_SOURCES_ALL TARGET ${target} PROPERTY SOURCES)
	foreach(source ${TIDY_SOURCES_ALL})
		if("${source}" MATCHES "\\.c$" OR
				"${source}" MATCHES "\\.C$" OR
				"${source}" MATCHES "\\.cc$" OR
				"${source}" MATCHES "\\.cxx$" OR
				"${source}" MATCHES "\\.cpp$")
			list(APPEND TIDY_SOURCES ${source})
			message(STATUS "adding: ${source}")
		endif()
	endforeach()
	if(DEFINED CLANG_TIDY_EXECUTABLE)
		add_custom_target(${custom}
			COMMAND ${CLANG_TIDY_EXECUTABLE} ${TIDY_SOURCES} -header-filter=.* -checks=*${TIDY_FLAGS} -- ${TIDY_INCLUDES} ${TIDY_DEFINES}
			DEPENDS ${TIDY_SOURCES}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BIN_DIR}
			COMMENT "[CLANG-TIDY] Analyzing ${target}")
	endif()
endfunction()

