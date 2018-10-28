# multiline_matcher.cmake: Make a regex that will match multiple consecutive
# lines in any order.  For use in editorconfig; see
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

set( CMAKE_LEGACY_CYGWIN_WIN32 0 )
cmake_minimum_required( VERSION 3.5.0 )
cmake_policy(SET CMP0054 NEW)

# Conventions:
#   - "P_*" are parameters parsed using cmake_parse_arguments
#   - Any parameter called "RETVAL", "RETVAL_*", or "*_NAME" should be given
#       the name of a variable in the caller's scope into which to
#       store results.

# This file implements the Johnson-Trotter
# algorithm described at https://sourceforge.net/projects/swappermutation/
# (by wvasperen, BSD licensed).  Additional info is at
# http://www.cut-the-knot.org/Curriculum/Combinatorics/JohnsonTrotter.shtml
# and https://tropenhitze.wordpress.com/2010/01/25/steinhaus-johnson-trotter-permutation-algorithm-explained-and-implemented-in-java/ .

###########################################################################
# Constants

set( ECT_MATCH_LINE_START "(^|[\n\r]+)" )
set( ECT_MATCH_LINE_END "[\n\r]+" )
#set( ECT_MATCH_LINE_START "<" )    # Easier to read when debugging
#set( ECT_MATCH_LINE_END ">" )
set( ECT_LEFT "- 1" )       # CAUTION: these are strings so I can use them
set( ECT_RIGHT "+ 1" )      # directly in math.
set( ECT_DONE -42 )   # special flag index that means we're done

###########################################################################
# Utility functions

# Set an element of a list
function( list_set LIST_NAME IDX VAL )
    list( LENGTH "${LIST_NAME}" len )
    math( EXPR max_idx "${len} - 1" )

    set( temp ${${LIST_NAME}} )

    list( REMOVE_AT temp "${IDX}" )
    if( "${IDX}" EQUAL "${max_idx}" )
        list( APPEND temp "${VAL}" )
    else()
        list( INSERT temp "${IDX}" "${VAL}" )
    endif()

    set( ${LIST_NAME} "${temp}" PARENT_SCOPE )  # send array back to caller
endfunction( list_set )

# Swap two elements in a list in-place
function( list_swap LIST_NAME IDX1 IDX2 )
    set( temp ${${LIST_NAME}} )   # Copy the list into our scope

    # Do the swap
    list( GET "${LIST_NAME}" "${IDX1}" item1 )
    list( GET "${LIST_NAME}" "${IDX2}" item2 )

    list_set( temp "${IDX1}" "${item2}" )
    list_set( temp "${IDX2}" "${item1}" )

    set( ${LIST_NAME} "${temp}" PARENT_SCOPE )  # send array back to caller
endfunction( list_swap )

###########################################################################
# Johnson-Trotter functions

function( switch_direction DIRS_NAME IDX )
    #message( "Switching direction in ${${DIRS_NAME}} at ${IDX}" )
    set( dirs ${${DIRS_NAME}} )   # Copy the list into our scope

    list( GET dirs "${curridx}" this_dir )
    if( "${this_dir}" STREQUAL "${ECT_LEFT}" )
        set( new_dir "${ECT_RIGHT}" )
    else()
        set( new_dir "${ECT_LEFT}" )
    endif()
    list_set( dirs "${curridx}" "${new_dir}" )

    set( ${DIRS_NAME} "${dirs}" PARENT_SCOPE )  # send array back to caller
endfunction( switch_direction )

# Is item IDX a mobile item in A[]?
function( jt_is_mobile )
    # Argument parsing
    set( one_value_keywords RETVAL IDX )
    set( multi_value_keywords A DIRS )
    cmake_parse_arguments( P "" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN} )

    list( LENGTH P_A len_a )
    math( EXPR max_a "${len_a} - 1" )
    list( GET P_DIRS "${P_IDX}" curr_dir )

    #message( "jt_is_mobile: retval name ${P_RETVAL} index ${P_IDX} dir ${curr_dir}" )
    #message( "              A ${P_A} len ${len_a}; dirs ${P_DIRS}" )

    set( rv TRUE )
        # unless one of the tests below says otherwise

    if(  ( "${P_IDX}" EQUAL "0" ) AND ( "${curr_dir}" STREQUAL "${ECT_LEFT}" )  )
        set( rv FALSE )

    elseif(  ( "${P_IDX}" EQUAL "${max_a}" ) AND ( "${curr_dir}" STREQUAL "${ECT_RIGHT}" )  )
        set( rv FALSE )

    else()
        list( GET a "${P_IDX}" curr_a )
        math( EXPR next_idx "${P_IDX} ${curr_dir}" )   # curr_dir = +/-1
        list( GET a "${next_idx}" next_a )

        if( "${next_a}" GREATER "${curr_a}" )
            set( rv FALSE )
        endif()

    endif()

    #message( "              Result: ${rv}" )
    set( ${P_RETVAL} "${rv}" PARENT_SCOPE )
endfunction( jt_is_mobile )

# Find the position of the largest mobile integer in A[]
function( jt_find_mobile )
    # Argument parsing
    set( one_value_keywords RETVAL_IDX RETVAL_ITEM )
    set( multi_value_keywords A DIRS )
    cmake_parse_arguments( P "" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN} )

    # Work
    set( chosen -1 )      # item numbers are >=1
    set( chosen_idx -1 )
    set( saw_mobile FALSE )   # if it's false at the end, we're done

    list( LENGTH P_A len_a )
    math( EXPR max_a "${len_a} - 1" )

    foreach( curridx RANGE 0 "${max_a}" )
        list( GET P_A "${curridx}" curr_item )
        jt_is_mobile( RETVAL ismobile IDX "${curridx}" A ${P_A} DIRS ${P_DIRS} )

        if( "${ismobile}" )
            set( saw_mobile TRUE )
        endif()

        if( "${ismobile}" AND ( "${curr_item}" GREATER "${chosen}" ) )
            set( chosen "${curr_item}" )
            set( chosen_idx "${curridx}" )
        endif()
    endforeach()

    if( "${saw_mobile}" )
        set( ${P_RETVAL_IDX} "${chosen_idx}" PARENT_SCOPE )
        set( ${P_RETVAL_ITEM} "${chosen}" PARENT_SCOPE )
    else()
        set( ${P_RETVAL_IDX} "${ECT_DONE}" PARENT_SCOPE )
    endif()
endfunction( jt_find_mobile )

# Make the next permutation.
function( jt_make_next )
    # Argument parsing
    set( one_value_keywords DONE A_NAME DIRS_NAME )
    set( multi_value_keywords "" )
    cmake_parse_arguments( P "" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN} )

    set( new_a ${${P_A_NAME}} )       # local work vars
    set( new_dirs ${${P_DIRS_NAME}} )

    #message( "jt_make_next: A_NAME ${P_A_NAME}; DIRS_NAME ${P_DIRS_NAME}" )
    #message( "jt_make_next: A ${new_a}; dirs ${new_dirs}" )

    jt_find_mobile( RETVAL_IDX mobile_idx RETVAL_ITEM mobile_item A ${new_a} DIRS ${new_dirs} )

    if( "${mobile_idx}" EQUAL "${ECT_DONE}" )
        set( ${P_DONE} TRUE PARENT_SCOPE )
    else()
        #message( "  found mobile item ${mobile_item} at ${mobile_idx}" )

        set( ${P_DONE} FALSE PARENT_SCOPE )

        # Swap the largest mobile index with its neighbor
        list( GET new_dirs "${mobile_idx}" mobile_dir )
        math( EXPR next_idx "${mobile_idx} ${mobile_dir}" )
        list( GET new_a "${next_idx}" next_item )
        list( GET new_dirs "${next_idx}" next_dir )

        # Do the swap
        list_swap( new_a "${mobile_idx}" "${next_idx}" )
        list_swap( new_dirs "${mobile_idx}" "${next_idx}" )

        # Now reverse the direction of all items larger than the latest
        # mobile item.
        list( LENGTH new_a len_a )
        math( EXPR max_a "${len_a} - 1" )
        foreach( curridx RANGE 0 "${max_a}" )
            list( GET new_a "${curridx}" this_a )
            if( ${this_a} GREATER "${mobile_item}" )
                switch_direction( new_dirs "${curridx}" )
            endif()

        endforeach()

        #message( "  after mod: A ${new_a}; dirs ${new_dirs}" )

        # send locals back to caller
        set( ${P_A_NAME} "${new_a}" PARENT_SCOPE )
        set( ${P_DIRS_NAME} "${new_dirs}" PARENT_SCOPE )
    endif()

endfunction( jt_make_next )

# Assemble one permutation into a regex that will match the given regexes on
# consecutive lines, in the given order.
function( re_assemble_perm )

    # Argument parsing
    set( one_value_keywords RETVAL )
    set( multi_value_keywords ORDER EXPECTED )
    cmake_parse_arguments( P "" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN} )

    #message( "Assembling in order ${P_ORDER} the regexes ${P_EXPECTED}" )

    list( LENGTH P_EXPECTED NR )
    math( EXPR maxr "${NR} - 1" )
    set( rv "${ECT_MATCH_LINE_START}" )
    foreach( idx RANGE 0 "${maxr}" )
        list( GET P_ORDER "${idx}" curr_order )
        math( EXPR curr_order "${curr_order} - 1" )   # 1-based -> 0-based
        list( GET P_EXPECTED "${curr_order}" curr_regex )
        set( rv "${rv}${curr_regex}${ECT_MATCH_LINE_END}" )
    endforeach()

    set( ${P_RETVAL} "${rv}" PARENT_SCOPE )     # return
endfunction( re_assemble_perm )

# Make a regex to match the given regexes on successive lines, in any order.
# Each input regex should match one whole line.  A line anchor at the beginning
# and at the end will automatically be added, but leading/trailing whitespace
# is left to the caller.
function( make_regex_of_permutations )

    # Argument parsing
    set( options FORCE )
    set( one_value_keywords RETVAL )
    set( multi_value_keywords EXPECTED )
    cmake_parse_arguments( P "${options}" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN} )

    #message( "Retval name:       " "${P_RETVAL}" )
    #message( "Regexes:           " "${P_EXPECTED}" )
    #message( "Force:             " "${P_FORCE}" )

    list( LENGTH P_EXPECTED NR )     # NR = how many regexes

    if("${NR}" EQUAL "0")
        message(FATAL_ERROR "EXPECTED argument required")
        return()
    endif()

    # Degenerate case: single element.  Warn because there is almost certainly
    # no need to use this macro in that case.
    if("${NR}" EQUAL "1")
        list(GET P_EXPECTED 0 elem)
        message(WARNING "Only one regex given.  Did you forget one?")
        set( ${P_RETVAL} "${elem}" PARENT_SCOPE )
        return()
    endif()

    # CMake regexes are limited to nine groups, as far as I can tell.  That
    # means we can only use regexes with go up to 3! = 6 permutations.
    # However, this function can generate any number of permutations,
    # if you specify FORCE.
    if( ( NOT "${P_FORCE}" ) AND ( "${NR}" GREATER "3" ) )
        message(FATAL_ERROR "CMake can't handle as many parentheses as I'll need to handle ${NR} regexes.  Sorry!")
    endif()

    # Get number of permutations, and set up for the Johnson-Trotter
    # algorithm
    set( NP 1 )                     # NP = how many permutations = NR!
    set( a "1" )                    # J-T current permutation
    set( dirs "${ECT_LEFT}" )       # J-T direction
    foreach( idx RANGE 2 "${NR}" )  # NR >= 2 because we checked 0 and 1 above
        math( EXPR NP "${NP} * ${idx}" )
        set( a "${a};${idx}" )
        set( dirs "${dirs};${ECT_LEFT}" )
    endforeach()

    #message( "  Regexes:      ${NR}" )
    #message( "  Permutations: ${NP}" )
    #message( "  a:            ${a}" )
    #message( "  dirs:         ${dirs}" )

    # Do perm 1
    re_assemble_perm( RETVAL curr_re ORDER ${a} EXPECTED ${P_EXPECTED} )
    #message( "  Perm 0 is: ${curr_re}" )
    set( rv "${curr_re}" )      # the regex we are building

    # Main loop
    foreach( permidx RANGE 2 "${NP}" )  # 2..${NP} inclusive

        jt_make_next( DONE jt_done A_NAME a DIRS_NAME dirs )
        if( jt_done )
            #message( WARNING "Done early!  Possible logic error?" )
            break()
        endif( jt_done )
        #message( "Got new order ${a}" )

        re_assemble_perm( RETVAL curr_re ORDER ${a} EXPECTED ${P_EXPECTED} )
        #message( "  Perm is: ${curr_re}" )
        set( rv "${rv}|${curr_re}" )
    endforeach()

    #message( "  Complete RE is: /${rv}/" )

    set( ${P_RETVAL} "${rv}" PARENT_SCOPE )     # return
endfunction( make_regex_of_permutations )

