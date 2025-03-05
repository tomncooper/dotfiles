### Config for OH MY ZSH ###

# Path to the oh-my-zsh installation.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="agnoster"
ZSH_THEME="pygmalion"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git-prompt history-substring-search zsh-syntax-highlighting)

ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

# Temp Fix for git prompt issue
zstyle ':omz:alpha:lib:git' async-prompt no

source $ZSH/oh-my-zsh.sh

### My shell configs ###

# Stop zsh recommending stupid things!
ENABLE_CORRECTION="false"
unsetopt correct_all

# Use Vim keybindings
bindkey -v
bindkey -M vicmd v edit-command-line

# Stop Home and End keys doing weird things
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
# Make the delete key do sensible things
bindkey "^[[3~" delete-char

# Read all the aliases
source $HOME/.zsh_aliases

alias zshconfig="vim ~/.zshrc"

#Stop Ctrl+S killing the screen updates in vim
stty -ixon

#Set default apps
export VISUAL=vim
export EDITOR=vim
export BROWSER=firefox

# Set the default wallpaper directory
export WALLPAPERS=$HOME/SynologyDrive/Photos/Wallpaper/

# Add user binaries to the path
export PATH=$PATH:$HOME/bin

# Add Kafka Tools
export KAFKA_HOME=$HOME/tools/kafka
export PATH=$PATH:$KAFKA_HOME/bin

# Add PIP installed binaries to the path
export PATH=$PATH:$HOME/.local/bin

# GO variables
export GOPATH=$HOME/repos/go
export PATH=$PATH:$GOPATH/bin

# Kubernetes
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Minikube
source <(minikube completion zsh)

# FZF
source <(fzf --zsh)
source $HOME/tools/fzf-git.sh
export FZF_ALT_C_OPTS="--walker-skip .git,.m2,.cache,.config,.npm,.kube,.local,.minikube"

# Read the local config file -- This is not stored in yadm so use for system specific config
source $HOME/.zsh_local

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

