#
# Copyright (c) 2011-2018 EditorConfig Team
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

# New escape-sequence processing.
cmake_minimum_required(VERSION 3.5)
cmake_policy(VERSION 3.5.1)

# Don't check any language compiler. This project is for EditorConfig Core
# testing only.
project(editorconfig-core-test NONE)

# Where this file lives
set(tests_cmakelists_dir "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Tests are in ${tests_cmakelists_dir}")

# Only when we are using editorconfig-core-test independently should we check
# cmake version, set EDITORCONFIG_CMD as cache string, and enable_testing()
# here.
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    set(EDITORCONFIG_CMD "editorconfig" CACHE STRING "editorconfig command.")
    set(EDITORCONFIG_CMD_IS_TARGET OFF CACHE BOOL
        "EDITORCONFIG_CMD names a CMake target rather than an executable.")
    enable_testing()
    message(STATUS "tests: Standalone testing enabled")
endif()

if(${EDITORCONFIG_CMD_IS_TARGET})
    message(STATUS "tests: Using editorconfig target ${EDITORCONFIG_CMD}")
else()
    message(STATUS "tests: Using editorconfig binary ${EDITORCONFIG_CMD}")
endif()

# The most common test function
function(new_ec_test name ec_file src_file regex)
    add_test(NAME ${name} COMMAND ${EDITORCONFIG_CMD} -f ${ec_file}
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

# A test that requires a version specified
function(new_ec_test_version name ec_file src_file regex version)
    add_test(NAME ${name} COMMAND ${EDITORCONFIG_CMD} -b ${version} -f ${ec_file}
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

# A test that requires the full path to the EditorConfig files
function(new_ec_test_full_ec_file_path name ec_file src_file regex)
    add_test(NAME ${name} COMMAND ${EDITORCONFIG_CMD} -f ${ec_file} ${src_file})
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

# A test that returns multiple lines of output.  CAUTION: filenames used in
# these tests may not contain semicolons.
function(new_ec_test_multiline name ec_file src_file regex)
    #message(STATUS "Building multiline test ${name} with tests_cmakelists_dir ${tests_cmakelists_dir}")
    #message(STATUS "List dir ${CMAKE_CURRENT_LIST_DIR}, source dir ${CMAKE_CURRENT_SOURCE_DIR}")
    if(${EDITORCONFIG_CMD_IS_TARGET})
        add_test(NAME ${name} COMMAND "cmake"
                    "-D" "EDITORCONFIG_CMD=$<TARGET_FILE:${EDITORCONFIG_CMD}>"
                        # Since variables aren't automatically passed to the inner cmake
                    "-D" "ECARGS:LIST=-f;${ec_file};${CMAKE_CURRENT_SOURCE_DIR}/${src_file}"
                        # Note: the semicolons separate list elements.
                    "-P" "${tests_cmakelists_dir}/cmake/ec_sort.cmake")
    else()
        add_test(NAME ${name} COMMAND "cmake"
                    "-D" "EDITORCONFIG_CMD=${EDITORCONFIG_CMD}"
                        # Since variables aren't automatically passed to the inner cmake
                    "-D" "ECARGS:LIST=-f;${ec_file};${CMAKE_CURRENT_SOURCE_DIR}/${src_file}"
                        # Note: the semicolons separate list elements.
                    "-P" "${tests_cmakelists_dir}/cmake/ec_sort.cmake")
    endif()

    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION
        "^[\r\n]*${regex}$")
        # Permit leading \n's because I can't always get rid of them using
        # only CMake-provided facilities.
endfunction()

# Tests for other CLI arguments.  Usage:
#   new_ec_cli_test(NAME name MATCH pass_regex ARGS arguments...)
function(new_ec_cli_test)
    # Parse args
    set(one_value_keywords NAME MATCH)
    set(multi_value_keywords ARGS)
    cmake_parse_arguments(P
        "" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN})

    # Add test
    add_test(NAME ${P_NAME} COMMAND ${EDITORCONFIG_CMD} ${P_ARGS})
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${P_MATCH}")

endfunction()

# First, make sure the test harness works.
add_subdirectory(meta)

# Then test the core.
add_subdirectory(glob)
add_subdirectory(properties)
add_subdirectory(parser)
add_subdirectory(filetree)
add_subdirectory(cli)
