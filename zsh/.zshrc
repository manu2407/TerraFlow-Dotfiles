# ~/.zshrc - TerraFlow Dotfiles
# Main Zsh configuration

# ─────────────────────────────────────────────
# Environment
# ─────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="ghostty"
export BROWSER="zen-browser"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Path
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# ─────────────────────────────────────────────
# History
# ─────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ─────────────────────────────────────────────
# Plugins (using zinit)
# ─────────────────────────────────────────────
# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Essential plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# ─────────────────────────────────────────────
# Completions
# ─────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ─────────────────────────────────────────────
# Tool Integrations
# ─────────────────────────────────────────────
# Starship prompt
eval "$(starship init zsh)"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# fzf keybindings
source <(fzf --zsh)

# ─────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────
# Modern replacements
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias lt="eza --tree --icons --level=2"
alias cat="bat"
alias grep="rg"
alias find="fd"

# Git
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="lazygit"

# System
alias update="paru -Syu"
alias cleanup="paru -Sc"

# TerraFlow
alias store="~/TerraFlow-Dotfiles/terra-store/target/release/terra_store"

# Quick edit
alias zshrc="nvim ~/TerraFlow-Dotfiles/zsh/.zshrc"
alias hyprconf="nvim ~/TerraFlow-Dotfiles/hyprland/"

# ─────────────────────────────────────────────
# Keybindings
# ─────────────────────────────────────────────
bindkey -e  # Emacs mode
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
