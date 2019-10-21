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

# Tests for version switches

# test --version option returns version information
new_ec_cli_test(NAME test_long_version_switch
    ARGS --version
    MATCH "^EditorConfig.* Version [0-9]+\\.[0-9]+\\.[0-9]+(-[a-z]+)?[ \t\n\r]$")

# test -v option returns version information
new_ec_cli_test(NAME test_short_version_switch
    ARGS -v
    MATCH "^EditorConfig.* Version [0-9]+\\.[0-9]+\\.[0-9]+(-[a-z]+)?[ \t\n\r]$")

# Test for multiple input files

# when files are specified on command line.  The files can appear in either
# order in the output, but each file's output line must be grouped with its
# file header.  Handle this by listing both possibilities manually in the regex.
new_ec_cli_test(NAME multiple_files_on_command_line
    ARGS -f cli.in
    "${CMAKE_CURRENT_SOURCE_DIR}/file1.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/file2.cpp"
    MATCH
    "^(\\[${CMAKE_CURRENT_SOURCE_DIR}/file1.c\\][ \t]*[\n\r]+key1=value1[ \t]*[\n\r]+\\[${CMAKE_CURRENT_SOURCE_DIR}/file2.cpp\\][ \t]*[\n\r]+key2=value2)|(\\[${CMAKE_CURRENT_SOURCE_DIR}/file2.cpp\\][ \t]*[\n\r]+key2=value2[ \t]*[\n\r]+\\[${CMAKE_CURRENT_SOURCE_DIR}/file1.c\\][ \t]*[\n\r]+key1=value1)[ \t\n\r]*$"
    )
