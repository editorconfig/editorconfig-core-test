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

cmake_minimum_required(VERSION 3.5)

# Test for EditorConfig file in parent directory
new_ec_test(parent_directory parent_directory.in parent_directory/test.a "^key=value[ \t\n\r]*$")

# Test for EditorConfig file in parent directory and current directory
new_ec_test_multiline(parent_and_current_dir_ML
    parent_directory.in parent_directory/test.b
    "key1=value1[ \t]*[\n\r]+key2=value2[ \t\n\r]*")

# Test for file in parent directory and overloaded by file in current directory
new_ec_test(parent_dir_overload parent_directory.in parent_directory/test.c "^key=valueB[ \t\n\r]*$")

# Test for file in parent directory and overloaded by file in current directory and repeated in current directory
new_ec_test(parent_dir_overload_repeat parent_directory.in parent_directory/test.d "^key=value_c[ \t\n\r]*$")

# Test for file in parent directory and overloaded by file in current directory and repeated in current directory, with different patterns
new_ec_test(parent_dir_overload_repeat2 parent_directory.in parent_directory/test.e "^key=value_g[ \t\n\r]*$")

# Test that search stops at root EditorConfig file
new_ec_test(root_file root_file.in root_file/test.a "^[ \t\n\r]*$")

# Test that search stops at root EditorConfig file
new_ec_test(root_file_mixed_case root_file.in root_mixed/test.a "^child=true[ \t\n\r]*$")

# Test that search stops at root EditorConfig file
new_ec_test(root_pattern root_file.in root "^name=root[ \t\n\r]*$")

# Tests path separator match
new_ec_test(path_separator path_separator.in path/separator "^key1=value1[ \t\n\r]*$")

# Windows style path separator in the command line should work on Windows, but
# should not work on other systems (including Cygwin)
if(WIN32)
    set(path_separator_backslash_in_cmd_line_regex "^key1=value1[ \t\n\r]*$")
else(WIN32)
    set(path_separator_backslash_in_cmd_line_regex "^[ \t\n\r]*$")
endif(WIN32)
new_ec_test_full_ec_file_path(path_separator_backslash_in_cmd_line
    path_separator.in
    "${CMAKE_CURRENT_SOURCE_DIR}\\path\\separator"
    ${path_separator_backslash_in_cmd_line_regex})

# Tests path separator match below top of path
new_ec_test(nested_path_separator path_separator.in nested/path/separator "^[ \t\n\r]*$")

# Tests path separator match top of path only
new_ec_test(top_level_path_separator path_separator.in top/of/path "^key2=value2[ \t\n\r]*$")

# Tests path separator match top of path only
new_ec_test(top_level_path_separator_neg path_separator.in not/top/of/path "^[ \t\n\r]*$")

# Test Windows-style path separator (backslash) does not work
new_ec_test(windows_separator path_separator.in windows/separator "^[ \t\n\r]*$")

# Test again that Windows-style path separator (backslash) does not work
new_ec_test(windows_separator2 path_separator.in windows/separator2 "^[ \t\n\r]*$")

# Globs with backslash in it but should be considered as file name on Non-Windows system
if((NOT WIN32) AND (NOT CYGWIN))
    new_ec_test(backslash_not_on_windows path_separator.in "windows\\separator2" "^key4=value4[ \t\n\r]*$")
endif()

new_ec_test(path_with_special_chars path_with_special_chars.in "path_with_special_[chars/test.a" "^key=value[ \t\n\r]*$")
## " <-- resync the syntax highlighter

# Test the unset value with various common properties
new_ec_test(unset_charset unset.in unset/charset.txt "^charset=unset[ \t\n\r]*$")
new_ec_test(unset_end_of_line unset.in unset/end_of_line.txt "^end_of_line=unset[ \t\n\r]*$")
new_ec_test_multiline(unset_indent_size_ML unset.in unset/indent_size.txt
    "indent_size=unset[ \t\n\r]*tab_width=unset[ \t\n\r]*")
new_ec_test(unset_indent_style unset.in unset/indent_style.txt "^indent_style=unset[ \t\n\r]*$")
new_ec_test(unset_insert_final_newline unset.in unset/insert_final_newline.txt "^insert_final_newline=unset[ \t\n\r]*$")
new_ec_test(unset_tab_width unset.in unset/tab_width.txt "^tab_width=unset[ \t\n\r]*$")
new_ec_test(unset_trim_trailing_whitespace unset.in unset/trim_trailing_whitespace.txt "^trim_trailing_whitespace=unset[ \t\n\r]*$")
