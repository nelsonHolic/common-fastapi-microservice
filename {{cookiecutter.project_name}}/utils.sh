#!/bin/bash

{{cookiecutter.project_name|lower}}_version="0.2.0"

{{cookiecutter.project_name|lower}}_repo_dir="{{cookiecutter.repo_dir}}"
{{cookiecutter.project_name|lower}}_issue_dir="replace_me.base_dir/issues"
{{cookiecutter.project_name|lower}}_issue_log="${{cookiecutter.project_name|lower}}_issue_dir/issue_log"
{{cookiecutter.project_name|lower}}_retro_dir="replace_me.base_dir/retro"

goto_{{cookiecutter.project_name|lower}}_repo() {
  cd "${{cookiecutter.project_name|lower}}_repo_dir" || return 1
}

goto_{{cookiecutter.project_name|lower}}_issues() {
  cd "${{cookiecutter.project_name|lower}}_issue_dir" || return 1
}

goto_{{cookiecutter.project_name|lower}}_current_issue() {
  current_issue=$(tail -n 1 "${{cookiecutter.project_name|lower}}_issue_log")
  cd "${{cookiecutter.project_name|lower}}_issue_dir/$current_issue" || return 1
}

{{cookiecutter.project_name|lower}}_current_issue() {
  tail -n 1 "${{cookiecutter.project_name|lower}}_issue_log"
}

{{cookiecutter.project_name|lower}}_version() {
  echo "${{cookiecutter.project_name|lower}}_version"
}
