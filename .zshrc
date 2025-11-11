# Init plugin manager: znit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Options
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc
export SSH_AUTH_SOCK=~/.1password/agent.sock
export PATH="$HOME/.config/tmux/plugins/tmuxifier/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH" 
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# History
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Bindings
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# Aliases
alias cat="bat"
alias ls="eza --color --icons --git -a"
alias vim="nvim"
alias lzg="lazygit"
alias lzd="lazydocker" 

# Functions
function cd {
  z "$@" && eza --color --icons --git -a
}

function cvim {
  z "$@" && nvim
}

# Completion style
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color --icons --git -a $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color --icons --git -a $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza --color --icons --git -a $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza --color --icons --git -a $realpath'

# Shell integrations
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/theme.omp.json)"
eval "$(fzf --zsh)"
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(op completion zsh)"; compdef _op op
eval "$(tmuxifier init -)"
