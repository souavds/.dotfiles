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
alias ar "asdf reshim"

# asdf
source ~/.asdf/asdf.fish

# plugins options
set fzf_preview_dir_cmd eza --all --color=always
set fzf_preview_file_cmd bat --color=always --style=numbers

# sourcing
starship init fish | source
zoxide init fish | source

# on startup
#macchina
