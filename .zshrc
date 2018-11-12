### OH MY ZSH Boilerplate ###

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
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
plugins=(git python archlinux httpie minikube vundle history-substring-search zsh-syntax-highlighting)

ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

### My configs ###

# Stop zsh recommending stupid things!
ENABLE_CORRECTION="false"
unsetopt correct_all

# Use Vim keybindings
bindkey -v

# Stop Home and End keys doing weird things
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
# Make the delete key do sensible things
bindkey "^[[3~" delete-char

# Read all the aliases
source $HOME/.zsh_aliases

# Read the local config file -- This is not stored in yadm so use for system specific config
source $HOME/.zsh_local

alias zshconfig="vim ~/.zshrc"

#Stop Ctrl+S killing the screen updates in vim
stty -ixon

# Set up fasd directory cache
eval "$(fasd --init posix-alias zsh-hook zsh-ccomp-install zsh-ccomp zsh-wcomp-install zsh-wcomp)"

#Set default apps
export VISUAL=vim
export EDITOR=vim

# Add PHD code modules to the python path
export PYTHONPATH=$PYTHONPATH:$HOME/repos/phd
export MYPYPATH=$MYPYPATH:$HOME/repos/phd

# GO variables
export GOPATH=$HOME/repos/go
export PATH=$PATH:$GOPATH/bin
alias gb=$GOPATH/bin/gb

# Ruby setup
PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin"
export GEM_HOME=$HOME/.gem

# Haskell setup
PATH=$PATH:$HOME/.cabal/bin
alias cabex='cabal exec "$SHELL"'

# Storm binaries
export PATH=$PATH:$HOME/tools/storm/bin

# Heron client tools
export PATH=$PATH:$HOME/tools/heron/bin

# Add bazel build variables
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++

# Set the timewarrior data folder location
export TIMEWARRIORDB=$HOME/GDrive/Tasks/TimeWarrior

# Add the gremlin programs to the path
export PATH=$PATH:$HOME/tools/gremlin-server/bin
export PATH=$PATH:$HOME/tools/gremlin-console/bin

# Add makelatex python script to the path
export PATH=$PATH:$HOME/tools/makelatex
