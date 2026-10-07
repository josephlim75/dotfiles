######################################
# Borrowed from : 
# https://gist.github.com/kokumura/a6d819ddcb4efe54c5541fc15e1d0347
######################################
lineinfile() {
  if [[ $# != 3 ]]; then
    return 1
  fi
  local pattern="$1"
  local line="$2"
  local filepath="$3"
  local dir=$(dirname $filepath)

  [[ ! -d "$dir" ]] && mkdir -p "$dir"
  [[ ! -f "$filepath" ]] && touch "$filepath"

  if grep -E -q "${pattern}" "${filepath}" ;then
    ## solution 1: works with GNU sed well, but not works with BSD sed.
    #sed -E -i '' "/${pattern//\//\\/}/c${line}" "${filepath}"
    ## solution 2: works with both (GNU|BSD) sed, but get useless *.bak file generated.
    # sed -E -i.bak "/${pattern//\//\\/}/c\\"$'\n'"${line}" "${filepath}"
    ## solution 3: give up to use sed, using perl instead.
    pattern="${pattern}" line="${line}" perl -i -nle 'if(/$ENV{"pattern"}/){print $ENV{"line"}}else{print}' "${filepath}"
  else
    echo "$line" >> "$filepath"
  fi
}

######################################
# Usage:
# Call the cross-platform function
#   blockinfile "my_app.conf" << 'EOF'
#   listen_port = 5080
#   enable_metrics = true
#   EOF
#####################################
blockinfile() {
  local target_file="$1"
  local comment_marker="${2:-#}"
  local start_marker="${comment_marker} BEGIN DOTFILES MANAGED BLOCK"
  local end_marker="${comment_marker} END DOTFILES MANAGED BLOCK"
  local tmp_file

  tmp_file=$(mktemp)

  # 1. Read multi-line block content from stdin
  local block_content
  block_content=$(cat)

  # 2. Extract parent directory and create it if it does not exist
  local target_dir
  target_dir=$(dirname "${target_file}")
  mkdir -p "${target_dir}"
  # 3. Touch the file to guarantee it exists before reading/grepping
  touch "${target_file}"

  # Cross-platform "sed -i" alternative: read to tmp, then replace the original file
  if grep -qF "${start_marker}" "${target_file}" 2>/dev/null; then
    # Strips out any existing older blocks
    sed "/${start_marker}/,/${end_marker}/d" "${target_file}" > "${tmp_file}"
  else
    cat "${target_file}" > "${tmp_file}"
  fi

  # Append the managed block with your boundaries to the temporary staging file
  {
    echo "${start_marker}"
    echo "${block_content}"
    echo "${end_marker}"
  } >> "${tmp_file}"

  # Move the finalized content safely over the target file
  mv "${tmp_file}" "${target_file}"
}