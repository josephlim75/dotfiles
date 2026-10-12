resolve_symlink_target() {
  local src="$1" dir link

  while [[ -L "$src" ]]; do
    dir="$(cd -P "$(dirname "$src")" && pwd)" || return 1
    link="$(readlink "$src")" || return 1

    case "$link" in
      /*) src="$link" ;;
      *)  src="$dir/$link" ;;
    esac
  done

  printf '%s\n' "$src"
}

lineinfile() {
  local pattern="$1"
  local line="$2"
  local file="$3"
  local dir tmp

  file="$(resolve_symlink_target "$file")" || return 1

  dir=$(dirname "$file")
  [ -d "$dir" ] || mkdir -p "$dir"
  [ -f "$file" ] || : > "$file"

  tmp="${file}.$$"

  awk -v pattern="$pattern" -v line="$line" '
    $0 ~ pattern {
      if (!done) {
        print line
        done = 1
      }
      next
    }
    { print }
    END {
      if (!done) {
        print line
      }
    }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

######################################
# Usage:
# Call the cross-platform function (prepend is the default)
#   blockinfile "my_app.conf" << 'EOF'
#   listen_port = 5080
#   enable_metrics = true
#   EOF
# Append instead:
#   blockinfile "/tmp/test.conf" append < /path/to/my_config.conf
# Use a custom comment marker:
#   blockinfile "/tmp/test.conf" prepend ";" < /path/to/my_config.conf
# Defaults can also be set with DOTFILES_BLKINFILE_PLACEMENT and
# DOTFILES_BLKINFILE_MARKER; positional arguments take precedence.
#####################################
blockinfile() {
  local target_file="$1"
  local placement="${2:-${DOTFILES_BLKINFILE_PLACEMENT:-append}}"
  local comment_marker="${3:-${DOTFILES_BLKINFILE_MARKER:-#}}"
  local start_marker="${comment_marker} BEGIN DOTFILES MANAGED BLOCK"
  local end_marker="${comment_marker} END DOTFILES MANAGED BLOCK"
  local tmp_file

  target_file="$(resolve_symlink_target "$target_file")" || return 1

  case "${placement}" in
    prepend|append) ;;
    *)
      echo "blockinfile: placement must be 'prepend' or 'append'" >&2
      return 1
      ;;
  esac

  # 1. Read multi-line block content from stdin
  local block_content
  block_content=$(cat)

  # 2. Extract parent directory and create it if it does not exist
  local target_dir
  target_dir=$(dirname "${target_file}")
  mkdir -p "${target_dir}"
  # 3. Touch the file to guarantee it exists before reading/grepping
  touch "${target_file}"

  # An existing managed block is left untouched.
  if grep -qF "${start_marker}" "${target_file}" 2>/dev/null; then
    return 0
  fi

  tmp_file=$(mktemp)

  # Stage the new block in the requested position.
  if [[ "${placement}" == "prepend" ]]; then
    {
      printf '%s\n' "${start_marker}"
      printf '%s\n' "${block_content}"
      printf '%s\n' "${end_marker}"
      cat "${target_file}"
    } > "${tmp_file}"
  else
    {
      cat "${target_file}"
      if [[ -s "${target_file}" && -n "$(tail -c 1 "${target_file}")" ]]; then
        printf '\n'
      fi
      printf '%s\n' "${start_marker}"
      printf '%s\n' "${block_content}"
      printf '%s\n' "${end_marker}"
    } > "${tmp_file}"
  fi

  # Move the finalized content safely over the target file
  mv "${tmp_file}" "${target_file}"
}