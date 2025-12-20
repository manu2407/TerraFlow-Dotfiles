if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    set -g fish_greeting
    alias ld="lazydocker"
    alias lg="lazygit"
    alias refresh="sudo update-desktop-database && rm -f ~/.cache/nwg-drawer/data && echo 'Menu Refreshed'"
    set -gx PATH $HOME/.local/bin $PATH
end
