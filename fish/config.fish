# options
set fish_greeting ""
set -gx TERM xterm-256color
set -gx EDITOR nvim

# aliases
alias cz "z"
alias cat "bat"
alias ls "eza --icons"
alias v "nvim"
alias vcfg "cd ~/dotfiles && v"
alias g "lazygit"

# plugins options
set fzf_preview_dir_cmd eza --all --color=always
set fzf_preview_file_cmd bat --color=always --style=numbers

# sourcing
starship init fish | source
zoxide init fish | source
mise activate fish | source

# on startup
#macchina

# paths


# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
