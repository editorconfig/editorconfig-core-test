# ec_sort.cmake: Run editorconfig and sort its output
# For use in editorconfig; see
# https://github.com/editorconfig/editorconfig/issues/375 .

# Call as, e.g.:
# cmake -D EDITORCONFIG_CMD="../editorconfig" -D ECARGS:LIST="-f;.editorconfig;foo" -P cmake/ec_sort.cmake
# EDITORCONFIG_CMD may also be list-valued.  EDITORCONFIG_CMD and ECARGS
# are put together on the command line, in that order, and split by CMake.

# BSD-2-Clause
# Copyright 2018 Christopher White (cxw42 at GitHub; http://devwrench.com)
# All rights reserved
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

cmake_minimum_required(VERSION 3.5)

# See documentation links at https://stackoverflow.com/q/12802377/2877364
set(tests_cmake_ec_sort_dir "${CMAKE_CURRENT_LIST_DIR}")
list(APPEND CMAKE_MODULE_PATH "${tests_cmake_ec_sort_dir}/../cmake")
include(runandsort)

# Required parameters are in variables: EDITORCONFIG_CMD and ECARGS
if("${EDITORCONFIG_CMD}" STREQUAL "")
    message(FATAL_ERROR "No EDITORCONFIG_CMD parameter specified")
    return()
endif()

if("${ECARGS}" STREQUAL "")
    message(FATAL_ERROR "No ECARGS parameter specified")
    return()
endif()

# Uncomment for debugging
#message(FATAL_ERROR " Running ${EDITORCONFIG_CMD} with ${ECARGS}")

run_and_sort(RETVAL lines RETVAL_FAILURE did_fail
    CMDLINE ${EDITORCONFIG_CMD} ${ECARGS}
)

if(${did_fail})
    message(FATAL_ERROR "${EDITORCONFIG_CMD} ${ECARGS} returned a nonzero exit code")
    return()
endif()

# message() will give us an extra \n, so trim one if we can.
string(REGEX REPLACE "(\r\n|\r|\n)$" "" lines "${lines}")

# Output **to stderr**.  If we used message(STATUS...), it would print to
# stdout but also emit a leading "--".
message("${lines}")
