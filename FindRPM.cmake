find_program(RPM_EXECUTABLE NAMES rpm)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RPM DEFAULT_MSG RPM_EXECUTABLE)

mark_as_advanced(RPM_EXECUTABLE)

