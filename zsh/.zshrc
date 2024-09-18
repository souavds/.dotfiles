# Init plugin manager: znit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Options
export EDITOR=nvim

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

# Aliases
alias cd="z"
alias cat="bat"
alias ls="eza --icons"
alias vim="nvim"
alias lzg="lazygit"
alias lzd="lazydocker" 

# Shell integrations
eval "$(oh-my-posh init zsh)"
eval "$(fzf --zsh)"
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(zellij setup --generate-auto-start zsh)"
