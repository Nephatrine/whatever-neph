find_package(ClangExtras)

set(WHATEVER_HAVE_TOOLS ON)

# ------------------------------
# we_helper_linked_libs
# helper function
#

function(we_helper_linked_libs VAR target)
	get_property(TIDY_TARGET_LIBS TARGET ${target} PROPERTY LINK_LIBRARIES)
	foreach(linklib ${TIDY_TARGET_LIBS})
		if(TARGET ${linklib})
			we_helper_linked_libs(THESE_LIBS ${linklib})
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
		get_property(FORMAT_TARGET_SOURCES TARGET ${arg} PROPERTY SOURCES)
		list(APPEND FORMAT_SOURCES ${FORMAT_TARGET_SOURCES})
		list(APPEND FORMAT_TARGETS ${arg})
	endforeach()
	list(REMOVE_DUPLICATES FORMAT_SOURCES)

	if(DEFINED CLANG_FORMAT_EXECUTABLE)
		add_custom_target(${custom}
			COMMAND ${CLANG_FORMAT_EXECUTABLE} -i ${FORMAT_SOURCES}
			DEPENDS ${FORMAT_SOURCES}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
			COMMENT "[CLANG-FORMAT] formatting: ${FORMAT_TARGETS}")
	endif()
endfunction()

# ------------------------------
# we_tool_clang_tidy
# run clang-tidy analysis
#

function(we_helper_clang_tidy custom target)
	if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json")
		set(TIDY_BUILD "-p=${CMAKE_CURRENT_BINARY_DIR}")
	else()
		# get all include directories and definitions needed
		get_property(TIDY_TARGET_INCLUDES TARGET ${target} PROPERTY INCLUDE_DIRECTORIES)
		get_property(TIDY_TARGET_DEFINES TARGET ${target} PROPERTY COMPILE_DEFINITIONS)
		we_helper_linked_libs(TIDY_TARGET_LIBS ${target})
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

		# greater accuracy
		message(WARNING "Consider using -DCMAKE_EXPORT_COMPILE_COMMANDS=ON for greater clang-tidy accuracy.")
		set(TIDY_BUILD "--")
	endif()

	# add custom target
	get_property(TIDY_TARGET_SOURCES TARGET ${target} PROPERTY SOURCES)
	foreach(source ${TIDY_TARGET_SOURCES})
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
			COMMAND ${CLANG_TIDY_EXECUTABLE} ${TIDY_SOURCES} ${TIDY_BUILD} ${TIDY_INCLUDES} ${TIDY_DEFINES}
			DEPENDS ${TIDY_TARGET_SOURCES}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
			COMMENT "[CLANG-TIDY] analyzing ${target}")
	endif()
endfunction()

function(we_tool_clang_tidy custom)
	if(DEFINED CLANG_TIDY_EXECUTABLE)
		foreach(arg ${ARGN})
			we_helper_clang_tidy(${custom}_${arg} ${arg})
			list(APPEND TIDY_DEPS "${custom}_${arg}")
		endforeach()
		add_custom_target(${custom})
		add_dependencies(${custom} ${TIDY_DEPS})
	endif()
endfunction()

