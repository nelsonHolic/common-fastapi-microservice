#!/bin/bash
# https://github.com/rbenv/rbenv/blob/4e923221ce57a04ab52bddd638473d566347711f/test/test_helper.bash#L1

flunk() {
    { if [ "$#" -eq 0 ]; then cat -
        else echo "$@"
        fi
    } | sed "s:${BATS_TEST_DIRNAME}:TEST_DIR:g" >&2
    return 1
}

assert_success() {
    # status is same as $?, returns status code of last command.
    # shellcheck disable=SC2154
    if [ "$status" -ne 0 ]; then
        flunk "command failed with exit status $status"
    elif [ "$#" -gt 0 ]; then
        assert_output "$1"
    fi
}

assert_failure() {
    if [ "$status" -eq 0 ]; then
        flunk "expected failed exit status"
    elif [ "$#" -gt 0 ]; then
        assert_output "$1"
    fi
}

assert_equal() {
    if [ "$1" != "$2" ]; then
        { echo "expected: '$1'"
          echo "actual:   '$2'"
        } | flunk
    fi
}

assert_match() {
    if ! [[ "$2" =~ $1 ]]; then
        {
            echo "expected '$2' to match '$1'"
        } | flunk
    fi
}

assert_partial() {
    if [[ "$2" == *"$1"* ]]; then
        {
            echo "expected '$1' to be in '$2'"
        } | flunk
    fi
}


assert_output() {
    local expected
    if [ $# -eq 0 ]; then expected="$(cat -)"
    else expected="$1"
    fi
    assert_equal "$expected" "$output"
}

assert_line() {
    if [ "$1" -ge 0 ] 2>/dev/null; then
        assert_equal "$2" "${lines[$1]}"
    else
        local line
        for line in "${lines[@]}"; do
            if [ "$line" = "$1" ]; then return 0; fi
        done
        flunk "expected line \`$1'"
    fi
}

refute_line() {
    if [ "$1" -ge 0 ] 2>/dev/null; then
        local num_lines="${#lines[@]}"
        if [ "$1" -lt "$num_lines" ]; then
            flunk "output has $num_lines lines"
        fi
    else
        local line
        for line in "${lines[@]}"; do
            if [ "$line" = "$1" ]; then
                flunk "expected to not find line \`$line'"
            fi
        done
    fi
}

assert() {
    if ! "$@"; then
        flunk "failed: $@"
    fi
}

# https://github.com/ztombol/bats-file/blob/master/src/file.bash
# bats-file - Common filesystem assertions and helpers for Bats
#
# Written in 2016 by Zoltan Tombol <zoltan dot tombol at gmail dot com>
#
# To the extent possible under law, the author(s) have dedicated all
# copyright and related and neighboring rights to this software to the
# public domain worldwide. This software is distributed without any
# warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication
# along with this software. If not, see
# <http://creativecommons.org/publicdomain/zero/1.0/>.
#

#
# file.bash
# ---------
#
# Assertions are functions that perform a test and output relevant
# information on failure to help debugging. They return 1 on failure
# and 0 otherwise.
#
# All output is formatted for readability using the functions of
# `output.bash' and sent to the standard error.
#

# Fail and display path of the file (or directory) if it does not exist.
# This function is the logical complement of `assert_file_not_exist'.
#
# Globals:
#   BATSLIB_FILE_PATH_REM
#   BATSLIB_FILE_PATH_ADD
# Arguments:
#   $1 - path
# Returns:
#   0 - file exists
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_file_exist() {
    local -r file="$1"
    if [[ ! -e "$file" ]]; then
        local -r rem="$BATSLIB_FILE_PATH_REM"
        local -r add="$BATSLIB_FILE_PATH_ADD"
        flunk "$1 does not exist"
    fi
}

# Fail and display path of the file (or directory) if it exists. This
# function is the logical complement of `assert_file_exist'.
#
# Globals:
#   BATSLIB_FILE_PATH_REM
#   BATSLIB_FILE_PATH_ADD
# Arguments:
#   $1 - path
# Returns:
#   0 - file does not exist
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_file_not_exist() {
    local -r file="$1"
    if [[ -e "$file" ]]; then
        local -r rem="$BATSLIB_FILE_PATH_REM"
        local -r add="$BATSLIB_FILE_PATH_ADD"
        flunk "$1 exists, but it was expected to be absent"
    fi
}

##############################
# custom setup and teardown
setup_example_files() {
    # make temp directory and example files
    target_dir=$(mktemp -d '/tmp/examples_XXX')
    # # https://github.com/sstephenson/bats/issues/191
    # if [[ "$DEBUG" == 'true' ]]; then
    #     run bash -c "(>&2 echo $target_dir)"
    # fi
    touch "$target_dir/first.EXAMPLE"
    touch "$target_dir/second.example"
}

# find files without any extension
# relies on setup_example_files not including extra extensions
list_non_example_files() {
    find "$1" -type f ! -iname "*.*"
}

# run script from bash_scripts root dir, relative to test dir.
run_relative() {
    run bash -c "${BATS_TEST_DIRNAME}/../$1"
}


project_dir="alphabet"
repo_dir="$PWD/$project_dir/$project_dir"

cleanup() {
    # handle case where teardown doesn't run because of unhandled failure
    # check if dir already exists, if it does delete it
    if [ -d "$project_dir" ]; then
        rm -rf "$project_dir"
    fi
}

# https://github.com/bats-core/bats-core/issues/39#issuecomment-377015447
setup() {
    # only run before first test
    if [[ "$BATS_TEST_NUMBER" -eq 1 ]]; then
        cleanup

        # setup example project so utils.sh exists and can be tested
        # stub editor by using echo instead
        poetry run cookiecutter . \
            --overwrite-if-exists \
            --no-input \
            project_name="$repo_dir" \
            editor="echo"

        # setup example repo
        mkdir "$repo_dir"
        git init "$repo_dir"
        # TODO: use local filesystem as fake remote, using this repo on github for now since it only pulls, never push.
        # https://stackoverflow.com/questions/10603671/how-to-add-a-local-repo-and-treat-it-as-a-remote-repo
        # git -C "$repo_dir/.git" remote add origin "$fake_remote/.git"
        # https://stackoverflow.com/a/35899275/6305204
        git -C "$repo_dir" remote add origin "https://github.com/nelsonHolic/common-fastapi-microservice.git"
        git -C "$repo_dir" fetch
        git -C "$repo_dir" checkout main
        # git branch --set-upstream-to=origin/master master
    fi

    # load functions to be tested
    load "$project_dir/utils.sh"
}

teardown() {
    if [[ "${#BATS_TEST_NAMES[@]}" -eq "$BATS_TEST_NUMBER" ]]; then
        cleanup
    fi
}