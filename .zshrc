#zsh-hook
autoload -U add-zsh-hook

#Package Manager
# ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit if it's not there
# if [ ! -d "$ZINIT_HOME" ]; then
# 	mkdir -p "$(dirname $ZINIT_HOME)"
# 	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
# fi

# Source/load zinit
# source "${ZINIT_HOME}/zinit.zsh"

#Plugin syntax highlighting the important ones
# zinit light zsh-users/zsh-syntax-highlighting
# zinit light zsh-users/zsh-completions
# zinit light zsh-users/zsh-autosuggestions
# zinit light Aloxaf/fzf-tab

#Add snippets
# zinit snippet OMZP::git

#Shell integrations
# tmux has-session -t development
# if [ $? != 0 ]
# then
#   tmux new-session -s development
# fi
# tmux attach -t development
tmux attach
fastfetch
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

#Aliases
alias ls='ls --color'
alias ll='ls -la'
alias nixconfig='sudo hx ~/.config/nix/configuration.nix'
alias nixrebuild='sudo nixos-rebuild switch'
alias swayconfig='hx ~/.config/sway/config'
alias labenv='hx ~/.config/labwc/environment'
alias labmenu='hx ~/.config/labwc/menu.xml'
alias labrc='hx ~/.config/labwc/rc.xml'
alias waybarconfig='hx ~/.config/waybar/config'
alias waybarcss='hx ~/.config/waybar/style.css'
alias zshconfig='hx ~/.zshrc'
alias fzf='fzf -m --preview="bat --color=always {} "'
alias hxfzf='hx $(fzf)'
alias nixupdate='sudo nixos-rebuild switch --upgrade'

# Load completions
autoload -Uz compinit && compinit
# zinit cdreplay -q

# fzf-tab
source ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh

#Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

#configure autosggestions
bindkey '^f' autosuggest-accept

# Lines configured by zsh-newuser-install
HISTFILE=~/.config/zsh/.zshhist
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/jordi/.zshrc'


# End of lines added by compinstall
