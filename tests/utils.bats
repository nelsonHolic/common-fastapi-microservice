#!/usr/bin/env bats

load "test_helper"

# TODO:
# 1. test date in retro filename, freeze date?
# 2. test issue log
@test "goto_alphabet_repo" {
  goto_alphabet_repo
  assert_equal "$alphabet_repo_dir" "$PWD"
}

@test "alphabet_version" {
  assert_equal "$(alphabet_version)" "0.2.0"
}