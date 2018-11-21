# sample.cmake: Tests run_and_sort to make sure it's working.

cmake_minimum_required(VERSION 3.5)

# See documentation links at https://stackoverflow.com/q/12802377/2877364
set( tests_meta_sample_dir "${CMAKE_CURRENT_LIST_DIR}" )
list( APPEND CMAKE_MODULE_PATH "${tests_meta_sample_dir}/../cmake" )
include( runandsort )

run_and_sort( RETVAL lines RETVAL_FAILURE did_fail
    CAPTURE_STDERR TRIM_INITIAL_LEADING_SPACE   # since we're using almostcat
    CMDLINE "cmake" "-DWHICH:STRING=${tests_meta_sample_dir}/sample.txt"
            "-P" "${tests_meta_sample_dir}/../cmake/almostcat.cmake"
)       # Don't use cat(1) since we might be running on Windows

if( ${did_fail} )
    message( FATAL_ERROR "Program returned a nonzero exit code" )
    return()
endif()

# message() will give us an extra \n, so trim one if we can.
string( REGEX REPLACE "(\r\n|\r|\n)$" "" lines "${lines}" )

message( "${lines}" )
# This outputs to stderr, and prints nothing extra except for a \n at the end

# Note that message( STATUS "${lines}" ) doesn't work because it outputs a "--"
# before the actual content.

# You could also use execute_process( COMMAND "echo" "${lines}" )
# or cmake -E echo, but I think the message() call is good enough.
