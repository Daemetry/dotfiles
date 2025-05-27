export TERM='xterm-256color'
export PATH="$PATH:/home/daemetry/.local/bin"

# zsh plugin manager directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# installing zinit if innit
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" 
fi

# source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

# other plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light unixorn/fzf-zsh-plugin
zinit light Aloxaf/fzf-tab

# hotkeys
bindkey '^f' autosuggest-accept
bindkey '^\b' backward-kill-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5A" history-search-backward
bindkey "^[[1;5B" history-search-forward

# history
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_query:*' fzf-preview 'ls --color $realpath'

autoload -Uz compinit && compinit
zinit cdreplay -q

# aliases
alias ls='ls --color'
alias lsa='ls --color --all'
alias c='clear'
alias nv='nvim'
alias mkdir='mkdir -p'
alias mv='mv -i'

_z_cd() {
    builtin cd "$@" || return "$?"

    if [ "$_ZO_ECHO" = "1" ]; then
        echo "$PWD"
    fi
}

cd() {
    if [ "$#" -eq 0 ]; then
        _z_cd ~
    elif [ "$#" -eq 1 ] && [ "$1" = '-' ]; then
        if [ -n "$OLDPWD" ]; then
            _z_cd "$OLDPWD"
        else
            echo 'zoxide: $OLDPWD is not set'
            return 1
        fi
    else
	if [ -d "$1" ]; then
		_z_cd "$@"
	else
	        _zoxide_result="$(zoxide query -- "$@")" && _z_cd "$_zoxide_result"
	fi
    fi
}

cdi() {
    _zoxide_result="$(zoxide query -i -- "$@")" && _z_cd "$_zoxide_result"
}


alias cda='zoxide add'
alias cdq='zoxide query'
alias cdqi='zoxide query -i'
alias cdr='zoxide remove'
cdri() {
    _zoxide_result="$(zoxide query -i -- "$@")" && zoxide remove "$_zoxide_result"
}


_zoxide_hook() {
    zoxide add "$(pwd -L)"
}

chpwd_functions=(${chpwd_functions[@]} "_zoxide_hook")

eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/ohmyposh.toml)"
