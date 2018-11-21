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


# Don't check any language compiler. This project is for EditorConfig Core
# testing only.
project(editorconfig-core-test NONE)

# Where this file lives
set(tests_cmakelists_dir "${CMAKE_CURRENT_LIST_DIR}")
#message(STATUS "Tests are in ${tests_cmakelists_dir}")

# Only when we are using editorconfig-core-test independently should we check
# cmake version, set EDITORCONFIG_CMD as cache string, and enable_testing()
# here.
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    cmake_minimum_required(VERSION 3.5)
    set(EDITORCONFIG_CMD "editorconfig" CACHE STRING "editorconfig command.")
    enable_testing()
endif()

# The most common test function
function(new_ec_test name ec_file src_file regex)
    add_test(${name} ${EDITORCONFIG_CMD} -f ${ec_file}
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

# The tests that requires version specified
function(new_ec_test_version name ec_file src_file regex version)
    add_test(${name} ${EDITORCONFIG_CMD} -b ${version} -f ${ec_file}
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

# The tests that requires the full path EditorConfig files
function(new_ec_test_full_ec_file_path name ec_file src_file regex)
    add_test(${name} ${EDITORCONFIG_CMD} -f ${ec_file} "${src_file}")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

# A test that returns multiple lines of output.  CAUTION: filenames used in
# these tests may not contain semicolons.
function(new_ec_test_multiline name ec_file src_file regex)
    #message(STATUS "Building multiline test ${name} with tests_cmakelists_dir ${tests_cmakelists_dir}")
    #message(STATUS "List dir ${CMAKE_CURRENT_LIST_DIR}, source dir ${CMAKE_CURRENT_SOURCE_DIR}")
    add_test(${name} "cmake"
                "-D" "EDITORCONFIG_CMD=${EDITORCONFIG_CMD}"
                    # Since variables aren't autpmatically passed to the inner cmake
                "-D" "ECARGS:LIST=-f;${ec_file};${CMAKE_CURRENT_SOURCE_DIR}/${src_file}"
                    # Note: the semicolons separate list elements.
                "-P" "${tests_cmakelists_dir}/cmake/ec_sort.cmake")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION
        "^[\n]*${regex}$")
        # Permit leading \n's because I can't always get rid of them using
        # only CMake-provided facilities.
endfunction()


# First, make sure the test harness works.
add_subdirectory(meta)

# Then test the core.
add_subdirectory(glob)
add_subdirectory(properties)
add_subdirectory(parser)
add_subdirectory(filetree)
add_subdirectory(cli)
