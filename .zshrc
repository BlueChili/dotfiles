# Add deno completions to search path
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi
# Path to your oh-my-zsh installation.
ZSH=~/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME=""

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(docker git-prompt)

# User configuration

export PATH="$HOME/.npm-global/bin:$HOME/go/bin:$PATH"
export PATH="$PATH:$HOME/Hubstaff"
export PATH="$HOME/.local/bin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"i

alias lal="ls -al"
alias ll="ls -l"
alias droplet="ssh root@68.183.56.22 -i .ssh/archiedesk"
# eval "$(rbenv init -)"

# auto completion for:
# tmux
#source /usr/local/etc/bash_completion.d/tmux

export EDITOR="nvim"
#exec fortune -a /Users/BlueChili/.oh-my-zsh/plugins/chucknorris/fortunes | cowthink
# exec fortune | cowthink
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Edit command lined inside vim
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

export PROMPT='%F{green}%2~ %F{red}%(?..%? )%F{blue}$ %f'
# export TERM=xterm-256color
ZDOTDIR="$HOME/.config/zsh"
source $ZDOTDIR/.zshrc
alias vim="nvim"
alias dwmrice="cd ~/aur/dwm && nvim config.h && rm -rf dwm-* pkg src && makepkg -si --skipinteg"
alias strice="cd ~/aur/st && nvim config.h && rm -rf *.tar.zst && makepkg -si"
#alias server_unironical_vultr="ssh root@unironical.vultr"
# alias server_unironical_vultr="ssh root@unironical.vultr -t tmux attach"
alias sxrice="pkill sxhkd && nvim ~/.config/sxhkd/sxhkdrc"
alias upworkrice="yay --editmenu upwork"
alias gcmsg="git commit -m"
alias gst="git status"
alias gd="git diff"
alias gdw="git diff --word-diff"
alias ga="git add"
alias gp="git push"
alias gco="git checkout"
alias gcko-="git checkout -"
alias ipadr="ip address"
alias wifidown="iwctl station wlan0 disconnect"
alias wifiup="iwctl station wlan0 connect MORDOR"
alias nvrice="cd ~/.config/nvim && nvim . && exit"
alias dev="npm run dev"
alias bdev="bun run dev"
alias bbuild="bun run build"
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh
export FZF_DEFAULT_COMMAND='rg --files --no-hidden -i '
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
unset npm_config_prefix

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=/opt/google-cloud-cli/bin:$PATH
# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
eval "$(pyenv virtualenv-init -)"

export PATH="$PATH:/usr/lib/docker/cli-plugins"
alias pivot_containers="docker-compose up database nats temporal nats-init localstack localstack-init temporal-init"
alias pivot_backend="pnpm nx run-many -t serve -p visa friend blockhead messenger buzzbuzz facebox blobby"
alias pivot_expo="pnpm nx serve pivot-expo"
alias gclphoenix="gcloud compute ssh mjsync-machine-phoenix --project=sonoranroots --zone=us-west1-a"
alias gclelfsight="gcloud compute ssh elfsight --project=sonoranroots --zone=us-west1-a"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
. "$HOME/.deno/env"
# Initialize zsh completions (added by deno install script)
autoload -Uz compinit
compinit
