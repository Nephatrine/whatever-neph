set(MY_PATH_32 "PROGRAMFILES(X86)")
set(MY_PATH_64 "PROGRAMW6432")

find_program(NSIS_EXECUTABLE NAMES makensis PATHS
	"C:/NSIS/bin"
	"$ENV{${NSIS}}/bin"
	"$ENV{${NSIS_ROOT_DIR}}/bin"
	"$ENV{${MY_PATH_32}}/NSIS/bin"
	"$ENV{${MY_PATH_64}}/NSIS/bin")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NSIS DEFAULT_MSG NSIS_EXECUTABLE)

mark_as_advanced(NSIS_EXECUTABLE)

