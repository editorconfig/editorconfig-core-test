#
# Copyright (c) 2011-2012 EditorConfig Team
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


# test tab_width default
ec_test_lines(NAME tab_width_default EC_FILE tab_width_default.in
    SRC_FILE test.c
    EXPECTED "indent_style=space[ \t]*" "indent_size=4[ \t]*" "tab_width=4[\t]*")

# Tab_width should not be set to any value if indent_size is "tab" and
# tab_width is not set
ec_test_lines(NAME tab_width_default_indent_size_tab
    EC_FILE tab_width_default.in SRC_FILE test2.c
    EXPECTED "indent_style=tab[ \t]*" "indent_size=tab[ \t]*")

# Test indent_size default. When indent_style is "tab", indent_size defaults to
# "tab".
ec_test_lines(NAME indent_size_default EC_FILE indent_size_default.in
    SRC_FILE test.c
    EXPECTED "^indent_style=tab[ \t]*" "indent_size=tab[ \t]*")

# Test indent_size default. When indent_style is "tab", indent_size should have
# no default value for version prior than 0.9.0.
new_ec_test_version(indent_size_default_pre_0_9_0 indent_size_default.in test.c
    "^indent_style=tab[ \t\n\r]*$" 0.8.0)

# Test indent_size default. When indent_style is "space", indent_size has no
# default value.
new_ec_test(indent_size_default_space indent_size_default.in test2.c
    "^indent_style=space[ \t\n\r]*$")

# Test indent_size default. When indent_style is "tab" and tab_width is set,
# indent_size should default to tab_width
ec_test_lines(
    NAME indent_size_default_with_tab_width
    EC_FILE indent_size_default.in
    SRC_FILE test3.c
    EXPECTED
    "indent_style=tab[ \t]*"
    "tab_width=2[ \t]*"
    "indent_size=2[ \t]*"
)
# test that same property values are lowercased (v0.9.0 properties)
ec_test_lines(NAME lowercase_values1 EC_FILE lowercase_values.in
    SRC_FILE test1.c
    EXPECTED "indent_style=space[ \t]*" "end_of_line=crlf[ \t]*")

# test that same property values are lowercased (v0.9.0 properties)
ec_test_lines(NAME lowercase_values2 EC_FILE lowercase_values.in
    SRC_FILE test2.c
    EXPECTED
    "insert_final_newline=true[ \t]*"
    "trim_trailing_whitespace=false[ \t]*"
    "charset=utf-8[ \t]*"
)

# test that same property values are not lowercased
new_ec_test(lowercase_values3 lowercase_values.in test3.c
    "^test_property=TestValue[ \t\n\r]*$")

# test that all property names are lowercased
new_ec_test(lowercase_names lowercase_names.in test.c
    "^testproperty=testvalue[ \t\n\r]*$")
