include(CheckCXXCompilerFlag)
include(CheckCXXSourceCompiles)
include(CMakeDependentOption)

set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

# ------------------------------
# MSVC Default Options
# because even MSVC needs some love...
#

cmake_dependent_option(BUILD_USE_MSVC_RUNTIME "Use MSVC DLL Runtime" ON MSVC OFF)

if(MSVC)
	# disable annoying warnings
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)

	# change default cflags
	foreach(flagvar CMAKE_C_FLAGS CMAKE_CXX_FLAGS
			CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG
			CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE
			CMAKE_C_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_MINSIZEREL
			CMAKE_C_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_RELWITHDEBINFO)
		string(REGEX REPLACE "/W3" "/W4" ${flagvar} ${${flagvar}})
		if(NOT BUILD_USE_MSVC_RUNTIME)
			string(REGEX REPLACE "/MDd" "/MTd" ${flagvar} "${${flagvar}}")
			string(REGEX REPLACE "/MD" "/MT" ${flagvar} "${${flagvar}}")
		endif()
	endforeach()
endif()

# ------------------------------
# we_config_has_atomic
# test for common atomic builtins
#

function(we_config_has_atomic)
	# gcc __atomic_*
	check_cxx_source_compiles("int main()
	{
		int rv = 0;
		__atomic_fetch_add( &rv, 1, __ATOMIC_SEQ_CST );
		return rv;
	}" HAS_BUILTIN__ATOMIC)

	# intel __sync_*
	check_cxx_source_compiles("int main()
	{
		int rv = 0;
		__sync_fetch_and_add( &rv, 1 );
		return rv;
	}" HAS_BUILTIN__SYNC)
endfunction()

# ------------------------------
# we_config_has_c_flags
# test for compiler flag support
#

function(we_config_has_cflags VAR)
	# check each flag
	foreach(flag ${ARGN})
		string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" FLAGVAR "HAS_CFLAG${flag}")
		string(TOUPPER ${FLAGVAR} FLAGVAR)
		check_cxx_compiler_flag(${flag} ${FLAGVAR})
		if(${FLAGVAR})
			list(APPEND CFLAGS ${flag})
		endif()
	endforeach()

	set(${VAR} ${${VAR}} ${CFLAGS}
		PARENT_SCOPE)
endfunction()

# ------------------------------
# we_config_has_ld_flags
# test for linker flag support
#

function(we_config_has_ldflags VAR)
	set(TEMP ${CMAKE_REQUIRED_FLAGS})
	
	# check each flag
	foreach(flag ${ARGN})
		string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" FLAGVAR "HAS_LDFLAG${flag}")
		string(TOUPPER ${FLAGVAR} FLAGVAR)
		set(CMAKE_REQUIRED_FLAGS ${flag})
		check_cxx_compiler_flag("" ${FLAGVAR})
		if(${FLAGVAR})
			list(APPEND LDFLAGS ${flag})
		endif()
	endforeach()

	set(${VAR} ${${VAR}} ${LDFLAGS}
		PARENT_SCOPE)
	set(CMAKE_REQUIRED_FLAGS ${TEMP})
endfunction()

# ------------------------------
# we_config_require_standard
# set required language standard version
#

function(we_config_require_standard LANG STD)
	set(CMAKE_${LANG}_STANDARD ${STD})
	set(CMAKE_${LANG}_STANDARD_REQUIRED ON)
	if(MSVC)
		set(CMAKE_${LANG}_STANDARD_REQUIRED OFF)
	endif()
endfunction()

