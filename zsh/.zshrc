## Zsh Configuration

#######################################
# Internal functions
#######################################
function has() {
  which "$@" > /dev/null 2>&1
}

# ZSH history search and keybinds
ZSH_HIST_SUBSTRING_SEARCH_IGNORE_CASE=true
HISTSIZE=1048576
SAVEHIST=$HISTSIZE
HISTFILE=$HOME/.zsh_history

setopt APPEND_HISTORY         # Appends history to the file instead of overwriting.
setopt INC_APPEND_HISTORY     # Saves history after each command, not just on exit.
setopt SHARE_HISTORY          # Shares history between concurrent sessions.
setopt HIST_IGNORE_ALL_DUPS   # don’t keep duplicate lines
setopt HIST_REDUCE_BLANKS     # trim extra spaces before saving

autoload -Uz history-beginning-search-backward history-beginning-search-forward
autoload -Uz backward-char forward-char
autoload -Uz up-line-or-history down-line-or-history

typeset -g _hist_locked=0

# Lock when you press ← / →
lock-left()  { _hist_locked=1; zle backward-char; }
lock-right() { _hist_locked=1; zle forward-char; }

smart-up() {
  if (( _hist_locked )) && [[ $BUFFER == *$'\n'* ]]; then
    # Locked + multiline: move within buffer only; never switch history
    [[ $LBUFFER == *$'\n'* ]] && zle .up-line-or-history || zle beginning-of-line
  else
    _hist_locked=0
    zle history-beginning-search-backward
  fi
}

smart-down() {
  if (( _hist_locked )) && [[ $BUFFER == *$'\n'* ]]; then
    # Locked + multiline: move within buffer only; never switch history
    [[ $RBUFFER == *$'\n'* ]] && zle .down-line-or-history || zle end-of-line
  else
    _hist_locked=0
    zle history-beginning-search-forward
  fi
}

# (Optional) when you press Enter, clear the lock for the next command
accept-and-unlock() { _hist_locked=0; zle .accept-line; }

zle -N smart-up
zle -N smart-down
zle -N lock-left
zle -N lock-right
zle -N accept-and-unlock

# Bindings (emacs & vi insert)
for km in emacs viins; do
  bindkey -M $km '^[[A'  smart-up
  bindkey -M $km '^[[B'  smart-down
  bindkey -M $km '^[OA'  smart-up
  bindkey -M $km '^[OB'  smart-down
  bindkey -M $km '^[[D'  lock-left
  bindkey -M $km '^[[C'  lock-right
  bindkey -M $km '^M'    accept-and-unlock     # Enter (optional)
done

# # Cycle through history based on characters already typed on the line
# autoload -U history-search-end
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end history-search-end
# bindkey "^[[A" history-beginning-search-backward-end
# bindkey "^[[B" history-beginning-search-forward-end


# Key binds
bindkey "^[[H"  beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[3~" delete-char
export TERM=xterm-256color


# Alias
alias ll="ls -l"
alias la="ls -la"
alias cls="clear"
alias t="terraform"
alias k="kubectl"
alias kctx="kubectl ctx"
alias kns="kubectl ns"
alias ap="aws-profiles"

## Starship init
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

## zsh configuration
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export TERM=xterm-256color
export PATH=$HOME/.dotfiles/bin:${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH
export CLICOLOR=YES

## Interos CLI
export PATH="/Users/jlim/.interos/toolkit/bin:$PATH"

## Add Krew PATH
export PATH=${KREW_ROOT:-$HOME/.krew}/bin:$PATH

## ASDF 0.15.0 configuration
export ASDF_DIR=$HOME/.asdf
. "$HOME/.asdf/asdf.sh"
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

## Granted configuration
alias assume='source $(asdf which assume)'
