# runandsort.cmake: Run a program and sort its output
# For use in editorconfig; see
# https://github.com/editorconfig/editorconfig/issues/375 .

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

# Conventions:
#   - "P_*" are parameters parsed using cmake_parse_arguments
#   - Any parameter called "RETVAL", "RETVAL_*", or "*_NAME" should be given
#       the name of a variable in the caller's scope into which to
#       store results.

# Run a program with the given arguments, and return its sorted output as
# a string.
# CAUTION 1:    May not produce correct output if any output line includes
#               a semicolon, because that is a list separator in CMake.
# CAUTION 2:    Depends on sort order of CMake; see discussion at
#               https://gitlab.kitware.com/cmake/cmake/issues/18551
#
# Limitations:
#   Any \x01 in the string will be corrupted - this routine uses those to work
#   around CMake limitations.

# Arguments:
#   RETVAL .  .  .  .  .  .  .  The name of the variable to store the result in
#   CMDLINE .  .  .  .  .  .  . The program to run, and any arguments
#   RETVAL_FAILURE .  .  .  .   If present, a variable that will be set to TRUE
#                               if PGM returns a non-zero exit code.
#   CAPTURE_STDERR .  .  .  .   If present, capture stderr instead of stdout
#   TRIM_INITIAL_LEADING_SPACE  If present, remove initial spaces from the
#                               first line.  This is to work around a hack
#                               in almostcat.cmake.
#
# Returns:
#   The sorted stdout of PGM, or the FAILURE string if PGM failed.
#   PGM's stderr is ignored.

function(run_and_sort)
    # Argument parsing
    set(option_keywords CAPTURE_STDERR TRIM_INITIAL_LEADING_SPACE)
    set(one_value_keywords RETVAL RETVAL_FAILURE)
    set(multi_value_keywords CMDLINE ARGS)
    cmake_parse_arguments(P "${option_keywords}" "${one_value_keywords}"
                            "${multi_value_keywords}" ${ARGN})

    #message(STATUS "Running ${P_CMDLINE}")              # DEBUG
    execute_process(COMMAND ${P_CMDLINE}
        RESULT_VARIABLE ep_retval
        OUTPUT_VARIABLE ep_stdout
        ERROR_VARIABLE ep_stderr
    )

    # Which one are we processing?
    if(${P_CAPTURE_STDERR})
        set(ep_out "${ep_stderr}")
    else()
        set(ep_out "${ep_stdout}")
    endif()

    #message(STATUS "Got retval =${ep_retval}=")         # DEBUG
    #message(STATUS "Got stdout =${ep_stdout}=")         # DEBUG
    #message(STATUS "Got stderr =${ep_stderr}=")         # DEBUG

    # Early bail on failure
    if(NOT("${ep_retval}" EQUAL "0"))
        set(${P_RETVAL} "" PARENT_SCOPE)
        if("${P_RETVAL_FAILURE}" MATCHES ".")     # if we got a name
            set(${P_RETVAL_FAILURE} TRUE PARENT_SCOPE)
        endif()
        return()
    endif()

    # Trim hack
    if(${P_TRIM_INITIAL_LEADING_SPACE})
        string(REGEX REPLACE "^[ ]+" "" ep_out "${ep_out}")
    endif()

    # Change all the semicolons in the output to \x01
    string(ASCII 1 ONE)
    string(REPLACE ";" "${ONE}" ep_out "${ep_out}")
    #message(STATUS "After escaping =${ep_out}=")        # DEBUG

    # Normalize line endings, just in case
    string(REGEX REPLACE "\r|\n|\r\n" "\n" ep_out "${ep_out}")
    #message(STATUS "After line-endings =${ep_out}=")    # DEBUG

    # Turn the string into a list
    string(REPLACE "\n" ";" ep_out "${ep_out}")
    #message(STATUS "After listifying =${ep_out}=")      # DEBUG

    # Sort the list
    list(SORT ep_out)

    # Back to individual lines
    string(REPLACE ";" "\n" ep_out "${ep_out}")
    #message(STATUS "After back to lines =${ep_out}=")   # DEBUG

    # And back to semicolons.  Note: I am not trying to reverse line endings.
    string(REPLACE "${ONE}" ";" ep_out "${ep_out}")
    #message(STATUS "After unescaping =${ep_out}=")      # DEBUG

    # Out to the caller
    set(${P_RETVAL} "${ep_out}" PARENT_SCOPE)
    #message(STATUS "Returned =${ep_out}=")              # DEBUG

endfunction(run_and_sort)

