find_program(DPKG_EXECUTABLE NAMES dpkg)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DPKG DEFAULT_MSG DPKG_EXECUTABLE)

mark_as_advanced(DPKG_EXECUTABLE)

