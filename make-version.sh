#!/usr/bin/env bash
#
# NOTE: This script can be run locally, but is intended for use by the github runner

set -euo pipefail

(return 0 2>/dev/null) && quit=return || quit=exit

usage() {
	echo "$(basename $0) [option]"
	echo "Update version info for a zpr bindings repo"
	echo "Options:"
	echo "  -d dir	Path to repository being versioned.  Defaults to ./"
	echo "  -s dir	Path to generator source.  Required"
	echo "  -r type	Release type.  One of: major, minor, patch.  Defaults to minor"
}

function get_repo() {
  local repo_long
  repo_long=$(git config --get remote.origin.url) || return 1
  echo "$(basename -s .git $repo_long)"
}

function parse_repo_name() {
  repo_parts=($(echo $repo | tr '-' ' ') )

  if [[ ${#repo_parts[@]} != 3 || ${repo_parts[0]} != "zpr" ]] ; then
    echo "Error: Unsupported repository"
    $quit 1
  fi

  lib=${repo_parts[1]}
  lang=${repo_parts[2]}

  case $lang in
    rs)
      pretty_lang="Rust"
      ;;
    go)
      pretty_lang="Go"
      ;;
    *)
      echo "Error: Unsupported language"
      $quit 1
      ;;
  esac

  case $lib in
    policy)
      pretty_lib="Policy IO"
      tool="protoc"
      ;;
    vsapi)
      pretty_lib="VSAPI"
      tool="thrift"
      tool_version_fix="s/Thrift version/Thrift/"
      ;;
    admin-api)
      pretty_lib="Admin Protocol"
      tool="capnp"
      tool_version_fix="s/Cap'n Proto version/CapnProto"
      ;;
    *)
      echo "Error: Unsupported target"
      $quit 1
      ;;
  esac

  echo "Versioning $pretty_lang bindings for $pretty_lib"
  echo "Using $tool toolchain"
}

function get_src_version() {
  src_repo=$(cd "$src_dir" && get_repo) || return 1
  if [[ "$src_repo" != "zpr-$lib" ]]; then
    echo "Repositories do not match"
	$quit 1
  fi
  echo "Reading version info from source repo at $src_dir"
  src_version=$(cd "$src_dir" && git describe --tags --always --abbrev=0)
  src_hash=$(cd "$src_dir" && git show -s --format=%h "$src_version")
}

function get_previous_versions() {
  old_src_file=$(cat "$src_version_filename")
  old_src_version=$(echo "$old_src_file" | cut -d' ' -f 1)
  old_this_version=$(cat "$this_version_filename")
  old_tool_version=$(cat "$tool_version_filename")
}

function check_src_version() {
  # TODO: check that the version hasn't gone backwards
  echo "Source version changed from $old_src_version to $src_version"
  echo "${src_version} ${src_hash}" > "$src_version_filename"
}

function check_tool_version() {
  tool_version=$($tool --version)
  tool_version=$( echo $tool_version | sed "${tool_version_fix:-""}" )

  if [[ "$old_tool_version" != "$tool_version" ]] ; then
    if [[ "${release_type:=minor}" != "major" ]]; then
      echo "WARNING: Toolchain version changed from $old_tool_version to $tool_version"
      echo "Please consider bumping the major version."
	fi
    echo "$tool_version" > "$tool_version_filename"
  fi
}

function bump_version() {
  case ${release_type:=minor} in
    major)
	  bump_major_version
      ;;
	minor)
      bump_minor_version
	  ;;
    patch)
	  bump_patch_version
	  ;;
	*)
	  bump_minor_version
	  ;;
  esac
}

function bump_major_version() {
  this_version=$(echo "$old_this_version" | awk -F . '{print "v" $1+1 ".0.0"}')
  echo "Bumping major version from $old_this_version to $this_version"
  echo "$this_version" > "$this_version_filename"
}

function bump_minor_version() {
  this_version=$(echo "$old_this_version" | awk -F . '{print $1 "." $2+1 ".0"}')
  echo "Bumping minor version from $old_this_version to $this_version"
  echo "$this_version" > "$this_version_filename"
}

function bump_patch_version() {
  this_version=$(echo "$old_this_version" | awk -F . '{print $1 "." $2 "." $3+1}')
  echo "Bumping patch version from $old_this_version to $this_version"
  echo "$this_version" > "$this_version_filename"
}

function update_rust_cargo() {
  version_regex="\([0-9]\+.[0-9]\+.[0-9]\+\)"
  sed -i "s/\(version = \"\)$version_regex\"/\1${this_version:1}\"/" Cargo.toml
}

function do_language_stuff() {
  case $lang in
    rs)
      update_rust_cargo
      ;;
    *)
      echo "Nothing language-specific to do"
      ;;
  esac
}

function populate_github_output() {
  if [[ -v GITHUB_OUTPUT ]]; then
    echo "title=[$this_version] Generate $pretty_lang bindings for $pretty_lib $src_version" >> "$GITHUB_OUTPUT"
    echo "body=This code was automatically generated using $tool_version." >> "$GITHUB_OUTPUT"
    echo "branch=generate-$this_version" >> "$GITHUB_OUTPUT"
  fi
}

function do_versioning() {
  echo "Reading version info for $pretty_lang bindings in $repo"
  src_version_filename="zpr-$lib.version"
  this_version_filename="this.version"
  tool_version_filename="$tool.version"

  get_previous_versions
  check_tool_version
  check_src_version
  bump_version
  do_language_stuff
  populate_github_output
}

while getopts 'hd:s:r:' opt; do
  case "$opt" in
    r)
	  if [[ "$OPTARG" =~ ^major|minor|patch$ ]]; then
		release_type="$OPTARG"
      else
		echo "Release type must be one of: major, minor, patch"
		$quit
	  fi
      ;;
    d)
	  version_dir=$(realpath "$OPTARG")
      ;;
	s)
	  src_dir=$(realpath "$OPTARG")
	  ;;
    h)
	  usage
	  $quit
      ;;
    ?)
      echo "Unexpected option"
	  $quit
      ;;
  esac
done

if [[ ! -d $src_dir ]]; then
  echo "Error: src_dir not specified"
  usage
  $quit
fi

cd "${version_dir:-./}"

repo=$(get_repo) || {
  echo "Error: Please invoke this script inside of a git repo or use -d to specify path"
  $quit 1
}

parse_repo_name

if ! get_src_version; then
  echo "Error: src_dir \"$src_dir\" is not a git repository"
  $quit
fi

do_versioning
