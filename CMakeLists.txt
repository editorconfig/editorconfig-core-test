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

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(multiline_matcher)

# Only when we are using editorconfig-core-test independently should we check
# cmake version, set EDITORCONFIG_CMD as cache string, and enable_testing()
# here.
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    cmake_minimum_required(VERSION 3.5.0)
    set(EDITORCONFIG_CMD "editorconfig" CACHE STRING "editorconfig command.")
    enable_testing()
endif()

# The most common test function
function(new_ec_test name ec_file src_file regex)
    add_test(${name} ${EDITORCONFIG_CMD} -f ${ec_file}
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
    set_tests_properties(${name} PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction()

# Test that the output _doesn't_ match a given regex
function(new_ec_test_does_not_match name ec_file src_file regex)
    add_test(${name} ${EDITORCONFIG_CMD} -f ${ec_file}
        "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
    set_tests_properties(${name} PROPERTIES FAIL_REGULAR_EXPRESSION "${regex}")
endfunction()


# Test for multiple regexes in any order in the output.  Each regex should
# match one line.
# Example:
#   ec_test_lines(NAME foo EC_FILE ec.in SRC_FILE src_file EXPECTED "a" "b" "c")
function(ec_test_lines)

    # Parse the arguments
    set(one_value_keywords NAME EC_FILE SRC_FILE)
    set(multi_value_keywords EXPECTED)
    cmake_parse_arguments(P "" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN})

    #message("Adding test:")
    #message("Name:              ${P_NAME}")
    #message("Editorconfig file: ${P_EC_FILE}")
    #message("Source file:       ${P_SRC_FILE}")
    #message("Regexes:           ${P_EXPECTED}")

    # Build the joint regex by building all possible permutations of
    # the input regex.
    make_regex_of_permutations(RETVAL regex EXPECTED ${P_EXPECTED})
    #message("Bulk regex:        ${regex}")

    add_test("${P_NAME}" ${EDITORCONFIG_CMD} -f "${P_EC_FILE}"
        "${CMAKE_CURRENT_SOURCE_DIR}/${P_SRC_FILE}")
    set_tests_properties("${P_NAME}"
        PROPERTIES PASS_REGULAR_EXPRESSION "${regex}")
endfunction(ec_test_lines)

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

add_subdirectory(glob)
add_subdirectory(properties)
add_subdirectory(parser)
add_subdirectory(filetree)
add_subdirectory(cli)

