#!/usr/bin/env bats

load "test_helper"

# TODO:
# 1. test date in retro filename, freeze date?
# 2. test issue log
@test "goto_alphabet_repo" {
  goto_alphabet_repo
  assert_equal "$alphabet_repo_dir" "$PWD"
}


@test "goto_alphabet_issues" {
  goto_alphabet_issues
  assert_equal "$alphabet_issue_dir" "$PWD"
}

@test "alphabet_new_retro" {
  # only the template exists
  # pipe to xargs to trim spaces (on osx)
  assert_equal '1' "$(ls $alphabet_retro_dir | wc -l | xargs)"

  alphabet_new_retro
  # the template and the new retro exists
  assert_equal '2' "$(ls $alphabet_retro_dir | wc -l | xargs)"
}

@test "alphabet_new_issue_fail_regex" {
  # only issue_log exists
  assert_equal '1' "$(ls $alphabet_issue_dir | wc -l | xargs)"

  # need run to assert failure
  run alphabet_new_issue "asdf"

  assert_output "asdf must match ^ABC-([0-9]+)(.*)+"

  # no issue created, only issue_log exists
  assert_equal '1' "$(ls $alphabet_issue_dir | wc -l | xargs)"
  assert_failure
}

@test "alphabet_new_issue" {
  # note: if this gets flaky (e.g. run tests in random order),
  # assert_file_not_exist instead of counting files in the issue_dir
  # only issue_log exists
  assert_equal '1' "$(ls $alphabet_issue_dir | wc -l | xargs)"

  alphabet_new_issue "ABC-123"

  # should be on new branch
  assert_equal "feature/ABC-123" "$(git -C $alphabet_repo_dir symbolic-ref --short HEAD)"

  # should create tech design file
  assert_file_exist "$alphabet_issue_dir/ABC-123/tech.md"

  # should have exactly 2 directories in issues, the template and the new issue (ABC-123)
  assert_equal '2' "$(ls $alphabet_issue_dir | wc -l | xargs)"
}

@test "alphabet_new_issue bug" {
  # issue should not exist yet
  assert_file_not_exist "$alphabet_issue_dir/ABC-100-bugs/tech.md"

  alphabet_new_issue "ABC-100-bugs" "bug"

  # should be on new branch of type bug
  assert_equal "bug/ABC-100-bugs" "$(git -C $alphabet_repo_dir symbolic-ref --short HEAD)"

  # should create tech design file
  assert_file_exist "$alphabet_issue_dir/ABC-100-bugs/tech.md"
}

@test "goto_current_issue" {
  alphabet_new_issue "ABC-222"
  goto_alphabet_current_issue

  assert_equal "$alphabet_issue_dir/ABC-222" "$PWD"
}

@test "current_issue" {
  alphabet_new_issue "ABC-001-cat"

  assert_equal "ABC-001-cat" "$(alphabet_current_issue)"
}

@test "alphabet_new_issue_stash" {
  # create changes and add them to check stash works
  touch "$alphabet_repo_dir/asdf"
  git -C "$alphabet_repo_dir" add "$alphabet_repo_dir/asdf"

  alphabet_new_issue "ABC-456789"

  # should have stashed changes if they exist
  assert_equal "stash@{0}: On ABC-001-cat: pre feature/ABC-456789" "$(git --no-pager -C $alphabet_repo_dir stash list -1)"
}

@test "alphabet_version" {
  assert_equal "$(alphabet_version)" "0.2.0"
}