# tests/meta/CMakeLists.txt: Test of the test harness for editorconfig.

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

set(tests_meta_cmakelists_dir "${CMAKE_CURRENT_LIST_DIR}")

# Line separator regex, for convenience
set(L "[ \t\n\r]+")

message(STATUS "meta: Using editorconfig ${EDITORCONFIG_CMD}")

# Test run_and_sort()
add_test(meta_runandsort cmake -P "${tests_meta_cmakelists_dir}/sample.cmake")
set_tests_properties(meta_runandsort PROPERTIES PASS_REGULAR_EXPRESSION
    "^[\r\n]*0${L}a;b${L}b;c${L}b;e${L}b;f${L}c;b;a${L}d${L}$")
    # Have to permit leading \n's - I don't know how to get rid of them

# Test the new multiline macro on a simple case.  The new_ec_test_multiline
# function adds /^[\r\n]*/ to the beginning of the provided regex, and
# /$/ to the end.
new_ec_test_multiline(meta_multiline meta.in meta.c
    "answer=42${L}")
